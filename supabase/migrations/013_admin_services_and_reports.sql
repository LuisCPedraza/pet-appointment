-- Admin helpers for service catalog guard and appointment reports.

create or replace function public.prevent_service_delete_with_appointments()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (
    select 1
    from public.appointments
    where service_id = old.id
  ) then
    raise exception 'No se puede eliminar un servicio con citas asociadas. Solo desactívalo.';
  end if;

  return old;
end;
$$;

drop trigger if exists trg_prevent_service_delete_with_appointments on public.services;
create trigger trg_prevent_service_delete_with_appointments
before delete on public.services
for each row
execute function public.prevent_service_delete_with_appointments();

create or replace function public.admin_appointments_report_summary(
  p_from timestamp with time zone,
  p_to timestamp with time zone,
  p_professional_id uuid default null,
  p_service_id uuid default null
)
returns table (
  total_count bigint,
  waiting_count bigint,
  confirmed_count bigint,
  in_progress_count bigint,
  attended_count bigint,
  cancelled_count bigint
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'No autorizado';
  end if;

  return query
  select
    count(*)::bigint as total_count,
    count(*) filter (where a.status = 'En espera')::bigint as waiting_count,
    count(*) filter (where a.status = 'Confirmada')::bigint as confirmed_count,
    count(*) filter (where a.status = 'En progreso')::bigint as in_progress_count,
    count(*) filter (where a.status = 'Atendida')::bigint as attended_count,
    count(*) filter (where a.status = 'Cancelada')::bigint as cancelled_count
  from public.appointments a
  join public.availability av on av.id = a.availability_id
  where av.slot_start >= p_from
    and av.slot_start <= p_to
    and (p_professional_id is null or a.professional_id = p_professional_id)
    and (p_service_id is null or a.service_id = p_service_id);
end;
$$;

grant execute on function public.admin_appointments_report_summary(timestamp with time zone, timestamp with time zone, uuid, uuid) to authenticated;

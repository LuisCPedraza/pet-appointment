-- Detalle administrativo para la pantalla de reportes.

create or replace function public.admin_appointments_report_details(
  p_from timestamp with time zone,
  p_to timestamp with time zone,
  p_professional_id uuid default null,
  p_service_id uuid default null,
  p_status text default null,
  p_limit integer default 50,
  p_offset integer default 0
)
returns table (
  id uuid,
  professional_id uuid,
  status text,
  notes text,
  created_at timestamp with time zone,
  client_id uuid,
  pet_id uuid,
  service_id uuid,
  availability_id uuid,
  client_name text,
  client_email text,
  professional_name text,
  pet_name text,
  pet_species text,
  service_name text,
  slot_start timestamp with time zone,
  slot_end timestamp with time zone
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
    a.id,
    a.professional_id,
    a.status,
    a.notes,
    a.created_at,
    a.client_id,
    a.pet_id,
    a.service_id,
    a.availability_id,
    client.full_name as client_name,
    client.email as client_email,
    professional.full_name as professional_name,
    pet.name as pet_name,
    pet.species as pet_species,
    service.name as service_name,
    av.slot_start,
    av.slot_end
  from public.appointments a
  join public.availability av on av.id = a.availability_id
  left join public.users client on client.id = a.client_id
  left join public.users professional on professional.id = a.professional_id
  left join public.pets pet on pet.id = a.pet_id
  left join public.services service on service.id = a.service_id
  where av.slot_start >= p_from
    and av.slot_start <= p_to
    and (p_professional_id is null or a.professional_id = p_professional_id)
    and (p_service_id is null or a.service_id = p_service_id)
    and (p_status is null or a.status = p_status)
  order by a.created_at desc
  limit greatest(p_limit, 0)
  offset greatest(p_offset, 0);
end;
$$;

grant execute on function public.admin_appointments_report_details(timestamp with time zone, timestamp with time zone, uuid, uuid, text, integer, integer) to authenticated;
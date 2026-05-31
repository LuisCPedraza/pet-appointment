-- HU-14: Cancelación de cita por cliente con RPC segura

alter table public.appointment_history
  add column if not exists change_reason text;

create or replace function public.cancel_client_appointment(
  p_appointment_id uuid,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_status text;
  v_previous_status text;
  v_availability_id uuid;
  v_current_user_id uuid := public.current_app_user_id();
begin
  if v_current_user_id is null then
    raise exception 'No hay sesión activa';
  end if;

  select client_id, status, availability_id
    into v_client_id, v_status, v_availability_id
  from public.appointments
  where id = p_appointment_id
  for update;

  if not found then
    raise exception 'Cita no encontrada';
  end if;

  if v_client_id <> v_current_user_id then
    raise exception 'No autorizado para cancelar esta cita';
  end if;

  if v_status not in ('En espera', 'Confirmada') then
    raise exception 'Solo se pueden cancelar citas en estado En espera o Confirmada';
  end if;

  v_previous_status := v_status;

  update public.appointments
  set status = 'Cancelada',
      updated_at = now()
  where id = p_appointment_id;

  if v_availability_id is not null then
    update public.availability
    set is_available = true
    where id = v_availability_id;
  end if;

  insert into public.appointment_history (
    appointment_id,
    previous_status,
    new_status,
    changed_by,
    change_reason,
    changed_at
  ) values (
    p_appointment_id,
    v_previous_status,
    'Cancelada',
    v_current_user_id,
    nullif(trim(p_reason), ''),
    now()
  );
end;
$$;

grant execute on function public.cancel_client_appointment(uuid, text) to authenticated;
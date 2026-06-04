-- RPC para obtener los slots ocupados por rango y profesional.
-- Evita depender de una columna inexistente en appointments y sortea RLS.

create or replace function public.get_booked_slot_ids(
  p_from timestamp with time zone,
  p_to timestamp with time zone,
  p_professional_id uuid default null
)
returns table (
  availability_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  select distinct a.availability_id
  from public.appointments a
  join public.availability av on av.id = a.availability_id
  where a.status in ('En espera', 'Confirmada', 'En progreso')
    and av.slot_start >= p_from
    and av.slot_start <= p_to
    and (p_professional_id is null or a.professional_id = p_professional_id)
    and a.availability_id is not null;
end;
$$;

grant execute on function public.get_booked_slot_ids(timestamp with time zone, timestamp with time zone, uuid) to authenticated;
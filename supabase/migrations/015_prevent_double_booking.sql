-- TASK-15: Evitar doble reserva de horarios activos
-- Esta restricción parcial impide que dos citas activas compartan el mismo slot.
-- Se complementa con validaciones en el servicio para devolver errores más claros.

begin;

with ranked_appointments as (
  select
    id,
    availability_id,
    status,
    row_number() over (
      partition by availability_id
      order by
        case status
          when 'En progreso' then 1
          when 'Confirmada' then 2
          when 'En espera' then 3
          else 4
        end,
        created_at asc,
        id asc
    ) as rn
  from public.appointments
  where availability_id is not null
    and status in ('En espera', 'Confirmada', 'En progreso')
), duplicate_appointments as (
  select id, availability_id, status
  from ranked_appointments
  where rn > 1
), cancelled_duplicates as (
  update public.appointments a
  set status = 'Cancelada',
      updated_at = now()
  from duplicate_appointments d
  where a.id = d.id
  returning a.id, d.availability_id, d.status as previous_status
)
insert into public.appointment_history (
  appointment_id,
  previous_status,
  new_status,
  changed_by,
  change_reason,
  changed_at
)
select
  id,
  previous_status,
  'Cancelada',
  null,
  'Limpieza automática por duplicado de availability_id',
  now()
from cancelled_duplicates;

create unique index if not exists idx_appointments_active_availability_unique
  on public.appointments (availability_id)
  where availability_id is not null
    and status in ('En espera', 'Confirmada', 'En progreso');

commit;

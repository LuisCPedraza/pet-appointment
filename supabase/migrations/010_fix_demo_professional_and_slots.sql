-- Idempotent demo-data repair for existing installs.
-- Ensures the demo professional can log in as profesional@pet.dev,
-- has the professional role, and starts with visible availability slots.

begin;

insert into public.users (email, full_name, phone, role)
values
  ('admin@petappointment.dev', 'Admin PetAppointment', '3000000001', 'admin'),
  ('profesional@pet.dev', 'Profesional PetAppointment', '3000000002', 'professional'),
  ('client@pet.dev', 'Cliente PetAppointment', '3000000003', 'client')
on conflict (email) do update
set full_name = excluded.full_name,
    phone = excluded.phone,
    role = excluded.role;

insert into public.services (name, description, duration_minutes, price, is_active)
values
  ('Consulta Veterinaria', 'Revision general de salud', 30, 50000, true),
  ('Peluqueria y Bano', 'Aseo completo para mascota', 60, 70000, true)
on conflict do nothing;

with demo_professional as (
  select id as professional_id
  from public.users
  where email = 'profesional@pet.dev'
  limit 1
), demo_service as (
  select id as service_id
  from public.services
  order by created_at asc
  limit 1
)
insert into public.availability (professional_id, service_id, slot_start, slot_end, is_available)
select
  demo_professional.professional_id,
  demo_service.service_id,
  slot_data.slot_start,
  slot_data.slot_end,
  true
from demo_professional
cross join demo_service
cross join (
  values
    (now() + interval '1 day' + interval '09:00', now() + interval '1 day' + interval '09:30'),
    (now() + interval '1 day' + interval '10:00', now() + interval '1 day' + interval '10:30'),
    (now() + interval '1 day' + interval '11:00', now() + interval '1 day' + interval '11:30'),
    (now() + interval '2 day' + interval '09:00', now() + interval '2 day' + interval '09:30'),
    (now() + interval '2 day' + interval '10:00', now() + interval '2 day' + interval '10:30'),
    (now() + interval '2 day' + interval '11:00', now() + interval '2 day' + interval '11:30')
) as slot_data(slot_start, slot_end)
on conflict (professional_id, slot_start) do nothing;

with demo_client as (
  select id as owner_id
  from public.users
  where email = 'client@pet.dev'
  limit 1
)
insert into public.pets (owner_id, name, species, breed, birth_date, notes)
select demo_client.owner_id, 'Luna', 'Perro', 'Mestizo', date '2021-06-15', 'Paciente de prueba'
from demo_client
where not exists (
  select 1
  from public.pets p
  where p.owner_id = demo_client.owner_id and p.name = 'Luna'
);

with demo_client as (
  select id as client_id
  from public.users
  where email = 'client@pet.dev'
  limit 1
), demo_professional as (
  select id as professional_id
  from public.users
  where email = 'profesional@pet.dev'
  limit 1
), demo_pet as (
  select id as pet_id
  from public.pets
  where name = 'Luna'
  order by created_at desc
  limit 1
), demo_service as (
  select id as service_id
  from public.services
  order by created_at asc
  limit 1
), demo_slot as (
  select id as availability_id
  from public.availability
  where professional_id = (select professional_id from demo_professional)
    and is_available = true
  order by slot_start asc
  limit 1
), demo_appointment as (
  insert into public.appointments (client_id, pet_id, professional_id, service_id, availability_id, status, notes)
  select
    demo_client.client_id,
    demo_pet.pet_id,
    demo_professional.professional_id,
    demo_service.service_id,
    demo_slot.availability_id,
    'En espera',
    'Cita semilla para validacion'
  from demo_client, demo_professional, demo_pet, demo_service, demo_slot
  where not exists (
    select 1
    from public.appointments a
    where a.client_id = demo_client.client_id
      and a.pet_id = demo_pet.pet_id
      and a.availability_id = demo_slot.availability_id
  )
  returning id
)
insert into public.appointment_history (appointment_id, previous_status, new_status, changed_by)
select demo_appointment.id, null, 'En espera', demo_professional.professional_id
from demo_appointment, demo_professional;

update public.availability
set is_available = false
where id in (
  select availability_id
  from public.appointments
  where notes = 'Cita semilla para validacion'
    and availability_id is not null
);

commit;
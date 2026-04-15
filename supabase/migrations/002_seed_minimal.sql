-- Seed minimo para validar TASK-02P1 y TASK-03
-- Incluye: 1 admin, 1 professional, 1 client, 2 services, 3+ availability,
-- 1 appointment y 1 appointment_history.

-- 1) Usuarios base
insert into public.users (email, full_name, phone, role)
values
  ('admin@petappointment.dev', 'Admin PetAppointment', '3000000001', 'admin'),
  ('pro@petappointment.dev', 'Profesional PetAppointment', '3000000002', 'professional'),
  ('client@petappointment.dev', 'Cliente PetAppointment', '3000000003', 'client')
on conflict (email) do update
set full_name = excluded.full_name,
    phone = excluded.phone,
    role = excluded.role;

-- 2) Servicios base
insert into public.services (name, description, duration_minutes, price, is_active)
values
  ('Consulta Veterinaria', 'Revision general de salud', 30, 50000, true),
  ('Peluqueria y Bano', 'Aseo completo para mascota', 60, 70000, true)
on conflict do nothing;

-- 3) Availability para profesional
with pro as (
  select id as professional_id
  from public.users
  where email = 'pro@petappointment.dev'
  limit 1
), svc as (
  select id as service_id
  from public.services
  order by created_at asc
  limit 1
)
insert into public.availability (professional_id, service_id, slot_start, slot_end, is_available)
select
  pro.professional_id,
  svc.service_id,
  s.slot_start,
  s.slot_end,
  true
from pro
cross join svc
cross join (
  values
    (now() + interval '1 day' + interval '09:00', now() + interval '1 day' + interval '09:30'),
    (now() + interval '1 day' + interval '10:00', now() + interval '1 day' + interval '10:30'),
    (now() + interval '1 day' + interval '11:00', now() + interval '1 day' + interval '11:30')
) as s(slot_start, slot_end)
on conflict (professional_id, slot_start) do nothing;

-- 4) Mascota base para cliente
with c as (
  select id as owner_id
  from public.users
  where email = 'client@petappointment.dev'
  limit 1
)
insert into public.pets (owner_id, name, species, breed, birth_date, notes)
select c.owner_id, 'Luna', 'Perro', 'Mestizo', date '2021-06-15', 'Paciente de prueba'
from c
where not exists (
  select 1
  from public.pets p
  where p.owner_id = c.owner_id and p.name = 'Luna'
);

-- 5) Crear 1 cita de prueba + historial
with c as (
  select id as client_id
  from public.users
  where email = 'client@petappointment.dev'
  limit 1
), p as (
  select id as professional_id
  from public.users
  where email = 'pro@petappointment.dev'
  limit 1
), pet as (
  select id as pet_id
  from public.pets
  where name = 'Luna'
  order by created_at desc
  limit 1
), svc as (
  select id as service_id
  from public.services
  order by created_at asc
  limit 1
), av as (
  select id as availability_id
  from public.availability
  where is_available = true
  order by slot_start asc
  limit 1
), ap as (
  insert into public.appointments (client_id, pet_id, professional_id, service_id, availability_id, status, notes)
  select
    c.client_id,
    pet.pet_id,
    p.professional_id,
    svc.service_id,
    av.availability_id,
    'En espera',
    'Cita semilla para validacion'
  from c, p, pet, svc, av
  where not exists (
    select 1
    from public.appointments a
    where a.client_id = c.client_id
      and a.pet_id = pet.pet_id
      and a.availability_id = av.availability_id
  )
  returning id
)
insert into public.appointment_history (appointment_id, previous_status, new_status, changed_by)
select ap.id, null, 'En espera', p.professional_id
from ap, p;

-- 6) Marcar slot usado por la cita semilla (si aplica)
update public.availability
set is_available = false
where id in (
  select availability_id
  from public.appointments
  where notes = 'Cita semilla para validacion'
    and availability_id is not null
);

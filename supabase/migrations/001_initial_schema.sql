-- TASK-03: Esquema inicial de base de datos para PetAppointment
-- Tablas objetivo: users, pets, services, availability, appointments, appointment_history

create extension if not exists "uuid-ossp";

-- USERS
create table if not exists public.users (
  id uuid primary key default uuid_generate_v4(),
  email text not null unique,
  full_name text not null,
  phone text,
  role text not null default 'client' check (role in ('client', 'professional', 'admin')),
  created_at timestamp with time zone not null default now()
);

-- PETS
create table if not exists public.pets (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  species text not null,
  breed text,
  birth_date date,
  notes text,
  photo_url text,
  created_at timestamp with time zone not null default now()
);

-- SERVICES
create table if not exists public.services (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  duration_minutes integer not null default 30,
  price numeric(10, 2) not null default 0,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now()
);

-- AVAILABILITY
create table if not exists public.availability (
  id uuid primary key default uuid_generate_v4(),
  professional_id uuid not null references public.users(id) on delete cascade,
  service_id uuid references public.services(id) on delete set null,
  slot_start timestamp with time zone not null,
  slot_end timestamp with time zone not null,
  is_available boolean not null default true,
  created_at timestamp with time zone not null default now(),
  constraint availability_slot_valid check (slot_end > slot_start),
  constraint availability_unique_slot unique (professional_id, slot_start)
);

-- APPOINTMENTS
create table if not exists public.appointments (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid not null references public.users(id) on delete cascade,
  pet_id uuid not null references public.pets(id) on delete cascade,
  professional_id uuid not null references public.users(id) on delete cascade,
  service_id uuid references public.services(id) on delete set null,
  availability_id uuid references public.availability(id) on delete set null,
  status text not null default 'En espera' check (status in ('En espera', 'Confirmada', 'En progreso', 'Atendida', 'Cancelada')),
  notes text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- APPOINTMENT HISTORY
create table if not exists public.appointment_history (
  id uuid primary key default uuid_generate_v4(),
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  previous_status text,
  new_status text not null,
  changed_by uuid references public.users(id) on delete set null,
  changed_at timestamp with time zone not null default now()
);

-- Indices clave
create index if not exists idx_pets_owner_id on public.pets(owner_id);
create index if not exists idx_availability_professional_id on public.availability(professional_id);
create index if not exists idx_availability_slot_start on public.availability(slot_start);
create index if not exists idx_appointments_client_id on public.appointments(client_id);
create index if not exists idx_appointments_professional_id on public.appointments(professional_id);
create index if not exists idx_appointments_status on public.appointments(status);
create index if not exists idx_appointment_history_appointment_id on public.appointment_history(appointment_id);

-- Helpers para resolver identidad y rol del usuario autenticado
create or replace function public.current_user_email()
returns text
language sql
stable
as $$
  select coalesce(auth.jwt() ->> 'email', '')
$$;

create or replace function public.current_app_user_id()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select id
  from public.users
  where email = public.current_user_email()
  limit 1
$$;

create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.users
    where email = public.current_user_email()
      and role = 'admin'
  )
$$;

create or replace function public.is_professional()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.users
    where email = public.current_user_email()
      and role in ('professional', 'admin')
  )
$$;

-- Habilitar RLS en todas las tablas
alter table public.users enable row level security;
alter table public.pets enable row level security;
alter table public.services enable row level security;
alter table public.availability enable row level security;
alter table public.appointments enable row level security;
alter table public.appointment_history enable row level security;

-- USERS
drop policy if exists users_select_own_or_admin on public.users;
create policy users_select_own_or_admin
on public.users
for select
using (
  email = public.current_user_email()
  or public.is_admin()
);

drop policy if exists users_insert_own_or_admin on public.users;
create policy users_insert_own_or_admin
on public.users
for insert
with check (
  email = public.current_user_email()
  or public.is_admin()
);

drop policy if exists users_update_own_or_admin on public.users;
create policy users_update_own_or_admin
on public.users
for update
using (
  email = public.current_user_email()
  or public.is_admin()
)
with check (
  email = public.current_user_email()
  or public.is_admin()
);

drop policy if exists users_delete_admin_only on public.users;
create policy users_delete_admin_only
on public.users
for delete
using (public.is_admin());

-- PETS
drop policy if exists pets_select_owner_or_admin on public.pets;
create policy pets_select_owner_or_admin
on public.pets
for select
using (
  owner_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists pets_insert_owner_or_admin on public.pets;
create policy pets_insert_owner_or_admin
on public.pets
for insert
with check (
  owner_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists pets_update_owner_or_admin on public.pets;
create policy pets_update_owner_or_admin
on public.pets
for update
using (
  owner_id = public.current_app_user_id()
  or public.is_admin()
)
with check (
  owner_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists pets_delete_owner_or_admin on public.pets;
create policy pets_delete_owner_or_admin
on public.pets
for delete
using (
  owner_id = public.current_app_user_id()
  or public.is_admin()
);

-- SERVICES
drop policy if exists services_select_authenticated on public.services;
create policy services_select_authenticated
on public.services
for select
using (auth.role() = 'authenticated');

drop policy if exists services_manage_admin_only on public.services;
create policy services_manage_admin_only
on public.services
for insert
with check (public.is_admin());

drop policy if exists services_update_admin_only on public.services;
create policy services_update_admin_only
on public.services
for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists services_delete_admin_only on public.services;
create policy services_delete_admin_only
on public.services
for delete
using (public.is_admin());

-- AVAILABILITY
drop policy if exists availability_select_authenticated on public.availability;
create policy availability_select_authenticated
on public.availability
for select
using (auth.role() = 'authenticated');

drop policy if exists availability_insert_professional_or_admin on public.availability;
create policy availability_insert_professional_or_admin
on public.availability
for insert
with check (
  professional_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists availability_update_professional_or_admin on public.availability;
create policy availability_update_professional_or_admin
on public.availability
for update
using (
  professional_id = public.current_app_user_id()
  or public.is_admin()
)
with check (
  professional_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists availability_delete_professional_or_admin on public.availability;
create policy availability_delete_professional_or_admin
on public.availability
for delete
using (
  professional_id = public.current_app_user_id()
  or public.is_admin()
);

-- APPOINTMENTS
drop policy if exists appointments_select_client_professional_or_admin on public.appointments;
create policy appointments_select_client_professional_or_admin
on public.appointments
for select
using (
  client_id = public.current_app_user_id()
  or professional_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists appointments_insert_client_or_admin on public.appointments;
create policy appointments_insert_client_or_admin
on public.appointments
for insert
with check (
  client_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists appointments_update_client_professional_or_admin on public.appointments;
create policy appointments_update_client_professional_or_admin
on public.appointments
for update
using (
  client_id = public.current_app_user_id()
  or professional_id = public.current_app_user_id()
  or public.is_admin()
)
with check (
  client_id = public.current_app_user_id()
  or professional_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists appointments_delete_admin_only on public.appointments;
create policy appointments_delete_admin_only
on public.appointments
for delete
using (public.is_admin());

-- APPOINTMENT HISTORY
drop policy if exists appointment_history_select_related_users on public.appointment_history;
create policy appointment_history_select_related_users
on public.appointment_history
for select
using (
  exists (
    select 1
    from public.appointments a
    where a.id = appointment_history.appointment_id
      and (
        a.client_id = public.current_app_user_id()
        or a.professional_id = public.current_app_user_id()
        or public.is_admin()
      )
  )
);

drop policy if exists appointment_history_insert_professional_or_admin on public.appointment_history;
create policy appointment_history_insert_professional_or_admin
on public.appointment_history
for insert
with check (
  public.is_professional()
  or public.is_admin()
);

drop policy if exists appointment_history_update_admin_only on public.appointment_history;
create policy appointment_history_update_admin_only
on public.appointment_history
for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists appointment_history_delete_admin_only on public.appointment_history;
create policy appointment_history_delete_admin_only
on public.appointment_history
for delete
using (public.is_admin());

-- TASK-02P1: Storage bucket para fotos de mascotas
insert into storage.buckets (id, name, public)
values ('pet-photos', 'pet-photos', true)
on conflict (id) do nothing;

-- TASK-02P1: Realtime en tablas necesarias
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'availability'
  ) then
    alter publication supabase_realtime add table public.availability;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'appointments'
  ) then
    alter publication supabase_realtime add table public.appointments;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'appointment_history'
  ) then
    alter publication supabase_realtime add table public.appointment_history;
  end if;
end $$;

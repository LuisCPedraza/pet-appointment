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

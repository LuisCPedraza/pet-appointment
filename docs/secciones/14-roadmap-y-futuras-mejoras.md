## 14. Roadmap y Futuras Mejoras

### Versión 2.0 (Siguiente iteración)

| # | Funcionalidad | Descripción |
|---|---|---|
| F-01 | Pagos en línea | Integración con PSE (Colombia), tarjeta de crédito/débito vía Stripe o MercadoPago |
| F-02 | Historia clínica digital | Registro de diagnósticos, vacunas, medicamentos y evolución por mascota |
| F-03 | Chat en tiempo real | Mensajería directa entre cliente y profesional usando Supabase Realtime |
| F-04 | Sistema de reseñas y calificaciones | Valoración del servicio post-cita; promedio visible en perfil del profesional |
| F-05 | Notificaciones WhatsApp en producción | Cuenta de negocio verificada con plantillas aprobadas por Meta |
| F-06 | Portal web administrativo | Dashboard web (Next.js o React) para administración desde escritorio |

### Versión 3.0 (Largo plazo)

| # | Funcionalidad | Descripción |
|---|---|---|
| F-07 | Multi-sucursal | Soporte para clínicas con múltiples sedes o franquicias |
| F-08 | Módulo de inventario | Control de medicamentos, insumos y vacunas |
| F-09 | Telemedicina básica | Consultas de seguimiento por videollamada integrada |
| F-10 | App para iOS en App Store | Publicación oficial en el App Store de Apple |
| F-11 | Integración con wearables | Lectura de datos de salud de mascotas desde dispositivos IoT |
| F-12 | IA para recomendaciones | Recordatorios inteligentes de vacunas, desparasitación y revisiones periódicas |

---

## Apéndice A — Scripts SQL de Migración

```sql
-- supabase/migrations/001_initial_schema.sql

-- Habilitar extensión uuid
create extension if not exists "uuid-ossp";
create extension if not exists "pg_net";

-- Tabla de perfiles de usuario (extiende auth.users de Supabase)
create table public.users (
  id uuid references auth.users(id) on delete cascade primary key,
  email text not null,
  full_name text not null,
  phone text,
  role text not null default 'client' check (role in ('client', 'professional', 'admin')),
  avatar_url text,
  created_at timestamp with time zone default now()
);

-- Tabla de mascotas
create table public.pets (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references public.users(id) on delete cascade not null,
  name text not null,
  species text not null check (species in ('Perro', 'Gato', 'Otro')),
  breed text,
  birth_date date,
  notes text,
  photo_url text,
  created_at timestamp with time zone default now()
);

-- Tabla de servicios
create table public.services (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  description text,
  duration_minutes integer not null default 30,
  price decimal(10, 2) not null default 0,
  is_active boolean not null default true
);

-- Tabla de profesionales
create table public.professionals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null unique,
  specialization text,
  bio text
);

-- Tabla de horarios disponibles
create table public.available_slots (
  id uuid default uuid_generate_v4() primary key,
  professional_id uuid references public.professionals(id) on delete cascade not null,
  service_id uuid references public.services(id) on delete set null,
  slot_start timestamp with time zone not null,
  slot_end timestamp with time zone not null,
  is_available boolean not null default true,
  constraint no_overlap unique (professional_id, slot_start)
);

-- Tabla de citas
create table public.appointments (
  id uuid default uuid_generate_v4() primary key,
  client_id uuid references public.users(id) on delete cascade not null,
  pet_id uuid references public.pets(id) on delete cascade not null,
  professional_id uuid references public.professionals(id) on delete cascade not null,
  service_id uuid references public.services(id) on delete set null,
  slot_id uuid references public.available_slots(id) on delete set null,
  status text not null default 'En espera'
    check (status in ('En espera', 'Confirmada', 'En progreso', 'Atendida', 'Cancelada')),
  notes text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Tabla de historial de estados de citas
create table public.appointment_history (
  id uuid default uuid_generate_v4() primary key,
  appointment_id uuid references public.appointments(id) on delete cascade not null,
  previous_status text,
  new_status text not null,
  changed_by uuid references public.users(id) on delete set null,
  changed_at timestamp with time zone default now()
);

-- Tabla de notificaciones
create table public.notifications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  appointment_id uuid references public.appointments(id) on delete cascade,
  type text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamp with time zone default now()
);

-- Índices para rendimiento
create index idx_appointments_client_id on appointments(client_id);
create index idx_appointments_professional_id on appointments(professional_id);
create index idx_appointments_status on appointments(status);
create index idx_available_slots_professional_id on available_slots(professional_id);
create index idx_available_slots_slot_start on available_slots(slot_start);
create index idx_notifications_user_id on notifications(user_id);

-- Trigger: actualizar updated_at en appointments
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger appointments_updated_at
  before update on appointments
  for each row execute function update_updated_at();

-- Trigger: registrar historial al cambiar estado
create or replace function log_appointment_status_change()
returns trigger as $$
begin
  if OLD.status is distinct from NEW.status then
    insert into appointment_history (appointment_id, previous_status, new_status, changed_by)
    values (NEW.id, OLD.status, NEW.status, auth.uid());
  end if;
  return NEW;
end;
$$ language plpgsql security definer;

create trigger on_appointment_status_change
  after update of status on appointments
  for each row execute function log_appointment_status_change();
```

---

## Apéndice B — Glosario

| Término | Definición |
|---|---|
| **APK** | Android Package Kit — archivo ejecutable para instalar aplicaciones en Android |
| **BaaS** | Backend as a Service — servicio que provee infraestructura de backend sin servidor propio |
| **Edge Function** | Función serverless ejecutada en la red perimetral de Supabase (basada en Deno) |
| **JWT** | JSON Web Token — estándar para transmisión segura de información entre partes |
| **Realtime** | Funcionalidad de Supabase para sincronización instantánea de datos vía WebSocket |
| **RLS** | Row Level Security — políticas de seguridad a nivel de fila en PostgreSQL |
| **Slot** | Franja horaria disponible para ser reservada por un cliente |
| **Story Points** | Unidad de medida relativa del esfuerzo de implementación de una historia de usuario |
| **Twilio** | Plataforma de comunicaciones cloud que provee APIs para SMS, voz y WhatsApp |
| **Widget** | Componente visual de Flutter que representa un elemento de la interfaz de usuario |

---

<div align="center">

---

**PetAppointment v1.0** — Documentación Técnica  
Proyecto Universitario | Desarrollo Móvil con Flutter y Supabase  
📅 Marzo 2026 | 🎓 [Nombre de la Universidad]

*"Porque el cuidado de tu mascota merece la mejor tecnología 🐾"*

</div>

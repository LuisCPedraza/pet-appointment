-- RPC segura para devolver las citas visibles al usuario actual con todos los campos
-- necesarios para la UI, evitando joins bloqueados por RLS en users/pets.

create or replace function public.get_my_appointments_with_details()
returns table (
  id uuid,
  client_id uuid,
  client_name text,
  client_email text,
  pet_id uuid,
  pet_name text,
  pet_species text,
  professional_id uuid,
  professional_name text,
  service_id uuid,
  service_name text,
  scheduled_at timestamp with time zone,
  status text,
  notes text,
  created_at timestamp with time zone,
  availability_id uuid
)
language sql
security definer
set search_path = public, pg_catalog
as $$
  select
    a.id,
    a.client_id,
    coalesce(cu.full_name, '') as client_name,
    coalesce(cu.email, '') as client_email,
    a.pet_id,
    coalesce(p.name, '') as pet_name,
    coalesce(p.species, '') as pet_species,
    a.professional_id,
    coalesce(pu.full_name, '') as professional_name,
    a.service_id,
    coalesce(s.name, '') as service_name,
    av.slot_start as scheduled_at,
    a.status,
    a.notes,
    a.created_at,
    a.availability_id
  from public.appointments a
  left join public.users cu on cu.id = a.client_id
  left join public.pets p on p.id = a.pet_id
  left join public.users pu on pu.id = a.professional_id
  left join public.services s on s.id = a.service_id
  left join public.availability av on av.id = a.availability_id
  where a.client_id = public.current_app_user_id()
     or a.professional_id = public.current_app_user_id()
     or public.is_admin();
$$;

grant execute on function public.get_my_appointments_with_details() to authenticated;

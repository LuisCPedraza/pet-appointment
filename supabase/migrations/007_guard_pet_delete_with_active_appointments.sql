-- HU-9: evitar eliminar mascotas con citas activas y optimizar la verificacion

create index if not exists idx_appointments_pet_id on public.appointments(pet_id);

create or replace function public.prevent_pet_delete_with_active_appointments()
returns trigger
language plpgsql
security definer
set search_path = public, pg_catalog
as $$
begin
  if exists (
    select 1
    from public.appointments
    where pet_id = old.id
      and status in ('En espera', 'Confirmada')
  ) then
    raise exception using
      errcode = 'P0001',
      message = 'No se puede eliminar la mascota porque tiene citas activas. Cancela las citas en estado "En espera" o "Confirmada" antes de continuar.';
  end if;

  return old;
end;
$$;

drop trigger if exists trg_prevent_pet_delete_with_active_appointments on public.pets;
create trigger trg_prevent_pet_delete_with_active_appointments
before delete on public.pets
for each row
execute function public.prevent_pet_delete_with_active_appointments();
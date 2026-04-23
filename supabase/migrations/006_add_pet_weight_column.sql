-- HU-6: Agregar peso opcional de mascota

alter table public.pets
  add column if not exists weight numeric(6, 2);

alter table public.pets
  drop constraint if exists pets_weight_positive;

alter table public.pets
  add constraint pets_weight_positive
  check (weight is null or weight > 0);

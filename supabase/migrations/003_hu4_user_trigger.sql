-- HU-4: Trigger para sincronizar auth.users → public.users
-- Cada vez que Supabase crea un usuario en auth.users (registro, OAuth, admin API)
-- se inserta automáticamente su fila en public.users usando los metadatos
-- enviados en el signUp (full_name, phone, role).

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email, full_name, phone, role)
  values (
    new.id,                                                          -- mismo UUID que auth.users
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.raw_user_meta_data ->> 'phone', null),
    coalesce(new.raw_user_meta_data ->> 'role', 'client')
  )
  on conflict (email) do nothing;                                    -- idempotente si ya existe
  return new;
end;
$$;

-- Vincular trigger a auth.users (se dispara tras cada INSERT)
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_auth_user();

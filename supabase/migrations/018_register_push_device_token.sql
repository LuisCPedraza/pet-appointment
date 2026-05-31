-- TASK-18: Registrar tokens push mediante RPC segura
-- Evita depender de RLS para el upsert del token y permite re-asignarlo
-- cuando el mismo dispositivo inicia sesión con otro usuario.

begin;

drop function if exists public.register_push_device_token(text, text);

create or replace function public.register_push_device_token(
  p_token text,
  p_platform text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_platform text;
begin
  if v_user_id is null then
    raise exception 'No hay sesión activa';
  end if;

  v_platform := lower(trim(p_platform));
  if v_platform not in ('android', 'ios', 'web', 'desktop', 'unknown') then
    raise exception 'Plataforma de push no soportada';
  end if;

  insert into public.push_device_tokens (
    user_id,
    token,
    platform,
    is_active,
    last_seen_at,
    updated_at
  )
  values (
    v_user_id,
    trim(p_token),
    v_platform,
    true,
    now(),
    now()
  )
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        is_active = true,
        last_seen_at = now(),
        updated_at = now();
end;
$$;

grant execute on function public.register_push_device_token(text, text) to authenticated;

commit;
-- TASK-19: Endurecer acceso a push_device_tokens
-- El cliente ya usa RPCs seguras; se revoca el DML directo para que la tabla
-- solo pueda consultarse desde la app y modificarse vía funciones definidas.

begin;

drop function if exists public.deactivate_current_user_push_tokens();
create or replace function public.deactivate_current_user_push_tokens()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.push_device_tokens
     set is_active = false,
         updated_at = now()
   where user_id = auth.uid();
end;
$$;

grant execute on function public.deactivate_current_user_push_tokens() to authenticated;

drop function if exists public.touch_push_device_token(text);
create or replace function public.touch_push_device_token(p_token text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.push_device_tokens
     set last_seen_at = now(),
         updated_at = now(),
         is_active = true
   where user_id = auth.uid()
     and token = trim(p_token);
end;
$$;

grant execute on function public.touch_push_device_token(text) to authenticated;

revoke insert, update, delete on public.push_device_tokens from authenticated;

commit;
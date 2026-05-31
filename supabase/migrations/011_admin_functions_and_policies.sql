-- Admin helpers for users management
-- Apply this migration after the base schema, auth trigger, and RLS foundation exist.

create or replace function public.admin_update_user_role(user_id uuid, new_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set role = new_role
  where id = user_id;
end;
$$;

create or replace function public.admin_set_user_active(user_id uuid, active boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set is_active = active
  where id = user_id;
end;
$$;

-- Recommended RLS policy shape for the users table:
-- 1) Only authenticated admins can read/update the table.
-- 2) The admin check should come from your existing role source (users.role or JWT claim).
-- 3) If you already have a policy system in place, keep this as a separate migration.

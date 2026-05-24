-- TASK-16: Preparar almacenamiento de tokens para push remoto
-- Esta migración deja lista la base para registrar tokens de dispositivos
-- y usarlos después desde una Edge Function o un servicio de mensajería.

begin;

create table if not exists public.push_device_tokens (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android', 'ios', 'web', 'desktop', 'unknown')),
  is_active boolean not null default true,
  last_seen_at timestamp with time zone not null default now(),
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint push_device_tokens_user_token_unique unique (user_id, token),
  constraint push_device_tokens_token_unique unique (token)
);

create index if not exists idx_push_device_tokens_user_id on public.push_device_tokens(user_id);
create index if not exists idx_push_device_tokens_active on public.push_device_tokens(is_active);

alter table public.push_device_tokens enable row level security;

drop policy if exists push_device_tokens_select_own_or_admin on public.push_device_tokens;
create policy push_device_tokens_select_own_or_admin
on public.push_device_tokens
for select
using (
  user_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists push_device_tokens_insert_own_or_admin on public.push_device_tokens;
create policy push_device_tokens_insert_own_or_admin
on public.push_device_tokens
for insert
with check (
  user_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists push_device_tokens_update_own_or_admin on public.push_device_tokens;
create policy push_device_tokens_update_own_or_admin
on public.push_device_tokens
for update
using (
  user_id = public.current_app_user_id()
  or public.is_admin()
)
with check (
  user_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists push_device_tokens_delete_own_or_admin on public.push_device_tokens;
create policy push_device_tokens_delete_own_or_admin
on public.push_device_tokens
for delete
using (
  user_id = public.current_app_user_id()
  or public.is_admin()
);

grant select, insert, update, delete on public.push_device_tokens to authenticated;

commit;

-- TASK-17: Cola de eventos para notificaciones push remotas
-- Genera eventos cuando cambian las citas y deja el envío a una Edge Function.

begin;

create table if not exists public.push_notification_events (
  id uuid primary key default uuid_generate_v4(),
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  recipient_user_id uuid not null references public.users(id) on delete cascade,
  actor_user_id uuid references public.users(id) on delete set null,
  event_type text not null check (
    event_type in (
      'appointment_created',
      'appointment_confirmed',
      'appointment_started',
      'appointment_completed',
      'appointment_cancelled',
      'appointment_rescheduled'
    )
  ),
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending' check (status in ('pending', 'processing', 'sent', 'failed')),
  attempts integer not null default 0,
  error_message text,
  processed_at timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create index if not exists idx_push_notification_events_status_created_at
  on public.push_notification_events(status, created_at);

create index if not exists idx_push_notification_events_recipient
  on public.push_notification_events(recipient_user_id);

alter table public.push_notification_events enable row level security;

drop policy if exists push_notification_events_select_own_or_admin on public.push_notification_events;
create policy push_notification_events_select_own_or_admin
on public.push_notification_events
for select
using (
  recipient_user_id = public.current_app_user_id()
  or public.is_admin()
);

drop policy if exists push_notification_events_insert_admin_only on public.push_notification_events;
create policy push_notification_events_insert_admin_only
on public.push_notification_events
for insert
with check (public.is_admin());

drop policy if exists push_notification_events_update_admin_only on public.push_notification_events;
create policy push_notification_events_update_admin_only
on public.push_notification_events
for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists push_notification_events_delete_admin_only on public.push_notification_events;
create policy push_notification_events_delete_admin_only
on public.push_notification_events
for delete
using (public.is_admin());

grant select on public.push_notification_events to authenticated;

drop function if exists public.enqueue_appointment_push_events();
create or replace function public.enqueue_appointment_push_events()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event_type text;
  v_previous_status text;
  v_payload jsonb;
begin
  if TG_OP = 'INSERT' then
    v_event_type := 'appointment_created';
    v_payload := jsonb_build_object(
      'appointment_id', NEW.id,
      'operation', TG_OP,
      'status_from', null,
      'status_to', NEW.status,
      'availability_id', NEW.availability_id
    );

    insert into public.push_notification_events (
      appointment_id,
      recipient_user_id,
      actor_user_id,
      event_type,
      payload
    )
    select
      NEW.id,
      recipients.recipient_user_id,
      NEW.client_id,
      v_event_type,
      v_payload
    from (
      select distinct recipient_user_id
      from unnest(array[NEW.client_id, NEW.professional_id]) as recipient_user_id
      where recipient_user_id is not null
    ) as recipients;

    return NEW;
  end if;

  if TG_OP = 'UPDATE' then
    if OLD.status is distinct from NEW.status then
      case NEW.status
        when 'Confirmada' then v_event_type := 'appointment_confirmed';
        when 'En progreso' then v_event_type := 'appointment_started';
        when 'Atendida' then v_event_type := 'appointment_completed';
        when 'Cancelada' then v_event_type := 'appointment_cancelled';
        else v_event_type := 'appointment_rescheduled';
      end case;
      v_previous_status := OLD.status;
    elsif OLD.availability_id is distinct from NEW.availability_id then
      v_event_type := 'appointment_rescheduled';
      v_previous_status := OLD.status;
    else
      return NEW;
    end if;

    v_payload := jsonb_build_object(
      'appointment_id', NEW.id,
      'operation', TG_OP,
      'status_from', v_previous_status,
      'status_to', NEW.status,
      'availability_id', NEW.availability_id,
      'previous_availability_id', OLD.availability_id
    );

    insert into public.push_notification_events (
      appointment_id,
      recipient_user_id,
      actor_user_id,
      event_type,
      payload
    )
    select
      NEW.id,
      recipients.recipient_user_id,
      NEW.client_id,
      v_event_type,
      v_payload
    from (
      select distinct recipient_user_id
      from unnest(array[NEW.client_id, NEW.professional_id]) as recipient_user_id
      where recipient_user_id is not null
    ) as recipients;

    return NEW;
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_enqueue_appointment_push_events on public.appointments;
create trigger trg_enqueue_appointment_push_events
after insert or update on public.appointments
for each row
execute function public.enqueue_appointment_push_events();

grant execute on function public.enqueue_appointment_push_events() to authenticated;

commit;

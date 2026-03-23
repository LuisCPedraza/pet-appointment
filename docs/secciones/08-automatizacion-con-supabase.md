## 8. Automatización con Supabase

### 8.1 Sincronización en Tiempo Real de Horarios

La sincronización en tiempo real se implementa mediante **Supabase Realtime** usando canales de Postgres Changes. Cuando un slot cambia de disponibilidad (alguien agenda o cancela), todos los clientes conectados reciben la actualización instantáneamente.

```dart
// lib/features/calendar/data/datasources/calendar_realtime_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarRealtimeDatasource {
  final SupabaseClient _client;
  RealtimeChannel? _slotsChannel;

  CalendarRealtimeDatasource(this._client);

  /// Suscripción a cambios en available_slots para un profesional y fecha específicos
  Stream<List<Map<String, dynamic>>> watchAvailableSlots({
    required String professionalId,
    required DateTime date,
  }) {
    return _client
        .from('available_slots')
        .stream(primaryKey: ['id'])
        .eq('professional_id', professionalId)
        .order('slot_start');
  }

  /// Suscripción broadcast para notificaciones de nueva cita al profesional
  void subscribeToNewAppointments({
    required String professionalId,
    required Function(Map<String, dynamic>) onNewAppointment,
  }) {
    _slotsChannel = _client
        .channel('appointments:professional:$professionalId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'professional_id',
            value: professionalId,
          ),
          callback: (payload) {
            onNewAppointment(payload.newRecord);
          },
        )
        .subscribe();
  }

  void dispose() {
    _slotsChannel?.unsubscribe();
  }
}
```

### 8.2 Recordatorios Automáticos con Edge Functions

La Edge Function de recordatorio se ejecuta mediante un **cron job programado** en Supabase (pg_cron) que dispara la función cada hora para revisar citas próximas.

```typescript
// supabase/functions/send-appointment-reminder/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (_req) => {
  // Buscar citas que ocurren en las próximas 24 horas
  const tomorrow = new Date();
  tomorrow.setHours(tomorrow.getHours() + 24);

  const today = new Date();

  const { data: upcomingAppointments, error } = await supabaseAdmin
    .from("appointments")
    .select(`
      id,
      status,
      client_id,
      pets (name),
      services (name),
      available_slots (slot_start),
      users!client_id (full_name, phone)
    `)
    .eq("status", "Confirmada")
    .gte("available_slots.slot_start", today.toISOString())
    .lte("available_slots.slot_start", tomorrow.toISOString());

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  // Crear notificación en DB para cada cita próxima
  for (const appointment of upcomingAppointments ?? []) {
    await supabaseAdmin.from("notifications").insert({
      user_id: appointment.client_id,
      appointment_id: appointment.id,
      type: "reminder_24h",
      message: `Recordatorio: Mañana tienes cita para ${appointment.pets?.name} — ${appointment.services?.name}`,
      is_read: false,
    });
  }

  return new Response(
    JSON.stringify({ processed: upcomingAppointments?.length ?? 0 }),
    { headers: { "Content-Type": "application/json" } }
  );
});
```

**Configuración del cron job en Supabase (SQL):**

```sql
-- Ejecutar la Edge Function cada hora para revisar recordatorios
select cron.schedule(
  'appointment-reminders',
  '0 * * * *',  -- cada hora
  $$
  select
    net.http_post(
      url := current_setting('app.settings.edge_function_url') || '/send-appointment-reminder',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
      ),
      body := '{}'::jsonb
    )
  $$
);
```

### 8.3 Notificaciones por WhatsApp (Twilio)

Este módulo se implementa como **prototipo funcional**. Requiere una cuenta de Twilio con el sandbox o número de WhatsApp Business verificado.

**Paso 1:** Crear la Edge Function para WhatsApp

```typescript
// supabase/functions/send-whatsapp-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const TWILIO_ACCOUNT_SID = Deno.env.get("TWILIO_ACCOUNT_SID")!;
const TWILIO_AUTH_TOKEN = Deno.env.get("TWILIO_AUTH_TOKEN")!;
const TWILIO_WHATSAPP_FROM = Deno.env.get("TWILIO_WHATSAPP_FROM")!; // "whatsapp:+14155238886"

serve(async (req) => {
  const { to_phone, message } = await req.json();

  // Formatear número para WhatsApp (E.164)
  const toWhatsApp = `whatsapp:+57${to_phone.replace(/\D/g, "")}`;

  const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`;

  const body = new URLSearchParams({
    From: TWILIO_WHATSAPP_FROM,
    To: toWhatsApp,
    Body: message,
  });

  const response = await fetch(twilioUrl, {
    method: "POST",
    headers: {
      Authorization: "Basic " + btoa(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`),
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  });

  const result = await response.json();

  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" },
    status: response.status,
  });
});
```

**Paso 2:** Configurar Database Trigger en PostgreSQL

```sql
-- Función que se ejecuta al cambiar el estado de una cita
create or replace function notify_whatsapp_on_status_change()
returns trigger as $$
declare
  client_phone text;
  client_name text;
  pet_name text;
  service_name text;
  msg text;
begin
  -- Solo notificar en cambios relevantes de estado
  if NEW.status in ('Confirmada', 'Cancelada', 'Atendida') then

    -- Obtener datos del cliente y la mascota
    select u.phone, u.full_name, p.name, s.name
    into client_phone, client_name, pet_name, service_name
    from users u
    join pets p on p.id = NEW.pet_id
    join services s on s.id = NEW.service_id
    where u.id = NEW.client_id;

    -- Construir mensaje según estado
    msg := case NEW.status
      when 'Confirmada' then
        '✅ Hola ' || client_name || ', tu cita para ' || pet_name ||
        ' (' || service_name || ') ha sido CONFIRMADA. ¡Te esperamos! 🐾'
      when 'Cancelada' then
        '❌ Hola ' || client_name || ', lamentamos informarte que la cita de ' ||
        pet_name || ' ha sido CANCELADA. Contáctanos para reprogramar.'
      when 'Atendida' then
        '🎉 ¡Listo! ' || pet_name || ' fue atendido(a) exitosamente. ' ||
        'Gracias por confiar en nosotros. 🐾'
      else ''
    end;

    -- Invocar Edge Function via pg_net (extensión de Supabase)
    perform net.http_post(
      url := current_setting('app.settings.edge_function_url') || '/send-whatsapp-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
      ),
      body := jsonb_build_object(
        'to_phone', client_phone,
        'message', msg
      )
    );
  end if;

  return NEW;
end;
$$ language plpgsql security definer;

-- Registrar el trigger en la tabla appointments
create trigger on_appointment_status_change
  after update of status on appointments
  for each row
  execute function notify_whatsapp_on_status_change();
```

---


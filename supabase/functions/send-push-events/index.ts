import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

type PushEventRow = {
  id: string;
  appointment_id: string;
  recipient_user_id: string;
  actor_user_id: string | null;
  event_type: string;
  payload: Record<string, unknown>;
  status: string;
  attempts: number;
};

type AppointmentRow = {
  id: string;
  status: string;
  client_id: string;
  professional_id: string;
  client_name: string | null;
  professional_name: string | null;
  pet_name: string | null;
  service_name: string | null;
  scheduled_at: string | null;
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function env(name: string): string {
  const value = Deno.env.get(name);
  if (!value || value.trim().length === 0) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function safeDateLabel(value: string | null): string {
  if (!value) return 'pronto';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'pronto';
  return new Intl.DateTimeFormat('es-ES', {
    day: 'numeric',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
}

function buildNotificationContent(event: PushEventRow, appointment: AppointmentRow) {
  const scheduledAt = safeDateLabel(appointment.scheduled_at);
  const serviceName = appointment.service_name ?? 'tu cita';
  const petName = appointment.pet_name ?? 'tu mascota';

  switch (event.event_type) {
    case 'appointment_created':
      return {
        title: 'Nueva cita agendada',
        body: `${petName} fue agendado para ${serviceName} el ${scheduledAt}`,
      };
    case 'appointment_confirmed':
      return {
        title: 'Cita confirmada',
        body: `${serviceName} para ${petName} fue confirmada para el ${scheduledAt}`,
      };
    case 'appointment_started':
      return {
        title: 'Cita en progreso',
        body: `${serviceName} para ${petName} ya está en progreso`,
      };
    case 'appointment_completed':
      return {
        title: 'Cita completada',
        body: `${serviceName} para ${petName} ya fue atendida`,
      };
    case 'appointment_cancelled':
      return {
        title: 'Cita cancelada',
        body: `${serviceName} para ${petName} fue cancelada`,
      };
    case 'appointment_rescheduled':
    default:
      return {
        title: 'Cita reprogramada',
        body: `${serviceName} para ${petName} cambió de horario`,
      };
  }
}

async function sendFcmLegacyNotification({
  serverKey,
  token,
  title,
  body,
  data,
}: {
  serverKey: string;
  token: string;
  title: string;
  body: string;
  data: Record<string, unknown>;
}) {
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `key=${serverKey}`,
    },
    body: JSON.stringify({
      to: token,
      priority: 'high',
      notification: { title, body },
      data,
    }),
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`FCM error ${response.status}: ${text}`);
  }

  return text;
}

async function fetchAppointmentContext(
  supabase: ReturnType<typeof createClient>,
  appointmentId: string,
): Promise<AppointmentRow> {
  const { data: appointment, error: appointmentError } = await supabase
    .from('appointments')
    .select('id, status, client_id, professional_id, pet_id, service_id, availability_id')
    .eq('id', appointmentId)
    .single();

  if (appointmentError || !appointment) {
    throw appointmentError ?? new Error('Appointment not found');
  }

  const appointmentData = appointment as Record<string, unknown>;
  const clientId = String(appointmentData.client_id ?? '');
  const professionalId = String(appointmentData.professional_id ?? '');
  const petId = String(appointmentData.pet_id ?? '');
  const serviceId = String(appointmentData.service_id ?? '');
  const availabilityId = String(appointmentData.availability_id ?? '');

  const [clientResult, professionalResult, petResult, serviceResult, availabilityResult] =
    await Promise.all([
      clientId
        ? supabase.from('users').select('full_name').eq('id', clientId).single()
        : Promise.resolve({ data: null, error: null }),
      professionalId
        ? supabase.from('users').select('full_name').eq('id', professionalId).single()
        : Promise.resolve({ data: null, error: null }),
      petId
        ? supabase.from('pets').select('name').eq('id', petId).single()
        : Promise.resolve({ data: null, error: null }),
      serviceId
        ? supabase.from('services').select('name').eq('id', serviceId).single()
        : Promise.resolve({ data: null, error: null }),
      availabilityId
        ? supabase.from('availability').select('slot_start').eq('id', availabilityId).single()
        : Promise.resolve({ data: null, error: null }),
    ]);

  const clientRow = clientResult.data as { full_name?: string } | null;
  const professionalRow = professionalResult.data as { full_name?: string } | null;
  const petRow = petResult.data as { name?: string } | null;
  const serviceRow = serviceResult.data as { name?: string } | null;
  const availabilityRow = availabilityResult.data as { slot_start?: string } | null;

  return {
    id: String(appointmentData.id ?? appointmentId),
    status: String(appointmentData.status ?? ''),
    client_id: clientId,
    professional_id: professionalId,
    client_name: clientRow?.full_name ?? null,
    professional_name: professionalRow?.full_name ?? null,
    pet_name: petRow?.name ?? null,
    service_name: serviceRow?.name ?? null,
    scheduled_at: availabilityRow?.slot_start ?? null,
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const supabaseUrl = env('SUPABASE_URL');
    const serviceRoleKey = env('SUPABASE_SERVICE_ROLE_KEY');
    const fcmServerKey = env('FCM_SERVER_KEY');

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    const body = await req.json().catch(() => ({}));
    const limit = Math.min(Number(body.limit ?? 20) || 20, 100);

    const { data: pendingEvents, error: pendingError } = await supabase
      .from('push_notification_events')
      .select('*')
      .eq('status', 'pending')
      .order('created_at', { ascending: true })
      .limit(limit);

    if (pendingError) {
      throw pendingError;
    }

    const events = (pendingEvents ?? []) as PushEventRow[];
    let sent = 0;
    let failed = 0;

    for (const event of events) {
      const { data: claimResult, error: claimError } = await supabase
        .from('push_notification_events')
        .update({
          status: 'processing',
          updated_at: new Date().toISOString(),
          attempts: event.attempts + 1,
        })
        .eq('id', event.id)
        .eq('status', 'pending')
        .select('id');

      if (claimError || (claimResult ?? []).length === 0) {
        continue;
      }

      try {
        const appointmentRow = await fetchAppointmentContext(
          supabase,
          event.appointment_id,
        );

        const tokensQuery = await supabase
          .from('push_device_tokens')
          .select('token')
          .eq('user_id', event.recipient_user_id)
          .eq('is_active', true);

        if (tokensQuery.error) {
          throw tokensQuery.error;
        }

        const tokens = (tokensQuery.data ?? []) as Array<{ token: string }>;
        const content = buildNotificationContent(event, appointmentRow);

        if (tokens.length === 0) {
          await supabase
            .from('push_notification_events')
            .update({
              status: 'sent',
              processed_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
              error_message: null,
            })
            .eq('id', event.id);
          sent++;
          continue;
        }

        for (const tokenRow of tokens) {
          await sendFcmLegacyNotification({
            serverKey: fcmServerKey,
            token: tokenRow.token,
            title: content.title,
            body: content.body,
            data: {
              appointmentId: event.appointment_id,
              eventType: event.event_type,
              recipientUserId: event.recipient_user_id,
              status: appointmentRow.status,
              payload: event.payload,
            },
          });
        }

        await supabase
          .from('push_notification_events')
          .update({
            status: 'sent',
            processed_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            error_message: null,
          })
          .eq('id', event.id);
        sent++;
      } catch (error) {
        failed++;
        await supabase
          .from('push_notification_events')
          .update({
            status: 'failed',
            error_message: String(error),
            updated_at: new Date().toISOString(),
          })
          .eq('id', event.id);
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        processed: events.length,
        sent,
        failed,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        ok: false,
        error: String(error),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }
});

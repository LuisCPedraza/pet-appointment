-- 001_create_app_events.sql
-- Tabla para almacenar eventos de aplicación simples
CREATE TABLE IF NOT EXISTS public.app_events (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_name text NOT NULL,
  payload jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE public.app_events IS 'Eventos de analítica mínimos generados por la app (open_app, appointment_created, etc)';

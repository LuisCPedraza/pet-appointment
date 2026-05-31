-- 002_create_crash_reports.sql
-- Tabla para almacenar reportes de errores/crash
CREATE TABLE IF NOT EXISTS public.crash_reports (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  error_message text NOT NULL,
  stack text DEFAULT '',
  fatal boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE public.crash_reports IS 'Registros de errores y stack traces enviados desde la app para diagnóstico';

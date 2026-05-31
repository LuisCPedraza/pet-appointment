-- 003_rls_appointments.sql
-- Habilita Row Level Security y crea políticas para appointments y appointment_history
-- Ejecutar desde el SQL editor de Supabase o psql conectado a la DB del proyecto.

BEGIN;

-- Habilitar RLS en tablas relevantes
ALTER TABLE IF EXISTS public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.appointment_history ENABLE ROW LEVEL SECURITY;

-- Asegurar permisos básicos para el role `authenticated` (las políticas controlarán acceso granular)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.appointments TO authenticated;
GRANT SELECT, INSERT ON public.appointment_history TO authenticated;

-- Crear políticas sólo si no existen (usa pg_policies para detección)
DO $$
BEGIN
  -- SELECT: profesionales, clientes y admins pueden ver sus filas
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'appointments_select_policy' AND schemaname = 'public' AND tablename = 'appointments') THEN
    EXECUTE $policy$
      CREATE POLICY appointments_select_policy ON public.appointments
      FOR SELECT
      USING (
        -- admin via users.role = 'admin' OR professional assigned OR client owner
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'admin')
        OR professional_id = auth.uid()
        OR client_id = auth.uid()
      );
    $policy$;
  END IF;

  -- INSERT: solo el cliente propio (o admin) puede insertar su cita
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'appointments_insert_policy' AND schemaname = 'public' AND tablename = 'appointments') THEN
    EXECUTE $policy$
      CREATE POLICY appointments_insert_policy ON public.appointments
      FOR INSERT
      WITH CHECK (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'admin')
        OR client_id = auth.uid()
      );
    $policy$;
  END IF;

  -- UPDATE: profesionales asignados, el cliente propio o admin pueden actualizar
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'appointments_update_policy' AND schemaname = 'public' AND tablename = 'appointments') THEN
    EXECUTE $policy$
      CREATE POLICY appointments_update_policy ON public.appointments
      FOR UPDATE
      USING (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'admin')
        OR professional_id = auth.uid()
        OR client_id = auth.uid()
      )
      WITH CHECK (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'admin')
        OR professional_id = auth.uid()
        OR client_id = auth.uid()
      );
    $policy$;
  END IF;

  -- DELETE: solo admin
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'appointments_delete_policy' AND schemaname = 'public' AND tablename = 'appointments') THEN
    EXECUTE $policy$
      CREATE POLICY appointments_delete_policy ON public.appointments
      FOR DELETE
      USING (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'admin')
      );
    $policy$;
  END IF;

  -- appointment_history: permitir inserciones realizadas por profesional o admin (historial)
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'appointment_history_insert_policy' AND schemaname = 'public' AND tablename = 'appointment_history') THEN
    EXECUTE $policy$
      CREATE POLICY appointment_history_insert_policy ON public.appointment_history
      FOR INSERT
      WITH CHECK (
        EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND (u.role = 'admin' OR u.role = 'professional'))
      );
    $policy$;
  END IF;
END$$;

COMMIT;

-- Nota:
-- - El role `service_role` (clave de servidor) ignora RLS; las llamadas desde el servidor (si se usan) no se verán afectadas.
-- - Si en tu proyecto el role utilizado para la app cliente no es `authenticated`, ajusta los GRANT correspondientes.
-- - Revisa que la tabla `public.users` exista y que el campo `role` contenga los valores 'admin'/'professional'/'client' según tus seeds.

-- Ejecución (ejemplo desde psql):
-- psql "postgresql://<dbuser>:<dbpass>@<host>:5432/<db>" -f 003_rls_appointments.sql

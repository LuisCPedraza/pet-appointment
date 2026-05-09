-- TASK: Otorgar permisos a PostgREST para exponer tablas via REST API
-- Problema: Tablas devuelven 404 porque les faltan permisos GRANT

-- 1) Otorgar permiso de uso al schema public
grant usage on schema public to anon, authenticated, service_role;

-- 2) Otorgar acceso a todas las tablas existentes
grant select, insert, update, delete on public.users to anon, authenticated;
grant select, insert, update, delete on public.pets to anon, authenticated;
grant select, insert, update, delete on public.services to anon, authenticated;
grant select, insert, update, delete on public.availability to anon, authenticated;
grant select, insert, update, delete on public.appointments to anon, authenticated;
grant select, insert, update, delete on public.appointment_history to anon, authenticated;

-- 3) Otorgar acceso a las secuencias (para UUID auto-generados)
grant usage, select on all sequences in schema public to anon, authenticated, service_role;

-- 4) Otorgar acceso a funciones públicas (importantes para las políticas RLS)
grant execute on all functions in schema public to anon, authenticated, service_role;

-- 5) Permisos por defecto para futuras tablas
alter default privileges in schema public grant select, insert, update, delete on tables to anon, authenticated;
alter default privileges in schema public grant usage, select on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant execute on functions to anon, authenticated, service_role;

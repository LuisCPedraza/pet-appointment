# Supabase Setup - Sprint 2

Este directorio contiene la base para iniciar `TASK-02P1` y `TASK-03`.

## Tareas cubiertas

- `TASK-02P1`: Configurar proyecto Supabase
  - Auth habilitado
  - Bucket de Storage `pet-photos`
  - Realtime activado en tablas necesarias
- `TASK-03`: Esquema de base de datos y migraciones
  - Tablas: `users`, `pets`, `services`, `availability`, `appointments`, `appointment_history`

## Ejecucion de migraciones en Supabase Dashboard

1. Crear proyecto en Supabase (si aun no existe).
2. Ir a `SQL Editor`.
3. Copiar y ejecutar en orden los archivos de `supabase/migrations`.
4. Verificar que existan las tablas y relaciones en `Table Editor`.
5. Verificar bucket `pet-photos` en `Storage`.
6. Verificar Realtime en `Database -> Replication`.

## Push remoto

La base ya incluye una cola de eventos para push remoto y una Edge Function para drenarla.

1. Ejecuta las migraciones nuevas hasta `017_push_notification_events.sql`.
2. Despliega la Edge Function `send-push-events`.
3. Configura estas variables de entorno en Supabase:
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `FCM_SERVER_KEY`
4. Llama la función cuando quieras procesar eventos pendientes o prográmala como job.

## Notas

- Este esquema usa UUID y claves foraneas para mantener integridad.
- El diseño de `availability` permite gestionar bloques de horario disponibles.
- `appointment_history` conserva trazabilidad de cambios de estado.
- La mensajería remota depende de tokens de dispositivo válidos en `push_device_tokens`.

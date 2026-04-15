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

## Notas

- Este esquema usa UUID y claves foraneas para mantener integridad.
- El diseño de `availability` permite gestionar bloques de horario disponibles.
- `appointment_history` conserva trazabilidad de cambios de estado.

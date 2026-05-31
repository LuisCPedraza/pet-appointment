# Conectar dashboards y visualización de KPIs

Este documento describe opciones rápidas para visualizar los eventos almacenados en Supabase (`app_events`, `crash_reports`) y alternativas para enviar a Amplitude/Firebase.

1) Metabase (recomendado, gratuito/self-hosted)

- Crear una base de datos en Metabase apuntando a la base de datos Postgres de Supabase (host, port, db, user, password).
- Consultas SQL de ejemplo para KPIs:

```sql
-- Total de citas creadas en los últimos 30 días
SELECT
  count(*) AS total_appointments,
  date_trunc('day', created_at) AS day
FROM app_events
WHERE event_name = 'appointment_created'
  AND created_at >= now() - interval '30 days'
GROUP BY day
ORDER BY day;

-- Errores fatales por día
SELECT date_trunc('day', created_at) AS day, count(*) AS fatal_errors
FROM crash_reports
WHERE fatal = true
GROUP BY day
ORDER BY day;
```

2) Exportar a CSV / importar a BI

- Exportar `app_events` desde Supabase Studio o usar psql:

```bash
psql "sslmode=require host=<host> port=5432 dbname=<db> user=<user> password=<pw>" -c "COPY (SELECT * FROM app_events) TO STDOUT WITH CSV HEADER" > app_events.csv
```

3) Amplitude / Firebase

- Amplitude: usar la API HTTP para enviar eventos desde el backend; para migrar eventos históricos exporta CSV y usa `Import API` de Amplitude.
- Firebase: para integrar nativa necesitarás actualizar dependencias de `firebase_core` y añadir `firebase_analytics`/`firebase_crashlytics` en Flutter — tarea no trivial (puedo preparar PR separado).

4) Dashboard rápido con Supabase + PostgREST

- Usar Supabase SQL editor para crear vistas agregadas y luego exponerlas vía API o conectarlas a Metabase.

5) Sugerencias de KPIs a exponer
- citas creadas por día
- tasa de conversión (reserva / intentos)
- latencia media de operaciones críticas (RPCs)
- errores fatales y stack sampling
- retención de usuarios (7/30 días)

Si quieres, preparo un script `tools/export_events.sh` que exporta `app_events` y `crash_reports` a CSV y lo sube a un bucket, o genero la integración con Amplitude (requiere clave API). ¿Cuál prefieres?

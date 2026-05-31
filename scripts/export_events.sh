#!/usr/bin/env bash
# Exporta las tablas `app_events` y `crash_reports` a CSV.
# Opcional: sube los CSVs a S3 usando `aws` o a Supabase Storage usando `curl` + API.

set -euo pipefail

OUT_DIR="exports"
mkdir -p "$OUT_DIR"

PG_CONN_STR=${PG_CONN_STR:-}
S3_BUCKET=${S3_BUCKET:-}
S3_PREFIX=${S3_PREFIX:-}
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_KEY=${SUPABASE_KEY:-}

if [ -z "$PG_CONN_STR" ]; then
  echo "Error: define PG_CONN_STR (ej: postgresql://user:pass@host:5432/db)"
  exit 1
fi

echo "Exportando app_events..."
psql "$PG_CONN_STR" -c "COPY (SELECT * FROM public.app_events) TO STDOUT WITH CSV HEADER" > "$OUT_DIR/app_events.csv"

echo "Exportando crash_reports..."
psql "$PG_CONN_STR" -c "COPY (SELECT * FROM public.crash_reports) TO STDOUT WITH CSV HEADER" > "$OUT_DIR/crash_reports.csv"

echo "Archivos generados en: $OUT_DIR"

if [ -n "$S3_BUCKET" ]; then
  if ! command -v aws >/dev/null 2>&1; then
    echo "aws CLI no encontrada; instala aws-cli para subir a S3 o deja S3_BUCKET vacío." >&2
  else
    echo "Subiendo CSVs a s3://$S3_BUCKET/$S3_PREFIX"
    aws s3 cp "$OUT_DIR/app_events.csv" "s3://$S3_BUCKET/${S3_PREFIX}app_events.csv"
    aws s3 cp "$OUT_DIR/crash_reports.csv" "s3://$S3_BUCKET/${S3_PREFIX}crash_reports.csv"
    echo "Subida a S3 completada."
  fi
fi

if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_KEY" ]; then
  echo "Intentando subir a Supabase Storage (requiere bucket ya creado y nombre 'exports')"
  # Subir app_events.csv
  curl -s -X POST "${SUPABASE_URL}/storage/v1/object/sign/${S3_PREFIX}app_events.csv" \
    -H "apiKey: ${SUPABASE_KEY}" -H "Authorization: Bearer ${SUPABASE_KEY}" || true
  echo "(Nota) Para subir a Supabase Storage usa la API adecuada o la CLI; este script deja los CSVs listos." 
fi

echo "Hecho."

cat <<EOF
Uso:
  export PG_CONN_STR='postgresql://user:pass@host:5432/db'
  # Opcional: export S3_BUCKET='my-bucket' S3_PREFIX='pet-appointment/'
  ./scripts/export_events.sh
EOF

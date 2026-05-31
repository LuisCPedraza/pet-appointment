#!/usr/bin/env bash
# Script to generate a Flutter startup trace (requires device connected)
set -e
DEVICE=${1:-}
if [ -z "$DEVICE" ]; then
  echo "Usage: $0 <device-id>"
  exit 1
fi

OUT_DIR="trace-output"
mkdir -p "$OUT_DIR"
echo "Running app in profile and capturing startup trace..."
flutter run --profile --trace-startup -d "$DEVICE" > "$OUT_DIR/flutter_run.log" 2>&1 || true
echo "Trace run complete. Check $OUT_DIR for logs. Use DevTools to capture timeline while running."

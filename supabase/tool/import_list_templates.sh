#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <db-url> <json-file> [truncate]" >&2
  exit 1
fi

DB_URL="$1"
JSON_FILE="$2"
TRUNCATE="${3:-false}"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "JSON file not found: $JSON_FILE" >&2
  exit 1
fi

# Portable base64 without line breaks.
if command -v base64 >/dev/null 2>&1; then
  if base64 --help 2>&1 | grep -q -- '--wrap'; then
    PAYLOAD=$(base64 --wrap=0 "$JSON_FILE")
  else
    PAYLOAD=$(base64 "$JSON_FILE" | tr -d '\n')
  fi
else
  echo "Missing dependency: base64" >&2
  exit 1
fi

psql "$DB_URL" -v ON_ERROR_STOP=1 <<SQL
SELECT public.import_list_templates(
  convert_from(decode('$PAYLOAD','base64'),'utf-8')::jsonb,
  $TRUNCATE
);
SQL

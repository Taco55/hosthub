#/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# prefer local env (but don't fail if missing)
[ -f "${SCRIPT_DIR}/../.env.local" ] && set -a && source "${SCRIPT_DIR}/../.env.local" && set +a

PROPERTY_ID="${PROPERTY_ID:-${LODGIFY_PROPERTY_ID:-}}"
API_KEY="${LODGIFY_API_KEY:-}"

if [ -z "$PROPERTY_ID" ] || [ -z "$API_KEY" ]; then
  cat <<'EOF' >&2
Missing LODGIFY_PROPERTY_ID and/or LODGIFY_API_KEY in .env.local
Please add them before running this script.
EOF
  exit 1
fi

START_DATE="${1:-2025-12-01}"
END_DATE="${2:-2026-03-01}"

START_DATE_TIME="${START_DATE}T00:00:00Z"
END_DATE_TIME="${END_DATE}T00:00:00Z"

echo "Requesting Lodgify availability for property ${PROPERTY_ID} (${START_DATE} → ${END_DATE})"

curl -sSL -i \
  -H "X-ApiKey: ${API_KEY}" \
  "https://api.lodgify.com/v2/availability/${PROPERTY_ID}?start=${START_DATE_TIME}&end=${END_DATE_TIME}&includeDetails=false"

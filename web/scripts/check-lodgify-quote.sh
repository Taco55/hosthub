#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# prefer local env (but don't fail if missing)
[ -f "${SCRIPT_DIR}/../.env.local" ] && set -a && source "${SCRIPT_DIR}/../.env.local" && set +a

PROPERTY_ID="${PROPERTY_ID:-${LODGIFY_PROPERTY_ID:-}}"
ROOM_TYPE_ID="${ROOM_TYPE_ID:-${LODGIFY_ROOM_TYPE_ID:-}}"
API_KEY="${LODGIFY_API_KEY:-}"

if [ -z "$PROPERTY_ID" ] || [ -z "$ROOM_TYPE_ID" ] || [ -z "$API_KEY" ]; then
  cat <<'EOF' >&2
Missing LODGIFY_PROPERTY_ID, LODGIFY_ROOM_TYPE_ID and/or LODGIFY_API_KEY in .env.local
Please add them before running this script.
EOF
  exit 1
fi

ARRIVAL="${1:-2026-01-09}"
DEPARTURE="${2:-2026-01-15}"
ADULTS="${3:-2}"
CHILDREN="${4:-0}"
PETS="${5:-0}"

PEOPLE=$((ADULTS + CHILDREN))

echo "Requesting Lodgify quote for property ${PROPERTY_ID}, room ${ROOM_TYPE_ID}"
echo "Dates: ${ARRIVAL} → ${DEPARTURE} | Adults: ${ADULTS} | Children: ${CHILDREN} | Pets: ${PETS}"

curl -sS -i -G \
  -H "X-ApiKey: ${API_KEY}" \
  -H "accept: application/json" \
  "https://api.lodgify.com/v2/quote/${PROPERTY_ID}" \
  --data-urlencode "arrival=${ARRIVAL}" \
  --data-urlencode "departure=${DEPARTURE}" \
  --data-urlencode "roomTypes[0].Id=${ROOM_TYPE_ID}" \
  --data-urlencode "roomTypes[0].People=${PEOPLE}" \
  --data-urlencode "roomTypes[0].guest_breakdown.adults=${ADULTS}" \
  --data-urlencode "roomTypes[0].guest_breakdown.children=${CHILDREN}" \
  --data-urlencode "roomTypes[0].guest_breakdown.pets=${PETS}"

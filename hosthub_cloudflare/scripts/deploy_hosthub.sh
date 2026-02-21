#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CF_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${CF_DIR}/../.." && pwd)"
DEFAULT_ENV_FILE="${REPO_ROOT}/secrets/hosthub-cloudflare-prd.env"
LEGACY_ENV_FILE="${CF_DIR}/secrets/hosthub-prd.env"
ENV_FILE="${DEFAULT_ENV_FILE}"
DRY_RUN=0
LIVE_VERSION_URL="https://www.trysilpanorama.com/admin/hosthub-version.json"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--env-file <path>] [--dry-run]

Builds Flutter web with /admin/ base href and deploys the single
Cloudflare Worker (code + assets) using wrangler.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -f "${ENV_FILE}" ]]; then
  echo "Loading env from ${ENV_FILE}"
  # shellcheck disable=SC1090
  set -a
  source "${ENV_FILE}"
  set +a
elif [[ "${ENV_FILE}" == "${DEFAULT_ENV_FILE}" && -f "${LEGACY_ENV_FILE}" ]]; then
  echo "Loading env from legacy path ${LEGACY_ENV_FILE}"
  # shellcheck disable=SC1090
  set -a
  source "${LEGACY_ENV_FILE}"
  set +a
else
  echo "No env file found at ${ENV_FILE}, using global wrangler auth."
fi

HOSTHUB_DIR="${REPO_ROOT}/hosthub/hosthub_console"

PACKAGE_VERSION="$(
  awk '/^version:[[:space:]]*/ {print $2; exit}' "${HOSTHUB_DIR}/pubspec.yaml" \
    | cut -d+ -f1
)"

if [[ -z "${PACKAGE_VERSION}" ]]; then
  echo "Unable to resolve package version from pubspec.yaml." >&2
  exit 1
fi

echo "Deploy target version: ${PACKAGE_VERSION}"

echo "Building Flutter web..."
(
  cd "${HOSTHUB_DIR}"
  flutter build web --release --base-href /admin/
  DEPLOYED_AT_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  cat > build/web/hosthub-version.json <<EOF
{"packageVersion":"${PACKAGE_VERSION}","deployedAtUtc":"${DEPLOYED_AT_UTC}"}
EOF
  echo "Wrote build/web/hosthub-version.json (v${PACKAGE_VERSION})"
)

WRANGLER_CMD=(
  npx
  -y
  wrangler@4.64.0
  deploy
  --cwd
  "${CF_DIR}"
  --config
  "${CF_DIR}/wrangler.toml"
)

if [[ "${DRY_RUN}" -eq 1 ]]; then
  WRANGLER_CMD+=(--dry-run)
fi

echo "Deploying Worker..."
"${WRANGLER_CMD[@]}"

if [[ "${DRY_RUN}" -eq 0 ]] && command -v curl >/dev/null 2>&1; then
  echo "Live deployed version (from ${LIVE_VERSION_URL}):"
  curl -fsS "${LIVE_VERSION_URL}?_ts=$(date +%s)" || true
  echo
fi

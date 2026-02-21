#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CF_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT=""
HOSTHUB_DIR=""
PUBSPEC_PATH=""
REPO_PARENT=""
DEFAULT_ENV_FILE=""
WORKSPACE_SECRETS_ENV_FILE=""
LEGACY_ENV_FILE=""
ENV_FILE=""
ENV_FILE_EXPLICIT=0
DRY_RUN=0
HOSTHUB_PUBLIC_DOMAIN="${HOSTHUB_PUBLIC_DOMAIN:-admin.trysilpanorama.com}"
HOSTHUB_ZONE_NAME="${HOSTHUB_ZONE_NAME:-trysilpanorama.com}"
HOSTHUB_ADMIN_PATH="${HOSTHUB_ADMIN_PATH:-/}"
HOSTHUB_WASM_DRY_RUN="${HOSTHUB_WASM_DRY_RUN:-0}"
HOSTHUB_WRANGLER_VERSION="${HOSTHUB_WRANGLER_VERSION:-4.67.0}"
LIVE_VERSION_URL=""
FLUTTER_DART_DEFINES=()
FLUTTER_DART_DEFINE_KEYS=()

require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

resolve_repo_root() {
  local cursor="${CF_DIR}"
  local candidate
  local depth=0

  while [[ "${depth}" -lt 6 ]]; do
    candidate="${cursor}/hosthub_console/pubspec.yaml"
    if [[ -f "${candidate}" ]]; then
      REPO_ROOT="${cursor}"
      return 0
    fi
    if [[ "${cursor}" == "/" ]]; then
      break
    fi
    cursor="$(cd "${cursor}/.." && pwd)"
    depth=$((depth + 1))
  done

  echo "Unable to locate hosthub_console/pubspec.yaml from ${CF_DIR}." >&2
  echo "Checked parent roots up to depth ${depth}." >&2
  return 1
}

load_env_file() {
  local env_path="$1"
  echo "Loading env from ${env_path}"
  # shellcheck disable=SC1090
  set -a
  source "${env_path}"
  set +a
}

require_non_empty_env() {
  local key="$1"
  local value="${!key:-}"
  if [[ -z "${value//[[:space:]]/}" ]]; then
    echo "Missing required env value: ${key}" >&2
    exit 1
  fi
}

append_dart_define_if_set() {
  local key="$1"
  local value="${!key:-}"
  if [[ -n "${value}" ]]; then
    FLUTTER_DART_DEFINES+=("--dart-define=${key}=${value}")
    FLUTTER_DART_DEFINE_KEYS+=("${key}")
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [--env-file <path>] [--dry-run]

Builds Flutter web with HOSTHUB_ADMIN_PATH base href and deploys the single
Cloudflare Worker (code + assets) using wrangler.

Optional env vars:
  HOSTHUB_WASM_DRY_RUN=1         Enable Flutter wasm dry-run warnings (default: 0)
  HOSTHUB_WRANGLER_VERSION=<v>   Override wrangler version (default: 4.67.0)
EOF
}

resolve_repo_root
HOSTHUB_DIR="${REPO_ROOT}/hosthub_console"
PUBSPEC_PATH="${HOSTHUB_DIR}/pubspec.yaml"
REPO_PARENT="$(cd "${REPO_ROOT}/.." && pwd)"
DEFAULT_ENV_FILE="${REPO_ROOT}/secrets/hosthub-prd.env"
WORKSPACE_SECRETS_ENV_FILE="${REPO_PARENT}/hosthub_secrets/hosthub-prd.env"
LEGACY_ENV_FILE="${CF_DIR}/secrets/hosthub-prd.env"
ENV_FILE="${DEFAULT_ENV_FILE}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        echo "--env-file requires a file path." >&2
        usage
        exit 1
      fi
      ENV_FILE="${2}"
      ENV_FILE_EXPLICIT=1
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
  load_env_file "${ENV_FILE}"
elif [[ "${ENV_FILE_EXPLICIT}" -eq 1 ]]; then
  echo "Env file not found: ${ENV_FILE}" >&2
  exit 1
elif [[ -f "${WORKSPACE_SECRETS_ENV_FILE}" ]]; then
  load_env_file "${WORKSPACE_SECRETS_ENV_FILE}"
elif [[ -f "${LEGACY_ENV_FILE}" ]]; then
  load_env_file "${LEGACY_ENV_FILE}"
else
  echo "No env file found, using global wrangler auth."
  echo "Checked:"
  echo "  - ${DEFAULT_ENV_FILE}"
  echo "  - ${WORKSPACE_SECRETS_ENV_FILE}"
  echo "  - ${LEGACY_ENV_FILE}"
fi

APP_ENVIRONMENT="${APP_ENVIRONMENT:-prd}"
require_non_empty_env "SUPABASE_URL"
if [[ -z "${SUPABASE_ANON_KEY:-}" && -z "${SUPABASE_KEY:-}" ]]; then
  echo "Missing required env value: SUPABASE_ANON_KEY (preferred) or SUPABASE_KEY." >&2
  exit 1
fi

append_dart_define_if_set "APP_ENVIRONMENT"
append_dart_define_if_set "SUPABASE_URL"
append_dart_define_if_set "SUPABASE_ANON_KEY"
append_dart_define_if_set "SUPABASE_KEY"
append_dart_define_if_set "GOOGLE_API_KEY"
append_dart_define_if_set "PLACES_GOOGLE_API_KEY"
append_dart_define_if_set "ADMIN_BASE_URL"
append_dart_define_if_set "LODGIFY_BASE_URL"
append_dart_define_if_set "TESTFLIGHT_URL"
append_dart_define_if_set "CMS_PREVIEW_DOMAIN"

if [[ -z "${SUPABASE_ANON_KEY:-}" && -n "${SUPABASE_KEY:-}" ]]; then
  echo "Warning: SUPABASE_ANON_KEY is empty; using legacy SUPABASE_KEY define."
fi

if [[ "${HOSTHUB_ADMIN_PATH}" != /* ]]; then
  HOSTHUB_ADMIN_PATH="/${HOSTHUB_ADMIN_PATH}"
fi

if [[ "${HOSTHUB_ADMIN_PATH}" == "/" ]]; then
  HOSTHUB_ADMIN_PATH="/"
else
  HOSTHUB_ADMIN_PATH="${HOSTHUB_ADMIN_PATH%/}"
  if [[ -z "${HOSTHUB_ADMIN_PATH}" ]]; then
    HOSTHUB_ADMIN_PATH="/"
  fi
fi

if [[ "${HOSTHUB_ADMIN_PATH}" == "/" ]]; then
  LIVE_VERSION_URL="https://${HOSTHUB_PUBLIC_DOMAIN}/hosthub-version.json"
  FLUTTER_BASE_HREF="/"
else
  LIVE_VERSION_URL="https://${HOSTHUB_PUBLIC_DOMAIN}${HOSTHUB_ADMIN_PATH}/hosthub-version.json"
  FLUTTER_BASE_HREF="${HOSTHUB_ADMIN_PATH}/"
fi

if [[ ! -f "${PUBSPEC_PATH}" ]]; then
  echo "Unable to find ${PUBSPEC_PATH}." >&2
  exit 1
fi

require_command flutter
require_command npx

PACKAGE_VERSION="$(
  awk '/^version:[[:space:]]*/ {print $2; exit}' "${PUBSPEC_PATH}" \
    | cut -d+ -f1
)"

if [[ -z "${PACKAGE_VERSION}" ]]; then
  echo "Unable to resolve package version from pubspec.yaml." >&2
  exit 1
fi

echo "Deploy target version: ${PACKAGE_VERSION}"
echo "HostHub public domain: ${HOSTHUB_PUBLIC_DOMAIN}"
echo "Cloudflare zone: ${HOSTHUB_ZONE_NAME}"
echo "Admin path: ${HOSTHUB_ADMIN_PATH}"
echo "Wrangler version: ${HOSTHUB_WRANGLER_VERSION}"
echo "Flutter APP_ENVIRONMENT: ${APP_ENVIRONMENT}"
if [[ "${#FLUTTER_DART_DEFINE_KEYS[@]}" -gt 0 ]]; then
  echo "Flutter dart-defines: ${FLUTTER_DART_DEFINE_KEYS[*]}"
fi
if ! grep -q "${HOSTHUB_PUBLIC_DOMAIN}" "${CF_DIR}/wrangler.toml"; then
  echo "Warning: wrangler.toml routes do not include host ${HOSTHUB_PUBLIC_DOMAIN}."
fi
if ! grep -q "zone_name = \"${HOSTHUB_ZONE_NAME}\"" "${CF_DIR}/wrangler.toml"; then
  echo "Warning: wrangler.toml routes do not include zone_name=${HOSTHUB_ZONE_NAME}."
fi
if [[ "${HOSTHUB_ADMIN_PATH}" != "/" ]] && ! grep -q "${HOSTHUB_ADMIN_PATH//\//\\/}\*" "${CF_DIR}/wrangler.toml"; then
  echo "Warning: wrangler.toml routes do not include admin path ${HOSTHUB_ADMIN_PATH}*."
fi

echo "Building Flutter web..."
(
  cd "${HOSTHUB_DIR}"
  FLUTTER_BUILD_CMD=(flutter build web --release --base-href "${FLUTTER_BASE_HREF}")
  FLUTTER_BUILD_CMD+=("${FLUTTER_DART_DEFINES[@]}")
  if [[ "${HOSTHUB_WASM_DRY_RUN}" != "1" ]]; then
    FLUTTER_BUILD_CMD+=(--no-wasm-dry-run)
  fi
  "${FLUTTER_BUILD_CMD[@]}"
  DEPLOYED_AT_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  cat > build/web/hosthub-version.json <<EOF
{"packageVersion":"${PACKAGE_VERSION}","deployedAtUtc":"${DEPLOYED_AT_UTC}"}
EOF
  echo "Wrote build/web/hosthub-version.json (v${PACKAGE_VERSION})"
)

WRANGLER_CMD=(
  npx
  -y
  "wrangler@${HOSTHUB_WRANGLER_VERSION}"
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

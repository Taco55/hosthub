#!/usr/bin/env bash
set -euo pipefail

CF_API_BASE="https://api.cloudflare.com/client/v4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SOURCE_ENV_FILE="${REPO_ROOT}/../hosthub_secrets/hosthub-prd.env"
TARGET_ENV_FILE=""
DOMAINS_CSV="trysilpanorama.com,ev-reward.com"
OUTPUT_DIR=""
ALLOW_NON_EMPTY_TARGET=0
DRY_RUN=0

require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF'
Usage: prepare_zone_migration.sh --target-env <path> [options]

Copies DNS records for one or more zones from a source Cloudflare account to a
target account and stores snapshots for rollback/audit.

Required:
  --target-env <path>         Env file containing:
                              CLOUDFLARE_API_TOKEN
                              CLOUDFLARE_ACCOUNT_ID

Optional:
  --source-env <path>         Source env file (default: ../hosthub_secrets/hosthub-prd.env)
  --domains <csv>             Comma separated domains (default: trysilpanorama.com,ev-reward.com)
  --output-dir <path>         Backup output directory
  --allow-non-empty-target    Do not fail when target zone already has non NS/SOA records
  --dry-run                   Do not create zones or DNS records
  -h, --help                  Show help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target-env)
        TARGET_ENV_FILE="${2:-}"
        shift 2
        ;;
      --source-env)
        SOURCE_ENV_FILE="${2:-}"
        shift 2
        ;;
      --domains)
        DOMAINS_CSV="${2:-}"
        shift 2
        ;;
      --output-dir)
        OUTPUT_DIR="${2:-}"
        shift 2
        ;;
      --allow-non-empty-target)
        ALLOW_NON_EMPTY_TARGET=1
        shift
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
}

read_env_var() {
  local file="$1"
  local key="$2"
  local value

  if [[ ! -f "${file}" ]]; then
    echo "Env file not found: ${file}" >&2
    exit 1
  fi

  value="$(awk -F= -v k="${key}" '$1==k {sub(/^[^=]*=/, ""); print; exit}' "${file}")"
  value="${value%$'\r'}"
  echo "${value}"
}

cf_request() {
  local token="$1"
  local method="$2"
  local path="$3"
  local data="${4:-}"
  local body_file status

  body_file="$(mktemp)"
  if [[ -n "${data}" ]]; then
    status="$(curl -sS -o "${body_file}" -w '%{http_code}' -X "${method}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      "${CF_API_BASE}${path}" \
      --data "${data}")"
  else
    status="$(curl -sS -o "${body_file}" -w '%{http_code}' -X "${method}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      "${CF_API_BASE}${path}")"
  fi

  if [[ "${status}" -lt 200 || "${status}" -ge 300 ]]; then
    echo "Cloudflare API ${method} ${path} failed (HTTP ${status})." >&2
    cat "${body_file}" >&2
    rm -f "${body_file}"
    exit 1
  fi

  if [[ "$(jq -r '.success // false' "${body_file}")" != "true" ]]; then
    echo "Cloudflare API ${method} ${path} returned success=false." >&2
    cat "${body_file}" >&2
    rm -f "${body_file}"
    exit 1
  fi

  cat "${body_file}"
  rm -f "${body_file}"
}

fetch_all_dns_records() {
  local token="$1"
  local zone_id="$2"
  local page=1
  local out_file

  out_file="$(mktemp)"
  : > "${out_file}"

  while true; do
    local resp total_pages
    resp="$(cf_request "${token}" GET "/zones/${zone_id}/dns_records?per_page=500&page=${page}")"
    echo "${resp}" | jq -c '.result[]' >> "${out_file}"
    total_pages="$(echo "${resp}" | jq -r '.result_info.total_pages // 1')"
    if (( page >= total_pages )); then
      break
    fi
    page=$((page + 1))
  done

  jq -s '.' "${out_file}"
  rm -f "${out_file}"
}

build_dns_payload() {
  local record_json="$1"
  echo "${record_json}" | jq -c '
    {
      type,
      name,
      content,
      ttl,
      proxied,
      priority,
      data,
      comment,
      tags
    }
    | with_entries(select(.value != null))
    | if has("comment") and (.comment | length == 0) then del(.comment) else . end
    | if has("tags") and (.tags | length == 0) then del(.tags) else . end
  '
}

verify_access() {
  local source_token="$1"
  local target_token="$2"
  local target_account_id="$3"

  cf_request "${source_token}" GET "/user/tokens/verify" >/dev/null
  cf_request "${target_token}" GET "/user/tokens/verify" >/dev/null
  cf_request "${target_token}" GET "/accounts/${target_account_id}" >/dev/null
}

ensure_output_dir() {
  if [[ -z "${OUTPUT_DIR}" ]]; then
    OUTPUT_DIR="${REPO_ROOT}/cloudflare/migration_backups/$(date -u +%Y%m%dT%H%M%SZ)"
  fi
  mkdir -p "${OUTPUT_DIR}"
}

main() {
  parse_args "$@"
  require_command curl
  require_command jq

  if [[ -z "${TARGET_ENV_FILE}" ]]; then
    echo "--target-env is required." >&2
    usage
    exit 1
  fi

  local source_token target_token target_account_id
  source_token="$(read_env_var "${SOURCE_ENV_FILE}" "CLOUDFLARE_API_TOKEN")"
  target_token="$(read_env_var "${TARGET_ENV_FILE}" "CLOUDFLARE_API_TOKEN")"
  target_account_id="$(read_env_var "${TARGET_ENV_FILE}" "CLOUDFLARE_ACCOUNT_ID")"

  if [[ -z "${source_token}" || -z "${target_token}" || -z "${target_account_id}" ]]; then
    echo "Missing required values in source/target env files." >&2
    exit 1
  fi

  verify_access "${source_token}" "${target_token}" "${target_account_id}"
  ensure_output_dir

  IFS=',' read -r -a domains <<< "${DOMAINS_CSV}"
  local summary_file="${OUTPUT_DIR}/migration_summary.txt"
  : > "${summary_file}"

  echo "Output directory: ${OUTPUT_DIR}"
  echo "Domains: ${DOMAINS_CSV}"
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "Mode: dry-run"
  fi

  for raw_domain in "${domains[@]}"; do
    local domain
    domain="$(echo "${raw_domain}" | xargs)"
    if [[ -z "${domain}" ]]; then
      continue
    fi

    echo
    echo "=== ${domain} ==="
    mkdir -p "${OUTPUT_DIR}/${domain}"

    local source_zone_resp source_zone_id
    source_zone_resp="$(cf_request "${source_token}" GET "/zones?name=${domain}")"
    source_zone_id="$(echo "${source_zone_resp}" | jq -r '.result[0].id // empty')"
    if [[ -z "${source_zone_id}" ]]; then
      echo "Source zone not found for ${domain}." >&2
      exit 1
    fi
    echo "${source_zone_resp}" | jq '.' > "${OUTPUT_DIR}/${domain}/source_zone.json"

    local source_records
    source_records="$(fetch_all_dns_records "${source_token}" "${source_zone_id}")"
    echo "${source_records}" | jq '.' > "${OUTPUT_DIR}/${domain}/source_dns_records.json"
    local source_record_count
    source_record_count="$(echo "${source_records}" | jq 'map(select(.type != "NS" and .type != "SOA")) | length')"
    echo "Source zone id: ${source_zone_id}"
    echo "Source DNS records to copy: ${source_record_count}"

    local target_zone_resp target_zone_id
    target_zone_resp="$(cf_request "${target_token}" GET "/zones?name=${domain}&account.id=${target_account_id}")"
    target_zone_id="$(echo "${target_zone_resp}" | jq -r '.result[0].id // empty')"

    if [[ -z "${target_zone_id}" ]]; then
      if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "Would create target zone: ${domain}"
      else
        target_zone_resp="$(cf_request "${target_token}" POST "/zones" "{\"name\":\"${domain}\",\"account\":{\"id\":\"${target_account_id}\"},\"type\":\"full\",\"jump_start\":false}")"
        target_zone_id="$(echo "${target_zone_resp}" | jq -r '.result.id')"
      fi
    fi

    if [[ -z "${target_zone_id}" ]]; then
      echo "Unable to resolve target zone id for ${domain}." >&2
      exit 1
    fi

    local target_zone_detail
    target_zone_detail="$(cf_request "${target_token}" GET "/zones/${target_zone_id}")"
    echo "${target_zone_detail}" | jq '.' > "${OUTPUT_DIR}/${domain}/target_zone.json"

    local target_nameservers
    target_nameservers="$(echo "${target_zone_detail}" | jq -r '.result.name_servers | join(", ")')"
    echo "Target zone id: ${target_zone_id}"
    echo "Target nameservers: ${target_nameservers}"

    local target_records target_non_system_count
    target_records="$(fetch_all_dns_records "${target_token}" "${target_zone_id}")"
    echo "${target_records}" | jq '.' > "${OUTPUT_DIR}/${domain}/target_dns_records_before.json"
    target_non_system_count="$(echo "${target_records}" | jq 'map(select(.type != "NS" and .type != "SOA")) | length')"

    if [[ "${target_non_system_count}" != "0" && "${ALLOW_NON_EMPTY_TARGET}" -ne 1 ]]; then
      echo "Target zone ${domain} already has ${target_non_system_count} non NS/SOA records." >&2
      echo "Refusing to continue. Re-run with --allow-non-empty-target if intentional." >&2
      exit 1
    fi

    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "Would copy ${source_record_count} DNS records to target zone ${target_zone_id}"
    else
      while IFS= read -r record; do
        local payload
        payload="$(build_dns_payload "${record}")"
        cf_request "${target_token}" POST "/zones/${target_zone_id}/dns_records" "${payload}" >/dev/null
      done < <(echo "${source_records}" | jq -c '.[] | select(.type != "NS" and .type != "SOA")')

      fetch_all_dns_records "${target_token}" "${target_zone_id}" | jq '.' > "${OUTPUT_DIR}/${domain}/target_dns_records_after.json"
      echo "Copied ${source_record_count} DNS records to target zone."
    fi

    {
      echo "domain=${domain}"
      echo "source_zone_id=${source_zone_id}"
      echo "target_zone_id=${target_zone_id}"
      echo "target_nameservers=${target_nameservers}"
      echo
    } >> "${summary_file}"
  done

  echo
  echo "Migration prep complete."
  echo "Summary: ${summary_file}"
  echo
  echo "IMPORTANT: For Cloudflare Registrar domains, move the domain between accounts"
  echo "from the source account, then accept the request in the target account."
}

main "$@"

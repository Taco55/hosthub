#!/usr/bin/env bash
set -euo pipefail

# Local dev helper for HostHub CMS preview links.
# Purpose: keep the website preview endpoint available at /preview/<locale> while
# running HostHub locally (for example from VS Code preLaunchTask).
# This script is not part of production website builds or deploys.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PORT="${PREVIEW_WEB_PORT:-43001}"
HEALTH_PATH="${PREVIEW_WEB_HEALTH_PATH:-/preview/nl}"
START_HOST="${PREVIEW_WEB_HOST:-0.0.0.0}"
DISPLAY_HOST="${PREVIEW_WEB_DISPLAY_HOST:-localhost}"
WAIT_SECONDS="${PREVIEW_WEB_WAIT_SECONDS:-60}"
READY_STREAK_REQUIRED="${PREVIEW_WEB_READY_STREAK:-2}"
HOLD_MODE="${PREVIEW_WEB_HOLD:-0}"
HOLD_INTERVAL_SECONDS="${PREVIEW_WEB_HOLD_INTERVAL_SECONDS:-5}"
PID_FILE="${REPO_ROOT}/.tmp/preview-web.pid"
LOG_FILE="${REPO_ROOT}/.tmp/preview-web.log"
DISPLAY_URL="http://${DISPLAY_HOST}:${PORT}${HEALTH_PATH}"

read_pid() {
  if [[ ! -f "${PID_FILE}" ]]; then
    return 0
  fi
  tr -d '[:space:]' < "${PID_FILE}" 2>/dev/null || true
}

is_pid_running() {
  local pid="$1"
  [[ -n "${pid}" ]] && kill -0 "${pid}" >/dev/null 2>&1
}

is_listening() {
  lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1
}

listening_pids() {
  lsof -nP -t -iTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null || true
}

is_display_healthy() {
  curl -fs -o /dev/null --connect-timeout 1 --max-time 3 "${DISPLAY_URL}" >/dev/null 2>&1
}

is_healthy_on_any_loopback() {
  local health_url
  for health_url in \
    "http://${DISPLAY_HOST}:${PORT}${HEALTH_PATH}" \
    "http://localhost:${PORT}${HEALTH_PATH}" \
    "http://127.0.0.1:${PORT}${HEALTH_PATH}" \
    "http://[::1]:${PORT}${HEALTH_PATH}"; do
    if curl -fs -o /dev/null --connect-timeout 1 --max-time 3 "${health_url}" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

print_debug_context() {
  echo "Listening processes on port ${PORT}:" >&2
  lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >&2 || true
  echo "Last log lines from ${LOG_FILE}:" >&2
  tail -n 80 "${LOG_FILE}" >&2 || true
}

hold_forever() {
  if [[ "${HOLD_MODE}" != "1" ]]; then
    return 0
  fi

  echo "Holding local preview task open (VS Code background mode)."
  while true; do
    if ! is_display_healthy; then
      echo "Preview website became unreachable on ${DISPLAY_URL} while holding task open." >&2
      print_debug_context
      exit 1
    fi
    sleep "${HOLD_INTERVAL_SECONDS}"
  done
}

start_preview_process() {
  cd "${REPO_ROOT}"

  if command -v perl >/dev/null 2>&1; then
    # Start in a new session so VS Code task/terminal shutdown does not kill the preview server.
    perl -MPOSIX -e 'setsid() or die "setsid failed: $!"; exec @ARGV' \
      npm --prefix web run dev -- --hostname "${START_HOST}" --port "${PORT}" \
      >"${LOG_FILE}" 2>&1 < /dev/null &
  else
    nohup npm --prefix web run dev -- --hostname "${START_HOST}" --port "${PORT}" >"${LOG_FILE}" 2>&1 < /dev/null &
  fi

  echo $! > "${PID_FILE}"
}

if is_display_healthy; then
  echo "Preview website already running on ${DISPLAY_URL}"
  echo "Local preview helper only (dev/debug)."
  listener_pid="$(listening_pids | head -n 1)"
  if [[ -n "${listener_pid:-}" ]]; then
    echo "${listener_pid}" > "${PID_FILE}"
  fi
  hold_forever
  exit 0
fi

mkdir -p "${REPO_ROOT}/.tmp"

old_pid="$(read_pid)"
if is_pid_running "${old_pid}"; then
  if is_listening; then
    echo "Restarting unhealthy preview process (pid ${old_pid})..."
    kill "${old_pid}" >/dev/null 2>&1 || true
    for _ in $(seq 1 5); do
      if ! is_pid_running "${old_pid}"; then
        break
      fi
      sleep 1
    done
  else
    echo "Preview process exists (pid ${old_pid}) but port ${PORT} is not ready yet."
  fi
fi

if is_listening && ! is_display_healthy; then
  if is_healthy_on_any_loopback; then
    echo "Port ${PORT} is listening but not reachable on ${DISPLAY_HOST}." >&2
    echo "Set PREVIEW_WEB_DISPLAY_HOST to the host you use in the browser." >&2
    echo "For HostHub launch config use: --dart-define=CMS_PREVIEW_DOMAIN=localhost:${PORT}" >&2
  fi
  echo "Port ${PORT} is in use by another process and preview is unhealthy; restarting it." >&2
  listener_pids="$(listening_pids)"
  if [[ -n "${listener_pids}" ]]; then
    echo "${listener_pids}" | xargs -n1 kill >/dev/null 2>&1 || true
    sleep 1
  fi
fi

echo "Starting website preview server on ${DISPLAY_HOST}:${PORT}..."
echo "Local preview helper only (dev/debug)."
start_preview_process

new_pid="$(read_pid)"
healthy_streak=0
for _ in $(seq 1 "${WAIT_SECONDS}"); do
  if is_display_healthy; then
    healthy_streak=$((healthy_streak + 1))
    if (( healthy_streak >= READY_STREAK_REQUIRED )); then
      if is_listening; then
        listener_pid="$(listening_pids | head -n 1)"
        if [[ -n "${listener_pid:-}" ]]; then
          echo "${listener_pid}" > "${PID_FILE}"
        fi
        echo "Preview website is ready on ${DISPLAY_URL}"
        hold_forever
        exit 0
      fi
    fi
  else
    healthy_streak=0
  fi

  if ! is_listening && [[ -n "${new_pid}" ]] && ! is_pid_running "${new_pid}"; then
    echo "Preview process (pid ${new_pid}) exited before becoming healthy." >&2
    print_debug_context
    exit 1
  fi
  sleep 1
done

echo "Preview website did not become healthy on port ${PORT} within ${WAIT_SECONDS}s." >&2
print_debug_context
exit 1

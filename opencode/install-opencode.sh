#!/usr/bin/env bash
#ddev-generated
set -euo pipefail

PERSIST_BASE="/mnt/ddev-global-cache/opencode/shared"
PERSIST_BIN_DIR="${PERSIST_BASE}/bin"
PERSIST_CONFIG_HOME="${PERSIST_BASE}/config"
PERSIST_APP_CONFIG_DIR="${PERSIST_CONFIG_HOME}/opencode"
PERSIST_DATA_HOME="${PERSIST_BASE}/data"
PERSIST_STATE_HOME="${PERSIST_BASE}/state"
PERSIST_BIN="${PERSIST_BIN_DIR}/opencode"
INSTALLER_URL="https://opencode.ai/install"
DEFAULT_CONFIG_TEMPLATE="/var/www/html/.ddev/opencode/default-opencode.jsonc"
GENERATED_CONFIG="${PERSIST_APP_CONFIG_DIR}/opencode.json"
FRESH_INSTALL=0

mkdir -p \
  "${PERSIST_BIN_DIR}" \
  "${PERSIST_APP_CONFIG_DIR}" \
  "${PERSIST_DATA_HOME}" \
  "${PERSIST_STATE_HOME}"

if [ -f "${DEFAULT_CONFIG_TEMPLATE}" ]; then
  awk 'NR==1 && $0 ~ /^#ddev-generated/ { next } { print }' \
    "${DEFAULT_CONFIG_TEMPLATE}" > "${GENERATED_CONFIG}"
fi

export XDG_CONFIG_HOME="${PERSIST_CONFIG_HOME}"
export XDG_DATA_HOME="${PERSIST_DATA_HOME}"
export XDG_STATE_HOME="${PERSIST_STATE_HOME}"
export OPENCODE_CONFIG="${GENERATED_CONFIG}"
export PATH="${PERSIST_BIN_DIR}:${HOME:-/home}/.opencode/bin:/home/.opencode/bin:${PATH}"

# If a persisted binary exists but is not runnable (wrong arch/libc), reinstall it.
if [ -x "${PERSIST_BIN}" ] && ! "${PERSIST_BIN}" --version >/dev/null 2>&1; then
  echo "Persisted OpenCode binary is not runnable, reinstalling ..."
  rm -f "${PERSIST_BIN}"
fi

if [ ! -x "${PERSIST_BIN}" ]; then
  FRESH_INSTALL=1
  if ! command -v opencode >/dev/null 2>&1; then
    echo "Installing OpenCode ..."
    curl -fsSL "${INSTALLER_URL}" | bash
  fi

  if ! command -v opencode >/dev/null 2>&1; then
    echo "OpenCode installer completed but no opencode binary was found on PATH." >&2
    exit 1
  fi

  cp "$(command -v opencode)" "${PERSIST_BIN}"
  chmod +x "${PERSIST_BIN}"
fi

echo "OpenCode version: $("${PERSIST_BIN}" --version)"

if [ "${FRESH_INSTALL}" -eq 1 ]; then
  exit 0
fi

check_and_upgrade_opencode() {
  local new_version
  local upgrade_status
  local -a run_prefix=()

  echo "Checking OpenCode update..."

  # Use OpenCode's native updater and force the known install method to avoid prompts.
  if command -v timeout >/dev/null 2>&1; then
    run_prefix=(timeout 60s)
  fi

  upgrade_status=0
  "${run_prefix[@]}" "${PERSIST_BIN}" upgrade --method curl </dev/null >/dev/null 2>&1 || upgrade_status=$?

  if [ "$upgrade_status" -eq 0 ]; then
    new_version=$("${PERSIST_BIN}" --version 2>/dev/null) || new_version="unknown"
    echo "✓ OpenCode version: ${new_version}"
    return 0
  fi

  if [ "$upgrade_status" -eq 124 ]; then
    echo "⚠ Warning: OpenCode upgrade check timed out (non-fatal)" >&2
    return 0
  fi

  echo "⚠ Warning: OpenCode upgrade check failed (non-fatal)" >&2
}

check_and_upgrade_opencode

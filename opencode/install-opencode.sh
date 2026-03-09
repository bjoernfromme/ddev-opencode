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
DEFAULT_INSTALLED_BIN="${HOME:-/home}/.opencode/bin/opencode"
INSTALLER_URL="https://opencode.ai/install"
DEFAULT_CONFIG_TEMPLATE="/var/www/html/.ddev/opencode/default-opencode.jsonc"
GENERATED_CONFIG="${PERSIST_APP_CONFIG_DIR}/opencode.json"

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

if [ ! -x "${PERSIST_BIN}" ]; then
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

echo "Installed OpenCode version: $("${PERSIST_BIN}" --version)"

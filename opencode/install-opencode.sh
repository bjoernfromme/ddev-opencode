#!/usr/bin/env bash
#ddev-generated
set -euo pipefail

PERSIST_BASE="/var/www/html/.ddev/.opencode"
PERSIST_BIN_DIR="${PERSIST_BASE}/bin"
PERSIST_CONFIG_HOME="${PERSIST_BASE}/config"
PERSIST_APP_CONFIG_DIR="${PERSIST_CONFIG_HOME}/opencode"
PERSIST_DATA_HOME="${PERSIST_BASE}/data"
PERSIST_STATE_HOME="${PERSIST_BASE}/state"
PERSIST_BIN="${PERSIST_BIN_DIR}/opencode"
DEFAULT_INSTALLED_BIN="${HOME:-/home}/.opencode/bin/opencode"
INSTALLER_URL="https://opencode.ai/install"
DEFAULT_CONFIG_TEMPLATE="/var/www/html/.ddev/opencode/default-opencode.json"
LIVE_CONFIG="${PERSIST_APP_CONFIG_DIR}/opencode.json"

mkdir -p \
  "${PERSIST_BIN_DIR}" \
  "${PERSIST_APP_CONFIG_DIR}" \
  "${PERSIST_DATA_HOME}" \
  "${PERSIST_STATE_HOME}"

if [ ! -f "${LIVE_CONFIG}" ] && [ -f "${DEFAULT_CONFIG_TEMPLATE}" ]; then
  cp "${DEFAULT_CONFIG_TEMPLATE}" "${LIVE_CONFIG}"
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${PERSIST_CONFIG_HOME}}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${PERSIST_DATA_HOME}}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${PERSIST_STATE_HOME}}"
export OPENCODE_CONFIG="${OPENCODE_CONFIG:-${LIVE_CONFIG}}"
export PATH="${PERSIST_BIN_DIR}:${HOME:-/home}/.opencode/bin:/home/.opencode/bin:${PATH}"

if [ ! -x "${PERSIST_BIN}" ]; then
  if [ ! -x "${DEFAULT_INSTALLED_BIN}" ]; then
    echo "Installing OpenCode ..."
    curl -fsSL "${INSTALLER_URL}" | bash
  fi

  if [ ! -x "${DEFAULT_INSTALLED_BIN}" ]; then
    echo "OpenCode installer completed but no binary was found at ${DEFAULT_INSTALLED_BIN}" >&2
    exit 1
  fi

  cp "${DEFAULT_INSTALLED_BIN}" "${PERSIST_BIN}"
  chmod +x "${PERSIST_BIN}"
fi

echo "Installed OpenCode version: $("${PERSIST_BIN}" --version)"

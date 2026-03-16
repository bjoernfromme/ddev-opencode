#!/usr/bin/env bash
#ddev-generated
set -euo pipefail

PERSIST_BASE="/mnt/ddev-global-cache/opencode/shared"
PERSIST_HOME="${PERSIST_BASE}/home"
PERSIST_CONFIG_HOME="${PERSIST_BASE}/config"
PERSIST_APP_CONFIG_DIR="${PERSIST_CONFIG_HOME}/opencode"
PERSIST_DATA_HOME="${PERSIST_BASE}/data"
PERSIST_STATE_HOME="${PERSIST_BASE}/state"
OPENCODE_BIN="${PERSIST_HOME}/.opencode/bin/opencode"
INSTALLER_URL="https://opencode.ai/install"
DEFAULT_CONFIG_TEMPLATE="/var/www/html/.ddev/opencode/default-opencode.jsonc"
GENERATED_CONFIG="${PERSIST_APP_CONFIG_DIR}/opencode.json"
ORIGINAL_HOME="${HOME:?HOME must be set}"

mkdir -p \
  "${PERSIST_HOME}" \
  "${PERSIST_APP_CONFIG_DIR}" \
  "${PERSIST_DATA_HOME}" \
  "${PERSIST_STATE_HOME}"

if [ -f "${DEFAULT_CONFIG_TEMPLATE}" ]; then
  awk 'NR==1 && $0 ~ /^#ddev-generated/ { next } { print }' \
    "${DEFAULT_CONFIG_TEMPLATE}" > "${GENERATED_CONFIG}"
fi

if [ -f "${ORIGINAL_HOME}/.gitignore_global" ]; then
  cp -f "${ORIGINAL_HOME}/.gitignore_global" "${PERSIST_HOME}/.gitignore_global"
fi

export HOME="${PERSIST_HOME}"
export XDG_CONFIG_HOME="${PERSIST_CONFIG_HOME}"
export XDG_DATA_HOME="${PERSIST_DATA_HOME}"
export XDG_STATE_HOME="${PERSIST_STATE_HOME}"
export OPENCODE_CONFIG="${GENERATED_CONFIG}"
export PATH="${HOME}/.opencode/bin:${PATH}"

if command -v git >/dev/null 2>&1; then
  git config --global core.excludesfile "${HOME}/.gitignore_global"
fi

# If a persisted binary exists but is not runnable (wrong arch/libc), reinstall it.
if [ -x "${OPENCODE_BIN}" ] && ! "${OPENCODE_BIN}" --version >/dev/null 2>&1; then
  echo "Persisted OpenCode binary is not runnable, reinstalling ..."
  rm -f "${OPENCODE_BIN}"
fi

if [ ! -x "${OPENCODE_BIN}" ]; then
  echo "Installing OpenCode ..."
  curl -fsSL "${INSTALLER_URL}" | bash -s -- --no-modify-path

  if [ ! -x "${OPENCODE_BIN}" ]; then
    echo "OpenCode installer completed but no opencode binary was found on PATH." >&2
    exit 1
  fi
fi

echo "OpenCode version: $("${OPENCODE_BIN}" --version)"

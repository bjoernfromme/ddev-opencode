# ddev-opencode

`ddev-opencode` is a DDEV add-on that runs OpenCode inside the DDEV `web` container while keeping OpenCode runtime state in DDEV’s persistent global cache.

## What it does

- installs OpenCode after `ddev start`
- exposes `ddev opencode`
- persists the OpenCode binary in a cache-backed path
- persists config, auth, logs, cache, and state outside the project tree
- provides an editable managed default config template at `.ddev/opencode/default-opencode.jsonc`

## Runtime storage

OpenCode runtime state is stored here:

    /mnt/ddev-global-cache/opencode/shared

This gives you one personal OpenCode environment shared across your DDEV projects on the same machine.

## Managed default config template

Edit this file:

    .ddev/opencode/default-opencode.jsonc

On every DDEV start, the installer regenerates (and overwrites) the runtime config from the template here:

    /mnt/ddev-global-cache/opencode/shared/config/opencode/opencode.json

The shipped template is:

    #ddev-generated
    {
      "$schema": "https://opencode.ai/config.json",
      "permission": {
        "bash": "ask",
        "webfetch": "ask",
        "websearch": "ask"
      }
    }

## Install

From a DDEV project root:

    ddev add-on get /path/to/ddev-opencode

Then restart:

    ddev restart

## Usage

    ddev opencode

    ddev opencode run "Summarize this repository"

    ddev opencode --version

## Installed managed files

    .ddev/config.opencode.yaml
    .ddev/commands/web/opencode
    .ddev/opencode/install-opencode.sh
    .ddev/opencode/default-opencode.jsonc

## Runtime storage

    /mnt/ddev-global-cache/opencode/shared

## Notes

- authenticate once for the shared storage location
- auth survives `ddev restart` and `ddev poweroff`
- updates are handled by OpenCode itself when it starts, via its built-in `autoupdate` behavior

## macOS / Linux / WSL2

This version does not depend on host OpenCode paths, so it behaves the same on macOS, Linux, and WSL2 as long as DDEV itself is working normally.

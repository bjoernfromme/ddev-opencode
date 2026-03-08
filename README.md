# ddev-opencode

`ddev-opencode` is a DDEV add-on that runs OpenCode inside the DDEV `web` container while keeping all OpenCode runtime state local to each project.

## What it does

- installs OpenCode after `ddev start`
- exposes `ddev opencode`
- persists the OpenCode binary in `.ddev/.opencode/bin/opencode`
- persists config in `.ddev/.opencode/config/opencode/`
- persists auth, logs, cache, and runtime data in `.ddev/.opencode/data`
- persists state in `.ddev/.opencode/state`
- provides an editable managed default config template at `.ddev/opencode/default-opencode.jsonc`

## Managed default config template

Edit this file:

    .ddev/opencode/default-opencode.jsonc

It is a DDEV-managed template file and includes a `#ddev-generated` marker on the first line so `ddev add-on remove` can clean it up with the rest of the add-on-managed files.

On every DDEV start, the installer regenerates the runtime config file here:

    .ddev/.opencode/config/opencode/opencode.json

The first line is stripped during generation so the runtime file becomes valid JSON for OpenCode.

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

## Important behavior

Because the runtime config is regenerated from the managed template on every start:

- edit `.ddev/opencode/default-opencode.jsonc` if you want persistent default changes
- do not edit `.ddev/.opencode/config/opencode/opencode.json` directly, because it will be replaced on the next start

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
    .ddev/docker-compose.opencode.yaml
    .ddev/commands/web/opencode
    .ddev/opencode/install-opencode.sh
    .ddev/opencode/default-opencode.jsonc

## Persistent runtime files

    .ddev/.opencode/

## Notes

- authenticate once per project
- auth survives `ddev restart`
- theme and model selections should survive because config, data, and state are stored in `.ddev/.opencode/`
- the binary survives `ddev restart` because the wrapper uses the copied persistent binary in `.ddev/.opencode/bin/`
- updates are handled by OpenCode itself when it starts, via its built-in `autoupdate` behavior
- ignore rules for `.ddev/.opencode/` and `.ddev/opencode/` should be handled in your project's own `.gitignore`

## macOS / Linux / WSL2

This version does not depend on host OpenCode paths, so it behaves the same on macOS, Linux, and WSL2 as long as DDEV itself is working normally.

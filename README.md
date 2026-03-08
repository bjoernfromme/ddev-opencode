# ddev-opencode

`ddev-opencode` is a DDEV add-on that runs OpenCode inside the DDEV `web` container while keeping all OpenCode runtime state local to each project.

## What it does

- installs OpenCode after `ddev start`
- exposes `ddev opencode`
- persists the OpenCode binary in `.ddev/.opencode/bin/opencode`
- persists config in `.ddev/.opencode/config/opencode/`
- persists auth, logs, cache, and runtime data in `.ddev/.opencode/data`
- persists state in `.ddev/.opencode/state`
- provides an editable default config template at `.ddev/opencode/default-opencode.json`

## Why this layout

This add-on is fully project-local.

It does not mount host OpenCode config or data into the container. That means:

- no dependency on host OpenCode state
- authentication happens once per project
- theme, model, and other config changes persist per project
- host files outside the DDEV project are not exposed by this add-on

## Editable default config

Before first run, you can edit:

```text
.ddev/opencode/default-opencode.json
```

On first startup, the installer copies that file to:

```text
.ddev/.opencode/config/opencode/opencode.json
```

but only if the live config does not already exist.

The shipped default template is:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": "ask",
    "webfetch": "ask",
    "websearch": "ask"
  }
}
```

If you later want to re-seed from the template, delete the live config file and restart DDEV.

## Install

From a DDEV project root:

```sh
ddev add-on get /path/to/ddev-opencode
```

Then restart:

```sh
ddev restart
```

## Usage

Start OpenCode:

```sh
ddev opencode
```

Run a one-shot prompt:

```sh
ddev opencode run "Summarize this repository"
```

Show version:

```sh
ddev opencode --version
```

## Installed managed files

After installation, these add-on-managed files are placed in `.ddev/`:

```text
.ddev/config.opencode.yaml
.ddev/docker-compose.opencode.yaml
.ddev/commands/web/opencode
.ddev/opencode/install-opencode.sh
.ddev/opencode/default-opencode.json
```

Persistent OpenCode runtime state lives here:

```text
.ddev/.opencode/
```

## Persistence behavior

- authenticate once per project
- auth survives `ddev restart`
- theme and model selections should survive because config, data, and state are stored in `.ddev/.opencode/`
- the binary survives `ddev restart` because the wrapper uses the copied persistent binary in `.ddev/.opencode/bin/`
- updates are handled by OpenCode itself when it starts, via its built-in `autoupdate` behavior

## Notes

- the add-on intentionally separates managed files from runtime state
- `.ddev/opencode/` contains add-on code and editable defaults
- `.ddev/.opencode/` contains runtime state and the persisted binary
- the install script installs only when needed and does not add a separate update timer
- ignore rules for `.ddev/.opencode/` and `.ddev/opencode/` should be handled in your project's own `.gitignore`

## macOS / Linux / WSL2

This version does not depend on host OpenCode paths, so it behaves the same on macOS, Linux, and WSL2 as long as DDEV itself is working normally.

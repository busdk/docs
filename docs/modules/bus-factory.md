---
title: bus-factory
description: Local development assistant UI for BusDK modules.
---

## `bus-factory` - module development assistant

### Synopsis

`bus factory [global flags] [serve] [--root <dir>] [--listen <addr>] [--port <n>] [--token <value>] [--enable-ai=<true|false>] [--webview|--print-url]`

`bus-factory [serve] [--root <dir>] [--listen <addr>] [--port <n>] [--token <value>] [--enable-ai=<true|false>] [--webview|--print-url]`

### Overview

`bus-factory` serves a local token-gated web UI intended for software development workflows in BusDK module repositories.

Initial features:

- read-only list of exported Go units
- toggleable AI assistant panel using the same shared `bus-ui` AI panel renderer (`RenderAIPanel`) used by `bus-ledger`
- shared `bus-ui` root shell layout and shared `bus-ui` light/dark theme tokens with automatic OS theme detection
- shared `bus-ui` panel/button/AI classes so AI visuals (icons, typography, panel layout) match `bus-ledger`
- superproject module-first view: if root contains `bus` / `bus-*` modules,
  modules are listed first and unit listing is loaded per selected module
- default action integration from `.bus/dev` and `.bus/run`

### Commands

`serve` starts a local HTTP server. By default it opens the capability URL in local browser/webview and prints the URL to stderr. Use `--print-url` to disable auto-open and print URL to stdout.

Global flags:

- `-h`, `--help`
- `-V`, `--version`
- `-v`, `--verbose` (`-vv` enables debug logs)
- `-q`, `--quiet` (suppresses non-error logs/output)
- `-C`, `--chdir <dir>`
- `-o`, `--output <file>`
- `-f`, `--format text`
- `--color <auto|always|never>` / `--no-color`

Defaults:

- `--root .`
- `--listen 127.0.0.1`
- `--port 0` (ephemeral)
- `--token` auto-generated when omitted
- `--enable-ai=true`
- `--webview=true`
- `--print-url=false`

### APIs

Under `/{token}/`:

- `GET v1/modules` returns detected BusDK modules under root
- `GET v1/public-units` returns exported Go declarations from workspace root
  or from selected module (`?module=<name>`)
- `GET v1/actions` returns user-defined actions from `.bus/dev` and `.bus/run`
- `POST v1/actions/run` runs non-prompt actions via `bus dev <action>` or
  `bus run <action>`
- `GET v1/ai/status` returns AI panel enable status
- `POST v1/client-log` forwards browser UI logs to server logs

Prompt action behavior:

- `.txt` actions are routed to AI input (prefill + open AI panel)
- Prompt actions are not executed via `bus dev` / `bus run`

### Exit behavior

- `0` success
- `2` invalid usage
- `1` runtime failure

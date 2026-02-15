---
title: bus sheets — local spreadsheet-like web UI for workspaces
description: "Local web UI for BusDK workspaces: multi-tab workbook over CSV resources, view and edit rows and schemas, run validation; delegates to bus-api in-process."
---

## `bus-sheets` — local spreadsheet-like web UI for BusDK workspaces

### Synopsis

`bus sheets [global flags] [serve | version]`  
`bus-sheets [global flags] [serve | version]`

With no subcommand, `bus sheets` runs **serve**. Global flags follow [CLI command naming](../cli/command-naming) and the [standard global flags](../cli/global-flags). The workspace root is set with `-C` / `--chdir` and is used as the workbook context.

Serve (default):

`bus-sheets serve [--listen <addr>] [--port <n>] [--token <string>] [--token-bytes <n>] [--tls-cert <file>] [--tls-key <file>] [--read-only] [--enable-agent] [global flags]`

`bus-sheets version` — Print the tool name and version to stdout and exit 0.

### Description

Command names follow [CLI command naming](../cli/command-naming). Bus Sheets provides a local web UI that presents your BusDK workspace as a multi-tab workbook: each workspace resource (a CSV file with its beside-the-table Table Schema) appears as a sheet tab, and you can view and edit rows, inspect and edit schemas, and run validation from the browser. The UI delegates all data and schema semantics to the [bus-api](./bus-api) core embedded in-process; no Bus module CLI is executed for grid or schema operations. Intended users are system administrators and power users who want a familiar spreadsheet experience over workspace datasets without installing a separate runtime.

When you start the server, it prints a **capability URL** to stdout. That URL includes an unguessable path token; you must open the full URL in a browser to use the UI. Requests that do not include the token path return 404. By default the server binds only to `127.0.0.1`, so the UI is reachable only from the local machine. The binary embeds everything needed to serve the UI (HTML, CSS, JavaScript); no extra template files or build directories are required after installation.

The workbook shows resources in the same order as the API (from `datapackage.json` when present, otherwise from beside-the-table schema discovery). Column order follows the Table Schema; cells show typed values and, for formula-enabled fields, computed values. Row add, update, and delete respect schema constraints and BusDK mutation policies (`busdk.update_policy`, `busdk.delete_policy`). Schema view and mechanical schema edits (field add/remove/rename, key operations) call the embedded API; destructive changes are refused unless explicitly forced per [bus-data](./bus-data) semantics. Validation actions run against the current resource or the full workspace and display deterministic diagnostics. Formula source can be shown alongside computed values via an opt-in toggle when the API supports it.

Optionally you can enable an **agent chat** (IDE-style). When started with `--enable-agent`, the UI exposes a chat panel that you can hide or show at runtime. In the chat you can ask an AI agent to perform operations; the agent runs with the workspace as its working directory and can run Bus CLI tools, so you can request data changes, validation, or other Bus commands and then refresh the sheet view to see results. Agent integration is disabled by default and can be turned on only at startup; see [Serve flags](#serve-flags) and [Agent chat](#agent-chat-when-enabled). The [bus-sheets SDD](../sdd/bus-sheets) defines the full design, security model, and integration with [bus-api](../sdd/bus-api) and [bus-agent](../sdd/bus-agent).

### Commands

**`serve`** (default) — Start the local HTTP server that serves the Bus Sheets web UI. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and prints the capability base URL to **stdout**. All diagnostics go to **stderr**. Open the printed URL in a browser to use the workbook; there is no separate login. The server does not mutate workspace data until you perform an edit or mutation in the UI (or until the agent performs an action when agent is enabled). If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

These flags apply only to `serve`. They can appear in any order before or after the subcommand name.

- **`--listen <addr>`** — Bind address. Default `127.0.0.1`. The server listens only on this address; use a non-loopback address only when you intend the UI to be reachable from other hosts.
- **`--port <n>`** — Port number. Default `0` (choose a free port). The printed capability URL includes the actual port in use.
- **`--token <string>`** — Use this token instead of generating one. Useful for scripts or tests that need a stable URL. If omitted, a random token is generated.
- **`--token-bytes <n>`** — Length of the generated token in bytes when `--token` is not set. Default `32`.
- **`--tls-cert <file>`** — Path to the TLS certificate file. When provided together with `--tls-key`, the server serves HTTPS instead of HTTP.
- **`--tls-key <file>`** — Path to the TLS private key file. When provided together with `--tls-cert`, the server serves HTTPS.
- **`--read-only`** — Disable all mutating operations in the UI. When set, create/update/delete and schema mutation requests return 403. Reads and validation remain available.
- **`--enable-agent`** — Enable the optional agent chat integration. When set, the UI shows a chat panel (which you can hide or show at runtime) and the agent can run Bus CLI tools in the workspace. Default: disabled. When disabled, the chat is not available and no agent endpoints are exposed.

### Global flags

These flags apply to all subcommands and match the [standard global flags](../cli/global-flags). They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective workspace root. All dataset and schema paths are resolved relative to this directory. The server treats this as the filesystem boundary. If the directory does not exist or is not accessible, the command exits with code 1.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. For `serve`, the capability URL is still printed to stdout unless you redirect it. Errors and diagnostics still go to stderr.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.

Command results (capability URL, version) are written to stdout when produced. Diagnostics and logs are written to stderr.

### Using the workbook

After starting the server with `bus sheets serve` (or `bus-sheets serve`), open the capability URL printed to stdout in your browser. The UI shows a tab for each workspace resource; tab order matches the API. Select a tab to load that resource’s schema and rows. Column headers follow the Table Schema field order; cells show typed values and formula-projected computed values where applicable. You can edit cells (subject to schema and mutation policy), add rows, and delete rows; the UI calls the embedded API and surfaces validation and policy errors. Primary key fields are treated as row identity and are typically not editable. Use the schema panel to inspect or mechanically edit the schema (field add/remove/rename, key operations); destructive changes are refused unless explicitly forced. Use “Validate sheet” or “Validate workbook” to run validation and see diagnostics grouped by resource and row. To see formula source for formula-enabled fields, use the formula-source toggle when the API supports it. After the agent (when enabled) performs mutating operations, refresh the sheet view to see updated data.

### Agent chat (when enabled)

When you start the server with `--enable-agent`, the UI exposes an optional chat panel, similar to IDE AI integrations. You can hide or show this panel at runtime without restarting the server. In the chat you can ask the AI agent to perform operations; the agent runs with the workspace as its working directory and can run Bus CLI tools (e.g. add rows, validate, run module commands). After the agent completes mutating operations, refresh the sheet view to see the changes. Agent runtimes (e.g. Cursor CLI, Codex, Gemini CLI, Claude CLI) are configured or detected per [bus-agent](../sdd/bus-agent); bus-sheets only exposes the chat UI and delegates execution to the bus-agent library. When agent integration is disabled (default), the chat is not shown and no agent endpoints are available.

### Security and binding

By default the server binds only to `127.0.0.1` and is reachable from the local machine. To listen on a non-loopback interface you must set `--listen` explicitly. The random token in the capability URL is a bearer capability: anyone who has the full URL can access the UI and the embedded API. The server does not implement user accounts, sessions, or stored credentials. All filesystem paths are confined to the workspace root. When you supply `--tls-cert` and `--tls-key`, the server serves HTTPS on the same address and port; otherwise it serves HTTP.

### Exit status and errors

- **0** — Success. For `serve`, the server is running until interrupted; for `version`, the command completed and wrote result to stdout (or `--output`).
- **1** — Execution failure: workspace root not readable or not accessible, or TLS files missing or invalid when HTTPS is requested.
- **2** — Invalid usage: unknown subcommand, invalid flag value (e.g. invalid `--listen` or `--port`), or conflicting flags (e.g. `--quiet` and `--verbose`).

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Development state

**Value promise:** Local spreadsheet-like web UI over BusDK workspaces so users can view and edit CSV resources and run validation in the browser without running module CLIs for grid operations.

**Use cases:** [Workbook and validated tabular editing](../workflow/workbook-and-validated-tabular-editing).

**Completeness:** 20% (Basic structure) — only serve and capability URL verified by e2e; workbook, grid, and API embed not yet test-backed.

**Use case readiness:** Workbook and validated tabular editing: 20% — serve and capability URL verified by e2e; grid, schema panel, validation UI not test-backed.

**Current:** E2e script `tests/e2e_bus_sheets.sh` proves help, version, global flags (color, quiet, chdir, output), invalid usage (unknown subcommand, invalid color, quiet+verbose), and that serve prints the expected capability URL with a fixed token and port. Unit tests in `internal/cli/flags_test.go` and `internal/serve/serve_test.go` cover flags and run. No test covers embedded API, workbook tabs, or grid CRUD.

**Planned next:** Embed [bus-api](./bus-api) in-process; embed UI assets; workbook tabs; grid row CRUD and schema panel; validation UI; optional agent chat; read-only mode; integration tests.

**Blockers:** [bus-api](./bus-api) embed and UI assets required before the main user value (grid over workspace) is real.

**Depends on:** [bus-api](./bus-api) (and transitively [bus-data](./bus-data)).

**Used by:** End users as the spreadsheet UI; no other bus module invokes it.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api">bus-api</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-sheets](../sdd/bus-sheets)
- [bus-api CLI reference](./bus-api)
- [bus-data CLI reference](./bus-data)
- [bus-agent SDD](../sdd/bus-agent)
- [Standard global flags](../cli/global-flags)

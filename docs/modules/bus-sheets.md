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

Command names follow [CLI command naming](../cli/command-naming).

Bus Sheets provides a local web UI over BusDK workspace resources.
It presents datasets as sheet tabs, with row editing, schema operations, and validation actions.

Data and schema semantics are delegated in-process to [bus-api](./bus-api).
No separate module CLI is executed for grid/schema operations.

On startup, server prints a capability URL to stdout.
The URL includes an unguessable token path; requests outside token path return `404`.
Default bind is `127.0.0.1`, so UI is local-only unless you change `--listen`.

Optional agent chat is enabled only with `--enable-agent`.
When enabled, you can run agent-assisted workspace commands from the UI.
For full design/security details, see [Module SDD: bus-sheets](../sdd/bus-sheets).

### Commands

**`serve`** (default) — Start the local HTTP server that serves the Bus Sheets web UI. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and prints the capability base URL to **stdout**. All diagnostics go to **stderr**. Open the printed URL in a browser to use the workbook; there is no separate login. The server does not mutate workspace data until you perform an edit or mutation in the UI (or until the agent performs an action when agent is enabled). If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

Serve-specific flags are `--listen <addr>` (default `127.0.0.1`), `--port <n>` (default `0`, auto-choose), `--token <string>`, `--token-bytes <n>`, `--tls-cert <file>` with `--tls-key <file>` for HTTPS, `--read-only` to disable mutating operations, and `--enable-agent` to expose the optional chat panel.

### Global flags

Standard global flags are supported; see [Standard global flags](../cli/global-flags).
`--quiet` and `--verbose` are mutually exclusive.
Diagnostics/logs are written to stderr.

### Using the workbook

After `bus sheets serve`, open the capability URL from stdout.
Tabs map to workspace resources in API order.
You can view/edit rows, inspect schema, and run sheet/workbook validation.
Edits follow schema constraints and mutation policies.

If agent chat is enabled and performs changes, refresh sheet view to load latest data.

### Agent chat (when enabled)

With `--enable-agent`, UI exposes optional chat panel.
Agent runs with workspace as working directory and can execute Bus CLI commands.
When disabled (default), no chat panel or agent endpoints are available.

### Security and binding

Default binding is `127.0.0.1` (local machine only).
Use non-loopback `--listen` only when remote access is intended.
Capability URL token works as bearer capability.

The server has no user/session authentication layer.
Filesystem access is confined to workspace root.
With `--tls-cert` + `--tls-key`, server uses HTTPS.

### Exit status and errors

Exit code `0` means success. For `serve`, success means the server is running until interrupted; for `version`, success means the command wrote version output to stdout (or `--output`).

Exit code `1` means execution failure, such as unreadable workspace root or missing/invalid TLS files when HTTPS is requested. Exit code `2` means invalid usage, such as unknown subcommand, invalid flag values (for example `--listen` or `--port`), or conflicting flags like `--quiet` with `--verbose`.

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Examples

```bash
bus sheets serve --port 8091 --token-bytes 32
bus sheets serve --read-only --port 8091
bus sheets -C ./workspace serve --enable-agent --port 8092
bus sheets version
```


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus sheets serve --read-only --port 8091
sheets serve --read-only --port 8091

# same as: bus sheets serve --enable-agent --port 8092
sheets serve --enable-agent --port 8092
```


### Development state

**Value promise:** Local spreadsheet-like web UI over BusDK workspaces so users can view and edit CSV resources and run validation in the browser without running module CLIs for grid operations.

**Use cases:** [Workbook and validated tabular editing](../workflow/workbook-and-validated-tabular-editing).

**Completeness:** 20% (Basic structure) — serve and capability URL verified by e2e; token gating by unit tests; no workbook journey step is test-verified or completable.

**Use case readiness:** Workbook and validated tabular editing: 20% — serve and capability URL verified by e2e; token gating (404 outside token, 200 under token) in unit tests; grid, schema panel, validation UI not test-backed; no workbook journey step completable.

**Current:** Serve flow, capability URL behavior, token gating, and global-flag handling are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-sheets](../sdd/bus-sheets).

**Planned next:** Embed [bus-api](./bus-api) in-process and mount under `/{token}/v1/`; embed UI assets; workbook tabs; grid row CRUD and schema panel; validation UI. Advances [Workbook and validated tabular editing](../workflow/workbook-and-validated-tabular-editing).

**Blockers:** [bus-api](./bus-api) embed and UI assets required before grid over workspace is real.

**Depends on:** [bus-api](./bus-api) (and transitively [bus-data](./bus-data)).

**Used by:** End users as the spreadsheet UI; no other bus module invokes it.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api">bus-api</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-books">bus-books</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-sheets](../sdd/bus-sheets)
- [bus-api CLI reference](./bus-api)
- [bus-data CLI reference](./bus-data)
- [bus-agent SDD](../sdd/bus-agent)
- [Standard global flags](../cli/global-flags)

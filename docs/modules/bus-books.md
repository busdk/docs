---
title: bus books — local bookkeeping web UI for end users
description: "Local web UI for BusDK bookkeeping: dashboard, Inbox, Journal, Periods, VAT, Bank, Attachments, validation; embeds Bus API and domain module backends."
---

## `bus-books` — local bookkeeping web UI for end users

### Synopsis

`bus books [global flags] [serve | version]`  
`bus-books [global flags] [serve | version]`

With no subcommand, `bus books` runs **serve**. Global flags follow [CLI command naming](../cli/command-naming) and the [standard global flags](../cli/global-flags). The workspace root is set with `-C` / `--chdir` and is used as the bookkeeping context.

Serve (default):

`bus-books serve [--listen <addr>] [--port <n>] [--token <string>] [--token-bytes <n>] [--tls-cert <file>] [--tls-key <file>] [--read-only] [--webview] [--print-url] [--enable-agent] [global flags]`

`bus-books version` — Print the tool name and version to stdout and exit 0.

### Description

Command names follow [CLI command naming](../cli/command-naming). Bus Books provides a local web UI for doing bookkeeping work in a BusDK workspace. It focuses on accounting screens and workflows: dashboard, Inbox (items needing action), Journal (view and post), Periods (open/close/lock), VAT (compute and review), Bank (import and list), optional Reconcile, Attachments (evidence), and Validate. The UI does not implement accounting logic itself; all domain behavior is delegated to existing BusDK modules through the [bus-api](./bus-api) core embedded in-process. No `bus-*` CLI is executed for normal UI operations. Intended users are people who do day-to-day bookkeeping and want a browser-based interface over the same workspace data as the [accounting workflow](../workflow/accounting-workflow-overview), without learning the CLI. For a generic spreadsheet over workspace resources, use [bus sheets](./bus-sheets) instead.

When you start the server, it opens the **capability URL** in a local GUI webview by default. The capability URL includes an unguessable path token. Use `--print-url` to print that URL to stdout for scripting or manual open flows. Requests that do not include the token path return 404. By default the server binds only to `127.0.0.1`, so the UI is reachable only from the local machine. The binary embeds everything needed to serve the UI (HTML, CSS, JavaScript); no extra template files or build directories are required after installation.

Screens that depend on a module backend (e.g. Journal, Periods, VAT, Bank) are shown when that backend is enabled in the embedded API and hidden or marked unavailable otherwise. All reads and writes go through the embedded API and module libraries, so workspace data stays consistent with CLI-driven workflows.

Optionally you can enable an **agent chat** (IDE-style). When started with `--enable-agent`, the UI exposes a chat panel that you can hide or show at runtime. In the chat you can ask an AI agent to perform operations; the agent runs with the workspace as its working directory and can run Bus CLI tools. Agent integration is disabled by default and can be turned on only at startup; see [Serve flags](#serve-flags) and [Agent chat](#agent-chat-when-enabled). The [bus-books SDD](../sdd/bus-books) defines the full design, security model, and integration with [bus-api](../sdd/bus-api) and domain modules.

### Commands

**`serve`** (default) — Start the local HTTP server that serves the Bus Books web UI. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and opens the capability URL in a local GUI webview by default. Use `--print-url` to print the capability base URL to **stdout** instead. All diagnostics go to **stderr**. The server does not mutate workspace data until you perform an action in the UI (or until the agent performs an action when agent is enabled). If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

These flags apply only to `serve`. They can appear in any order before or after the subcommand name.

- **`--listen <addr>`** — Bind address. Default `127.0.0.1`. The server listens only on this address; use a non-loopback address only when you intend the UI to be reachable from other hosts.
- **`--port <n>`** — Port number. Default `0` (choose a free port). The capability URL uses the actual port in use.
- **`--token <string>`** — Use this token instead of generating one. Useful for scripts or tests that need a stable URL. If omitted, a random token is generated.
- **`--token-bytes <n>`** — Length of the generated token in bytes when `--token` is not set. Default `32`.
- **`--tls-cert <file>`** — Path to the TLS certificate file. When provided together with `--tls-key`, the server serves HTTPS instead of HTTP.
- **`--tls-key <file>`** — Path to the TLS private key file. When provided together with `--tls-cert`, the server serves HTTPS.
- **`--read-only`** — Disable all mutating operations in the UI. When set, create/update/delete and other mutating requests return 403 via the embedded API. Reads and validation remain available.
- **`--webview`** — Open the capability URL in a local GUI window using the host opener (`open` on macOS, `xdg-open` on Linux, `rundll32` on Windows). This is best-effort and is the default behavior for `serve`.
- **`--print-url`** — Print the capability URL to stdout instead of auto-opening the GUI webview. Use this for scripts, tests, and manual browser flows.
- **`--enable-agent`** — Enable the optional agent chat integration. When set, the UI shows a chat panel (which you can hide or show at runtime) and the agent can run Bus CLI tools in the workspace. Default: disabled. When disabled, the chat is not available and no agent endpoints are exposed.

### Global flags

These flags apply to all subcommands and match the [standard global flags](../cli/global-flags). They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective workspace root. All dataset and schema paths are resolved relative to this directory. The server treats this as the filesystem boundary. If the directory does not exist or is not accessible, the command exits with code 1.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. For `serve`, this applies when `--print-url` is used. Errors and diagnostics still go to stderr.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.

Command results (version, and capability URL when `--print-url` is used) are written to stdout when produced. Diagnostics and logs are written to stderr.

### Using the bookkeeping UI

After starting the server with `bus books serve` (or `bus-books serve`), the app opens in a local GUI webview by default. If you start with `--print-url`, open the printed capability URL in your browser.

**Dashboard** — Shows workspace identity, current period state, validation status summary, and shortcuts to Inbox and core workflows. The dashboard presents read-only workflows first, then writable operations.

**Inbox** — Merged list of items needing bookkeeping attention (e.g. invoices and bank transactions when those modules are enabled). You can filter by review state and evidence completeness and open an item for detail. Triage and review actions are available when the underlying object supports them.

**Journal** — List and inspect transactions; create a new balanced transaction through the journal backend. Postings into closed or locked periods are rejected with deterministic errors.

**Periods** — List periods and their states; open, close, and lock periods through the period backend. The UI shows why an action is refused when preconditions or validation fail.

**VAT** — Select a VAT reporting period, run VAT calculation via the VAT/reporting backends, and view totals and diagnostics.

**Bank** — Trigger import and browse imported bank transactions; view reconciliation and evidence status where supported.

**Reconcile** — When reconciliation backends are enabled, view suggested matches and confirm links; diagnostics are shown for refused matches.

**Attachments** — List evidence items, add evidence (upload or reference), and link evidence to bookkeeping objects. Evidence completeness is visible in item views and the Inbox.

**Validate** — Run full workspace validation and see deterministic diagnostics grouped by resource or object.

Views that depend on a module backend are hidden or shown as unavailable when that backend is not enabled. The capability response `GET /v1/modules` includes `readOnly` and `enableAgent`, which the UI uses to show mode status and capability-aware workflow guidance. When you change data through the UI, relevant lists may refresh automatically for changes that go through the embedded API; changes made outside the API (e.g. by the agent or external edits) may require a manual refresh.

Control semantics in the UI follow the SDD graphics policy:
- controls that are permanently unavailable in the current session are removed from the UI (not shown disabled),
- controls that may become available after user changes in the current form remain visible but disabled,
- read-only values remain visible by default.

### Agent chat (when enabled)

When you start the server with `--enable-agent`, the UI exposes an optional chat panel. You can hide or show this panel at runtime without restarting the server. In the chat you can ask the AI agent to perform operations; the agent runs with the workspace as its working directory and can run Bus CLI tools. The UI presents the agent as a privileged tool that can run commands in the workspace and encourages a “propose then apply” flow (agent suggests changes; you confirm). Agent runtimes are configured or detected per [bus-agent](../sdd/bus-agent); bus-books only exposes the chat UI and delegates execution to the bus-agent library. When agent integration is disabled (default), the chat is not shown and no agent endpoints are available.

### Security and binding

By default the server binds only to `127.0.0.1` and is reachable from the local machine. To listen on a non-loopback interface you must set `--listen` explicitly. The random token in the capability URL is a bearer capability: anyone who has the full URL can access the UI and the embedded API. The server does not implement user accounts, sessions, or stored credentials. All filesystem paths are confined to the workspace root. When you supply `--tls-cert` and `--tls-key`, the server serves HTTPS on the same address and port; otherwise it serves HTTP.

### Exit status and errors

- **0** — Success. For `serve`, the server is running until interrupted; for `version`, the command completed and wrote result to stdout (or `--output`).
- **1** — Execution failure: workspace root not readable or not accessible, or TLS files missing or invalid when HTTPS is requested.
- **2** — Invalid usage: unknown subcommand, invalid flag value (e.g. invalid `--listen` or `--port`), or conflicting flags (e.g. `--quiet` and `--verbose`).

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Examples

```bash
bus books serve --port 8090 --token-bytes 32
bus books version
```

### Development state

**Value promise:** Local bookkeeping web UI over BusDK workspaces so end users can perform accounting tasks (journal, periods, VAT, bank, invoices, attachments, validation) in a browser without using the CLI.

**Use cases:** [Accounting workflow overview](../workflow/accounting-workflow-overview).

**Completeness:** 100% — The bus-books Definition of Done is met: a fully functioning UI for Bus modules through embedded bus-api with deterministic CLI/API behavior, capability routing, read-only gating, and headless browser E2E coverage.

**Use case readiness:** Accounting workflow (bookkeeping UI): 100% — Users can complete the documented bookkeeping workflow in the UI with deterministic diagnostics and module-backed operations across all required screens.

**Current:** Serve with default GUI webview launch and optional `--print-url`, default subcommand, token gating, workspace checks, read-only mode, embedded API, schema endpoints, SSE mutation events, module backend routing, and screen flows are test-covered by `tests/e2e_bus_books.sh` and `internal/*/*_test.go`. Inbox supports filters (`reviewState`, `evidenceOk`) and item actions; Journal supports list/detail/new with deterministic period-state errors; Periods supports open/close/lock transitions; VAT supports period list/report run plus source links to underlying transactions when provided by the backend; Bank supports import/list/detail; Reconcile supports suggestions and confirm with deterministic refusals; Attachments supports add/list/link; Validate supports grouped deterministic diagnostics. List views (Inbox, Journal, Bank) now support deterministic `limit`/`offset` slicing, and the UI exposes row-limit selectors to keep large lists responsive. The main view now uses full-width section backgrounds with constrained inner content, aligned to the documentation layout contract.

**Planned next:** Ongoing maintenance and incremental UX polish; no open functional gaps against the current bus-books SDD/CLI requirements.

**Blockers:** None known.

**Depends on:** [bus-api](./bus-api) (embedded); domain modules ([journal](./bus-journal), [period](./bus-period), [vat](./bus-vat), [bank](./bus-bank), [invoices](./bus-invoices), [attachments](./bus-attachments), [reconcile](./bus-reconcile), [validate](./bus-validate)) via their module backend handlers.

**Used by:** End users as the bookkeeping UI; no other bus module invokes it.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-sheets">bus-sheets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-books](../sdd/bus-books)
- [bus-api CLI reference](./bus-api)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [bus-sheets CLI reference](./bus-sheets)
- [bus-agent SDD](../sdd/bus-agent)
- [Standard global flags](../cli/global-flags)

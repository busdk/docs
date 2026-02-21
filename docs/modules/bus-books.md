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

`bus-books serve [--listen <addr>] [--port <n>] [--token <string>] [--token-bytes <n>] [--open-view <route>] [--view-only] [--view-param <key=value>]... [--tls-cert <file>] [--tls-key <file>] [--read-only] [--webview] [--print-url] [--enable-agent] [global flags]`

`bus-books version` — Print the tool name and version to stdout and exit 0.

### Description

Command names follow [CLI command naming](../cli/command-naming). Bus Books provides a local web UI for bookkeeping in a BusDK workspace.

It focuses on accounting workflows: Dashboard, Inbox, Journal, Periods, VAT, Bank, optional Reconcile, Attachments, and Validate.

The UI does not implement accounting logic itself. Domain behavior is delegated to BusDK modules through embedded [bus-api](./bus-api) handlers.

No `bus-*` CLI is executed for normal UI actions.

Intended users are day-to-day bookkeepers who want a browser UI over the same workspace data as the [accounting workflow](../workflow/accounting-workflow-overview). For generic spreadsheet-style editing, use [bus sheets](./bus-sheets).

When the server starts, it opens the **capability URL** in a local GUI webview by default.

The capability URL includes an unguessable token path. Use `--print-url` to print this URL to stdout for scripts or manual browser flows.

Requests outside the token path return 404.

By default, the server binds only to `127.0.0.1`, so the UI is local-only.

The binary embeds all UI assets (HTML/CSS/JS); no extra template files or build directories are required after installation.

Screens that depend on a module backend (e.g. Journal, Periods, VAT, Bank) are shown when that backend is enabled in the embedded API and hidden or marked unavailable otherwise. All reads and writes go through the embedded API and module libraries, so workspace data stays consistent with CLI-driven workflows.

You can optionally enable **agent chat** (IDE-style).

With `--enable-agent`, the UI exposes a chat panel you can hide/show at runtime. The agent runs with workspace working directory and can run Bus CLI tools.

Agent integration is disabled by default and can be enabled only at startup.

See [Serve flags](#serve-flags), [Agent chat](#agent-chat-when-enabled), and [bus-books SDD](../sdd/bus-books) for full behavior and security model.

Finland-focused UI requirements are documented as split topic pages in [Finnish WebView bookkeeping UI requirements](../implementation/fi-webview-accounting-ui-requirements), with dedicated pages for IA/navigation, table-first UX, compliance and audit UX, and accessibility/performance.

### Commands

**`serve`** (default) — Start the local HTTP server that serves the Bus Books web UI. The effective workspace root is the current directory or the directory given by `-C` / `--chdir`. The server generates an unguessable token (unless you pass `--token`), binds to the address and port given by `--listen` and `--port`, and opens the capability URL in a local GUI webview by default. Use `--print-url` to print the capability base URL to **stdout** instead. All diagnostics go to **stderr**. The server does not mutate workspace data until you perform an action in the UI (or until the agent performs an action when agent is enabled). If the workspace root is not readable, startup fails with a deterministic diagnostic and a non-zero exit code.

**`version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored when version is requested.

### Serve flags

Serve flags can appear before or after the subcommand. `--listen` and `--port` control bind address and port, `--token` and `--token-bytes` control capability token behavior, and `--tls-cert` with `--tls-key` enables HTTPS. For launch behavior, use `--webview` (default), `--print-url`, `--open-view`, `--view-only`, and repeatable `--view-param <key=value>`. For access control, `--read-only` blocks mutating requests and `--enable-agent` enables the optional chat panel.

### Global flags

Standard global flags are supported; see [Standard global flags](../cli/global-flags). In this module, the most common are `-C/--chdir` for workspace selection, `-o/--output` with `--print-url` for scripted startup flows, and `-q/-v` for output control. `--quiet` and `--verbose` are mutually exclusive (usage error `2`). Normal results go to stdout (or `--output`), while diagnostics/logs go to stderr.

### Using the bookkeeping UI

After starting the server with `bus books serve` (or `bus-books serve`), the app opens in a local GUI webview by default. If you start with `--print-url`, open the printed capability URL in your browser.

The Dashboard shows workspace identity, current period state, validation summary, and shortcuts to core workflows. Inbox merges items that need attention (for example invoices and bank transactions), with filters for review/evidence state. Journal supports listing, inspection, and balanced entry creation, and refuses postings into closed/locked periods with deterministic errors.

Periods view handles open/close/lock transitions and explains refusals. VAT view runs period calculations and shows totals/diagnostics. Bank and Reconcile views support import and matching flows when those backends are enabled. Attachments view handles evidence add/list/link operations. Validate runs full workspace checks and groups diagnostics by resource or object.

Views that depend on a module backend are hidden or shown as unavailable when that backend is not enabled. The capability response `GET /v1/modules` includes `readOnly` and `enableAgent`, which the UI uses to show mode status and capability-aware workflow guidance. When you change data through the UI, relevant lists may refresh automatically for changes that go through the embedded API; changes made outside the API (e.g. by the agent or external edits) may require a manual refresh.

Control semantics in the UI follow the SDD graphics policy:
controls permanently unavailable in current session are removed (not shown disabled), controls that may become available after user input stay visible but disabled, and read-only values remain visible by default.

### Agent chat (when enabled)

When you start the server with `--enable-agent`, the UI exposes an optional chat panel. You can hide or show this panel at runtime without restarting the server. In the chat you can ask the AI agent to perform operations; the agent runs with the workspace as its working directory and can run Bus CLI tools. The UI presents the agent as a privileged tool that can run commands in the workspace and encourages a “propose then apply” flow (agent suggests changes; you confirm). Agent runtimes are configured or detected per [bus-agent](../sdd/bus-agent); bus-books only exposes the chat UI and delegates execution to the bus-agent library. When agent integration is disabled (default), the chat is not shown and no agent endpoints are available.

### Security and binding

By default the server binds only to `127.0.0.1` and is reachable from the local machine. To listen on a non-loopback interface you must set `--listen` explicitly. The random token in the capability URL is a bearer capability: anyone who has the full URL can access the UI and the embedded API. The server does not implement user accounts, sessions, or stored credentials. All filesystem paths are confined to the workspace root. When you supply `--tls-cert` and `--tls-key`, the server serves HTTPS on the same address and port; otherwise it serves HTTP.

### Exit status and errors

Exit code `0` means success. For `serve`, process stays running until interrupted. Exit code `1` means runtime failure such as unreadable workspace root or invalid TLS files. Exit code `2` means invalid usage, for example unknown subcommand, invalid flag value, or conflicting flags.

Error messages are written to stderr. When the workspace root does not exist or is not readable, startup fails with a clear diagnostic and exit code 1.

### Examples

```bash
bus books serve --port 8090 --token-bytes 32
bus books serve --print-url --enable-agent
bus books -C ./workspace --read-only serve --print-url
bus books serve --print-url --open-view /journal/new --view-only --view-param date=2026-02-20 --view-param desc="Collect details"
bus books version
```


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus books --help
books --help

# same as: bus books -V
books -V

# print a deterministic URL for scripts
books serve --print-url --port 8090

# read-only UI mode from a specific workspace
books -C ./workspace serve --read-only --print-url

# launch a focused single-view GUI form and prefill fields for user input
books serve --print-url --open-view /journal/new --view-only \
  --view-param date=2026-02-20 \
  --view-param desc="Provide bank transaction details"
```

### `.bus` form-view examples (add or edit a record)

Use these patterns when a `.bus` flow needs a human to fill or adjust values in the GUI before continuing.

```bus
# Add record flow: open "new journal entry" form with prefilled fields.
books serve --print-url --open-view /journal/new --view-only \
  --view-param date=2026-02-20 \
  --view-param desc="Add missing bank transaction details"

# Edit record flow: open one existing bank record detail view directly.
# Replace btx-2026-00017 with your transaction id.
books serve --print-url --open-view /bank/btx-2026-00017 --view-only
```

In both cases, the user gets a focused single-view window, enters or edits data, and closes when ready.


### Development state

**Value promise:** Local bookkeeping web UI over BusDK workspaces so end users can perform accounting tasks (journal, periods, VAT, bank, invoices, attachments, validation) in a browser without using the CLI.

**Use cases:** [Accounting workflow overview](../workflow/accounting-workflow-overview).

**Completeness:** 100% — The bus-books Definition of Done is met: a fully functioning UI for Bus modules through embedded bus-api with deterministic CLI/API behavior, capability routing, read-only gating, and headless browser E2E coverage.

**Use case readiness:** Accounting workflow (bookkeeping UI): 100% — Users can complete the documented bookkeeping workflow in the UI with deterministic diagnostics and module-backed operations across all required screens.

**Current:** Serve with default GUI webview launch and optional `--print-url`, default subcommand, token gating, workspace checks, read-only mode, embedded API, schema endpoints, SSE mutation events, module backend routing, and screen flows are test-covered by `tests/e2e.sh` and `internal/*/*_test.go`. Inbox supports filters (`reviewState`, `evidenceOk`) and item actions; Journal supports list/detail/new with deterministic period-state errors; Periods supports open/close/lock transitions; VAT supports period list/report run plus source links to underlying transactions when provided by the backend; Bank supports import/list/detail; Reconcile supports suggestions and confirm with deterministic refusals; Attachments supports add/list/link; Validate supports grouped deterministic diagnostics. List views (Inbox, Journal, Bank) now support deterministic `limit`/`offset` slicing, and the UI exposes row-limit selectors to keep large lists responsive. The main view now uses full-width section backgrounds with constrained inner content, aligned to the documentation layout contract.

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
- [Finnish WebView bookkeeping UI requirements](../implementation/fi-webview-accounting-ui-requirements)
- [Finnish WebView compliance and audit UX](../implementation/fi-webview-compliance-and-audit-ux)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)

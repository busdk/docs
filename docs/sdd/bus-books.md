---
title: bus-books — local bookkeeping web UI for end users (accounting screens over BusDK modules)
description: bus books provides a local, end-user-focused web UI for BusDK bookkeeping workspaces, integrating core accounting modules (journal, periods, VAT, bank, invoices, attachments) with safe defaults and optional agent chat.
---

# bus-books — local bookkeeping web UI for end users (SDD)

## bus-books — local bookkeeping web UI for end users

### Introduction and Overview

Bus Books provides a local, end-user-facing web UI for doing bookkeeping work in a BusDK workspace. Unlike [Bus Sheets](bus-sheets) (generic table/grid editing), Bus Books focuses on accounting screens and workflows that map to real bookkeeping tasks: journal postings, period control, VAT review, bank import and reconciliation, invoice review, evidence attachments, and workspace validation.

Bus Books does not create a new accounting engine. All domain behavior is delegated to existing BusDK modules through in-process Go libraries and the embedded [Bus API](bus-api) surface. The UI is schema-driven: adding a new column to a workspace dataset and its schema must make that column appear in list and detail views without recompilation or reprogramming. Bus Books does not shell out to other `bus-*` CLIs for its own UI operations. The only allowed CLI execution is optional agent chat, which runs in a clearly marked, explicitly enabled “agent execution context”.

Bus Books follows the same MVP security model as [Bus API](bus-api) and [Bus Sheets](bus-sheets): loopback-only binding by default, and a capability-style unguessable random token in the URL path prefix that gates both UI and API.

The purpose of this SDD is to define Bus Books as an end-user UI module, specify its command surface, security defaults, integration boundaries, and the minimum accounting workflows it must support.

### Goals

G-BOK-001 End-user bookkeeping UI. Provide a usable local web UI for normal bookkeeping tasks without requiring the user to learn the CLI.

G-BOK-002 Module-backed correctness. Use BusDK domain modules as the authoritative source of truth for rules and data semantics (period rules, balanced postings, VAT computation, import validation). Do not duplicate accounting logic in the UI backend.

G-BOK-003 Safe-by-default local operation. Default to loopback binding and capability URL gating; avoid accounts, cookies, sessions, and stored credentials.

G-BOK-004 Unified “Inbox” mental model. Provide one actionable view for items needing bookkeeping attention (e.g. invoices and bank transactions) using shared workflow metadata fields so triage and review status are consistent across object types.

G-BOK-005 Optional agent assist. When explicitly enabled, provide a chat view where an AI agent can propose or perform operations in the workspace, with clear separation from normal UI actions.

G-BOK-006 Schema-driven column display. Adding a new column to a workspace dataset (and its schema) must make that column appear in the relevant Bus Books list and detail views without recompilation, redeployment, or configuration change. The implementation must be schema-driven so that workspace evolution does not require code or binary changes.

### Non-goals

NG-BOK-001 Not a generic spreadsheet editor. Bus Books is not a workbook-style grid UI for arbitrary resource editing and does not provide schema editing. Power users can use [Bus Sheets](bus-sheets) for that.

NG-BOK-002 No multi-user authentication. No user accounts, sessions, OAuth, cookies, or stored credentials. MVP authorization is loopback binding + capability URL token.

NG-BOK-003 No background watchers by default. The server does not watch files or mutate data without explicit user actions. UI refresh is client-driven and event-driven only for changes that go through the embedded API.

NG-BOK-004 No hosted SaaS promise. Bus Books is designed for local use. Running it on a LAN or behind a proxy is an operator choice, not a core requirement.

NG-BOK-005 No “magical” bookkeeping automation. The UI may assist, but accounting decisions remain explicit and reviewable (Git-auditable workspace data).

## Requirements

### Functional Requirements

FR-BOK-001 Local UI server. The module MUST provide a CLI command that starts a local HTTP server which serves the Bus Books web UI for the selected workspace root.
Acceptance criteria: startup succeeds without configuration in a readable workspace; startup fails deterministically if the workspace root is not readable.

FR-BOK-002 Capability URL gating. On startup, the server MUST generate an unguessable random token and MUST require all UI and API requests to be scoped under a path prefix containing that token.
Acceptance criteria: the server prints a full base URL that includes the token and a port; requests outside the token prefix return 404 (or equivalent).

FR-BOK-003 Safe default binding. The server MUST bind to `127.0.0.1` by default and MUST NOT listen on non-loopback interfaces unless explicitly requested.
Acceptance criteria: without flags, the UI is reachable only from localhost; non-loopback bind requires an explicit `--listen` flag.

FR-BOK-004 Embedded assets. The binary MUST embed everything needed to serve the UI (HTML/CSS/JS) without external template files, build directories, or runtime downloads.
Acceptance criteria: `bus-books serve` works after installation with no additional files.

FR-BOK-005 Bus API backend in-process. Bus Books MUST embed the Bus API server core as a Go library and mount it under the capability prefix.
Acceptance criteria: all workspace reads/writes performed by the UI are served by embedded handlers; no code path executes `bus-api`, `bus-data`, or any other `bus-*` binary for normal UI operations.

FR-BOK-006 Domain module endpoints enabled for UI. Bus Books MUST expose domain module backends through the embedded Bus API module endpoint mechanism so the UI can perform bookkeeping operations through module libraries.
Acceptance criteria: the embedded API mounts `/{token}/v1/modules/{module}/...` for the enabled modules; UI screens that require a module are disabled or hidden when that module backend is unavailable.

FR-BOK-007 Dashboard screen. The UI MUST provide a dashboard that summarizes workspace status relevant to bookkeeping.
Acceptance criteria: dashboard shows (at minimum) workspace identity, current fiscal period state, validation status summary, and quick links to Inbox, Journal, Periods, VAT, Bank, and Attachments.

FR-BOK-008 Inbox screen for bookkeeping triage. The UI MUST provide an Inbox view that lists items needing action across supported object types (at minimum: invoices and bank transactions when those modules are enabled).
Acceptance criteria: user can filter by workflow metadata (review state, evidence completeness, booked/locked state) and open an item detail view.

FR-BOK-009 Journal screen (view and post). The UI MUST provide a Journal view to browse postings and create a balanced transaction through the journal module backend.
Acceptance criteria: user can list and inspect transactions; user can create a new balanced transaction; the system rejects postings into closed/locked periods with deterministic errors.

FR-BOK-010 Periods screen (open/close/lock). The UI MUST provide a Periods view to list period states and perform open/close/lock actions through the period module backend.
Acceptance criteria: period state transitions follow the module rules; UI shows deterministic diagnostics when transitions are refused.

FR-BOK-011 VAT screen (compute and review). The UI MUST provide a VAT view that can run VAT calculations and show the resulting report outputs through the VAT/reporting backends when available.
Acceptance criteria: user can compute VAT for a selected reporting period and view totals and diagnostics; failures are shown with stable error messages.

FR-BOK-012 Bank screen (import and review). The UI MUST provide a Bank view that can import bank statements and list normalized bank transactions through the bank module backend.
Acceptance criteria: user can trigger an import and then browse imported transactions; import failures are deterministic and do not partially corrupt datasets.

FR-BOK-013 Reconciliation support (when available). If reconciliation backends are enabled, the UI MUST expose reconciliation workflows (suggestions, linking, marking matched).
Acceptance criteria: user can see candidate matches and explicitly confirm matches; resulting changes are persisted in workspace data via module semantics.

FR-BOK-014 Attachments and evidence. The UI MUST provide an Attachments view to add and list evidence and link it to bookkeeping objects using module capabilities.
Acceptance criteria: user can upload/add evidence references and see linked evidence per item; evidence completeness status is visible in the Inbox.

FR-BOK-015 Validation view. The UI MUST provide a way to run workspace validation and show diagnostics.
Acceptance criteria: user can run full validation and see deterministic, stable-ordered diagnostics; validation does not modify datasets.

FR-BOK-016 Optional agent chat UI. When agent integration is enabled, the UI MUST provide an IDE-style chat dialog where the user can ask an AI agent to perform operations in the workspace.
Acceptance criteria: when enabled, chat is available; the agent runs with workspace as workdir and can run Bus CLI tools; when disabled, no agent UI or endpoints exist.

FR-BOK-017 Agent enable and visibility. Agent integration MUST be optional and controllable at startup (enable/disable) and at runtime (hide/unhide panel).
Acceptance criteria: server starts with agent disabled by default; when enabled, the user can hide or show the panel without restart.

FR-BOK-018 Event-driven refresh (API-originated). The UI SHOULD subscribe to the embedded API event stream and refresh views when changes are made through the API.
Acceptance criteria: when mutations occur via the embedded API, relevant lists refresh without manual reload; changes made outside the API (agent CLI or external file edits) require manual refresh.

FR-BOK-019 Schema-driven columns for datasets. The UI and embedded API MUST derive the set of columns for dataset tables from the workspace schema (e.g. Table Schema) at runtime. Adding a new column to a dataset and its schema in the workspace MUST cause that column to appear in the relevant Bus Books list and detail views without recompilation, redeployment, or configuration change.
Acceptance criteria: (1) For any dataset exposed in the UI, the columns shown are those present in the schema (or inferred from the data) for that dataset. (2) After a new column is added to the CSV and schema, refreshing or reopening the view shows the new column. (3) No code or binary change is required to display the new column.

### Non-Functional Requirements

NFR-BOK-001 Minimal authentication surface. The MVP MUST rely on loopback binding + capability URL token and MUST NOT implement accounts, sessions, OAuth, cookies, or stored credentials.

NFR-BOK-002 Deterministic error surfacing. The UI MUST surface stable error codes/messages from the embedded API and module backends without rewriting away deterministic identifiers.

NFR-BOK-003 No hidden background work. The server MUST NOT mutate workspace data without explicit user actions, and MUST NOT run filesystem watchers by default.

NFR-BOK-004 Operation gating. The server MUST support a read-only mode that makes all mutating operations return a deterministic error (e.g. 403), while still allowing reads and validation.

NFR-BOK-005 Concurrency safety. Concurrent writes must not corrupt workspace data; all mutations go through the embedded API and module libraries and rely on their locking/atomicity rules.

NFR-BOK-006 Maintainability. The module MUST be library-first with a thin CLI wrapper and a reproducible frontend build; the UI should not depend on network services to run.

NFR-BOK-007 Performance (local). The server and UI MUST remain responsive for typical local workspaces; list views must support paging/limits as needed.

NFR-BOK-008 No hardcoded column set for datasets. The implementation MUST NOT require recompilation or reprogramming to display new or renamed columns in workspace datasets. Column metadata MUST be read from the workspace (schema or data) at runtime.

## System Architecture

Bus Books is a local web app server composed of:

1) Embedded Bus API core (in-process). This is the authoritative HTTP surface for workspace operations and module endpoints. Bus Books mounts the Bus API handler under `/{token}/v1/...` and enables a default set of bookkeeping modules (when compiled/registered).

2) Embedded frontend assets (SPA). The server serves `index.html` and static assets under `/{token}/...` with SPA fallback for non-API routes.

Optional:
3) Embedded agent endpoints (when enabled). When `--enable-agent` is set, Bus Books mounts agent endpoints that delegate to bus-agent library, with the workspace root as working directory.

### Routing and base URL

The server prints a single capability base URL for the user to open:

`http://127.0.0.1:<port>/{token}/`

Under that prefix:
- UI assets and SPA routes are served under `/{token}/...`
- Embedded Bus API is available under `/{token}/v1/...` (core endpoints and enabled module endpoints)
- When enabled, agent endpoints are available under a defined prefix (e.g. `/{token}/v1/agent/...`)

Requests not under `/{token}/` return 404.

## Key Decisions

KD-BOK-001 “Books” naming. The module is named `bus-books` to evoke bookkeeping “books” and end-user accounting workflows, distinct from the generic grid editor.

KD-BOK-002 Same security defaults as Bus API. Loopback-only + capability URL token is the MVP authorization model, avoiding accounts and cookies.

KD-BOK-003 Module-backed operations. Bookkeeping actions are performed through domain module libraries exposed via the embedded API, not by directly editing CSV tables in the UI.

KD-BOK-004 Inbox uses shared workflow metadata. The Inbox is a unified view over different object types by relying on a shared review/evidence vocabulary where available.

KD-BOK-005 Agent integration is optional and clearly separated. The agent is disabled by default and, when enabled, is explicitly presented as a privileged tool that can run CLI operations in the workspace.

KD-BOK-006 Schema-driven table display. List and detail views for workspace datasets (journal lines, bank transactions, invoices, etc.) derive their column set from the workspace schema at runtime so that new columns appear in the UI without code changes. Workspace evolution (e.g. adding a table column) must not require a new build or reprogramming.

## Component Design and Interfaces

### IF-BOK-001 Go library interface (server core)

The module exposes a Go package that can be used to embed Bus Books server behavior.

Normative shape (names illustrative):
- `type Server struct { … }`
- `func NewServer(root string, opt Options) (*Server, error)`
- `func (s *Server) Handler() http.Handler`
- `func (s *Server) Serve(l net.Listener) error`

`Options` includes:
- `ListenAddr`, `Port` (0 allowed)
- `Token` (optional; if empty, generated randomly)
- `TokenBytes` (default 32)
- `TLSCertFile`, `TLSKeyFile` (optional; serve HTTPS when both set)
- `ReadOnly` (pass-through to embedded Bus API)
- `APIVersion` (default `v1`, pass-through)
- `EnableModules` (default: bookkeeping module set compiled into the binary)
- `EnableAgent` (default false)

### IF-BOK-002 Embedded Bus API integration

Bus Books constructs an embedded Bus API server instance using the Bus API Go library and mounts it under `/{token}/v1/...`.

Bus Books MUST NOT invoke any Bus module CLI for normal UI operations. Domain module behavior is provided by registered module backends (Go `http.Handler`) mounted under `/{token}/v1/modules/{module}/...`.

### IF-BOK-003 Frontend asset serving

The server serves:
- `index.html` for SPA entry
- hashed static assets under a deterministic prefix (e.g. `/{token}/assets/...`)
- SPA route fallback: any non-API path under `/{token}/` that is not a real asset returns `index.html`

The SPA must support a dynamic base path rooted at `/{token}/`.

### IF-BOK-004 Optional agent integration

When `EnableAgent` is true, the server mounts agent endpoints that delegate to the bus-agent library with the workspace root as working directory.
When `EnableAgent` is false, no agent routes are registered and the UI must not show the chat panel.

## Command Surface

The module exposes `bus-books` as a CLI entry point (and via dispatcher as `bus books …`).

Commands:
- `bus-books serve` (default)
  - Starts the server, prints the capability URL to stdout, writes diagnostics to stderr.
- `bus-books version`
  - Prints version info.

Serve flags (module-specific, aligned with Bus API defaults):
- `--listen <addr>` default `127.0.0.1`
- `--port <n>` default `0` (auto)
- `--token <string>` optional (tests)
- `--token-bytes <n>` default `32`
- `--tls-cert <file>` optional (when used with `--tls-key`)
- `--tls-key <file>` optional (when used with `--tls-cert`)
- `--read-only` disables all mutating operations (403) via embedded Bus API
- `--enable-agent` enables optional agent chat integration (default: disabled)

## UI Behavior

List and detail views for workspace datasets derive their column set from the workspace schema at runtime; new or renamed columns appear in the UI without recompilation (FR-BOK-019, KD-BOK-006).

### Navigation

The UI provides primary navigation:
- Dashboard
- Inbox
- Journal
- Periods
- VAT
- Bank
- Reconcile (only when available)
- Attachments
- Validate

Views that depend on a module backend are hidden or shown as “unavailable” when that backend is not enabled.

### Dashboard

The dashboard shows:
- Workspace identity (from config when available)
- Current/open period(s) and their state
- Validation status summary (last run in this session) and a “Run validation” action
- Shortcuts to Inbox and core workflows

### Inbox

The Inbox is a merged list of bookkeeping items from enabled modules (at minimum invoices and bank transactions when those datasets exist).
It supports:
- filtering by review state and evidence completeness (workflow metadata fields)
- opening an item detail view
- marking review progress (triage/book/lock actions) when the underlying object supports those fields

### Journal

The Journal view supports:
- listing transactions (with paging)
- inspecting a transaction and its lines
- creating a new balanced transaction through the journal backend
- deterministic failure messages when balance rules or period rules are violated

### Periods

The Periods view supports:
- listing periods and their states
- opening, closing, and locking periods through the period backend
- showing why an action is refused (preconditions, validation failures)

### VAT

The VAT view supports:
- selecting a VAT reporting period
- running VAT calculation via VAT/reporting backends
- showing totals and diagnostics
- linking VAT outputs back to underlying transactions where supported

### Bank

The Bank view supports:
- importing statements via the bank backend
- listing transactions and opening details
- showing reconciliation status and evidence status where supported

### Reconcile (optional)

When reconciliation backends exist:
- show suggested matches
- allow explicit confirmation of links/matches
- show deterministic diagnostics for refused matches

### Attachments

The Attachments view supports:
- listing evidence items
- adding evidence (upload or reference, per attachments backend)
- linking evidence to bookkeeping objects where supported
- surfacing evidence completeness in item views and Inbox

### Validate

The Validate view supports:
- running full workspace validation
- showing deterministic diagnostics grouped by resource/object where possible

### Agent chat (when enabled)

When started with `--enable-agent`, the UI shows a chat panel that can be hidden/unhidden.
Agent actions are treated as privileged:
- UI clearly indicates that agent may run CLI commands in the workspace
- UI encourages “propose then apply” interaction (agent suggests changes; user confirms)

## Data Design

Bus Books introduces no new on-disk formats or persistent server state. All persistent data remains BusDK workspace datasets (CSV + Table Schema + optional `datapackage.json`) owned by existing modules.

The server is stateless aside from in-process runtime state (token, listeners, active SSE connections). Any “last run” UI status (e.g. last validation results) is session-local and may be stored in the browser only.

Column set for dataset views is not stored or hardcoded in Bus Books. The UI and API derive which columns to display from the workspace schema (and, where applicable, from the data) at runtime. Adding or renaming columns in the workspace datasets and their schemas is sufficient for those columns to appear in list and detail views; no recompilation or configuration change is required.

## Assumptions and Dependencies

AD-BOK-001 Bus API library is available and stable enough to embed as an in-process server core.

AD-BOK-002 Workspaces live on the local filesystem; the workspace root is the security boundary.

AD-BOK-003 Domain modules that Bus Books exposes provide module backends (Go handlers) that implement the operations required by screens (journal posting, period transitions, import flows, reporting).

AD-BOK-004 When agent integration is enabled, bus-agent is available and agent runtimes are configured/detected outside bus-books per bus-agent semantics.

## Security Considerations

Bus Books inherits Bus API MVP security model:
- Loopback binding by default.
- Capability URL token gates all UI and API routes.
- Optional HTTPS when operator provides cert+key (or external TLS termination).
- Workspace root confinement: filesystem operations remain workspace-relative and must not escape the root boundary.
- Logging should redact the token in request paths by default.

Agent risk:
- Agent integration is disabled by default.
- When enabled, it is clearly marked as privileged because it can run CLI commands in the workspace.
- The UI should support a “read-only” server mode where even agent-triggered API mutations are refused through the embedded API gating (note: agent can still edit files directly if it is allowed to run arbitrary shell commands; this is an operator decision and must be communicated).

## Error Handling and Resilience

Invalid CLI usage exits with code 2 and a concise usage error.

Runtime failures return deterministic HTTP statuses and JSON error bodies from the embedded API and module backends. The UI displays errors without losing stable error codes.

Any request that fails must leave the workspace unchanged, relying on atomic write semantics and locking provided by the embedded stack.

## Testing Strategy

Unit tests:
- token gating for UI + API (requests outside `/{token}/` are 404)
- SPA fallback behavior does not intercept API routes
- deterministic asset serving (no dependency on filesystem build output)
- read-only mode returns deterministic 403 on mutating operations

Integration tests:
- start server with fixed `--token` and fixed `--port`
- verify dashboard can load minimal workspace metadata
- verify journal add is rejected/accepted according to period state
- verify period transitions produce expected deterministic outcomes
- verify validation endpoint results are surfaced correctly

## Deployment and Operations

Not Applicable. The module ships as a single embedded binary for local use; no separate deployment or operational runbook is required beyond starting the server.

Operators MAY run the server on non-loopback interfaces or behind a reverse proxy, but that is outside MVP assumptions and must be considered carefully due to the capability URL authorization model.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-sheets">bus-sheets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api module SDD](./bus-api) (embedded API, security model)
- [bus-sheets module SDD](./bus-sheets) (contrast: generic workbook vs accounting UI)
- [bus-agent module SDD](./bus-agent) (optional agent chat)

### Document control

Title: bus-books module SDD  
Project: BusDK  
Document identifier: sdd/bus-books  
Version: 1  
Status: Draft  
Last updated: 2025-02-17  
Owner: BusDK maintainers

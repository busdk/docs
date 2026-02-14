---
title: bus-sheets — spreadsheet-like web UI for workspace data (SDD)
description: Bus Sheets provides a local, spreadsheet-like web user interface for BusDK workspaces.
---

## bus-sheets — spreadsheet-like web UI for workspace data

### Introduction and Overview

Bus Sheets provides a local, spreadsheet-like web user interface for BusDK workspaces. It is intended for system administrators and power users who want a familiar multi-tab “workbook” experience over BusDK’s tabular data: each BusDK resource (a CSV file with a beside-the-table Table Schema JSON) is presented as a sheet tab, and the workspace directory is presented as the workbook.

Bus Sheets does **not** implement domain UIs for Bus modules (accounts, invoices, VAT, etc.). Its scope is strictly the mechanical workspace layer: listing resources, viewing and editing rows, inspecting and mechanically editing schemas, and running validations. All semantics for CSV, Table Schema, Data Package, mutation policies, foreign keys, and formula projection are delegated to Bus API / Bus Data, not re-implemented. ([bus-api SDD](./bus-api))

Bus Sheets follows the same security and HTTP defaults as Bus API: loopback-only binding by default, and a capability-style unguessable random token in the URL path prefix that gates both the UI and the underlying API. ([bus-api SDD](./bus-api))

The document’s purpose is to provide a single source of truth for design review and implementation. The intended audience is human reviewers who verify correctness and completeness and downstream implementors or AI agents who use the SDD as authoritative guidance. Explicitly out of scope: domain-specific UIs (accounting or invoice screens, module wizards), multi-user authentication, and re-implementation of dataset semantics.

### Goals

G-SHT-001 Workbook UX over a workspace. Present a workspace as a workbook and each CSV+schema resource as a sheet tab with deterministic ordering and stable identifiers.

G-SHT-002 Schema-aware spreadsheet editing. Provide a grid view that respects Table Schema field order, types, constraints, primary keys, and BusDK mutation policies (`busdk.update_policy`, `busdk.delete_policy`) via Bus API. ([bus-api SDD](./bus-api))

G-SHT-003 Library-backed correctness. Reuse Bus API as the authoritative backend and do not re-implement dataset semantics in the UI backend. Bus API delegates to Bus Data, including formula projection. ([bus-api SDD](./bus-api))

G-SHT-004 Zero-install web UI. Ship as a single embedded binary that starts the UI from the CLI without external runtime downloads.

G-SHT-005 Optional agent integration. When enabled, provide an IDE-style chat dialog so the user can ask an AI agent to perform operations via Bus CLI tools in the workspace and see resulting changes in the sheets view. The agent runs with the workspace as working directory and has access to run Bus CLI tools; the user can enable or disable the feature at startup (command-line) and hide or show the chat at runtime in the UI. ([bus-agent](./bus-agent))

### Non-goals

NG-SHT-001 No domain module UI. Bus Sheets does not provide “accounting screens”, “invoice screens”, or module-specific wizards. Those belong to separate modules.

NG-SHT-002 No multi-user auth. No accounts, sessions, OAuth, cookies, or stored credentials. MVP security is loopback + capability URL. ([bus-api SDD](./bus-api))

NG-SHT-003 No background watchers by default. The server does not watch files or mutate data without explicit user actions via the API; UI refresh is client-driven (manual refresh or polling). ([bus-api SDD](./bus-api))

NG-SHT-004 No formula engine in the UI backend. Bus Sheets does not evaluate formulas itself; formula behavior is delegated through Bus API → Bus Data → BFL. ([bus-api SDD](./bus-api))

---

## Requirements

### Functional Requirements

FR-SHT-001 Local UI server. The module MUST provide a CLI command that starts a local HTTP server which serves the Bus Sheets web UI for the selected workspace root. Acceptance criteria: starting succeeds without configuration in a readable workspace; startup fails deterministically if the workspace root is not readable.

FR-SHT-002 Capability URL gating. On startup, the server MUST generate an unguessable random token and MUST require all UI and API requests to be scoped under a path prefix containing that token. Acceptance criteria: the server prints a full base URL that includes the token and a port; requests outside the token prefix return 404 (or equivalent). This mirrors Bus API’s capability URL model. ([bus-api SDD](./bus-api))

FR-SHT-003 Safe default binding. The server MUST bind to `127.0.0.1` by default and MUST NOT listen on non-loopback interfaces unless explicitly requested. Acceptance criteria: without flags, the UI is reachable only from localhost; non-loopback bind requires an explicit `--listen` flag. ([bus-api SDD](./bus-api))

FR-SHT-004 Embedded assets. The binary MUST embed everything needed to serve the UI (HTML/CSS/JS) without external template files, build directories, or runtime downloads. Acceptance criteria: `bus-sheets serve` works after installation with no additional files.

FR-SHT-005 Bus API backend in-process. Bus Sheets MUST provide the underlying workspace operations by embedding (and delegating to) the Bus API server core as a Go library, and MUST NOT invoke any Bus module CLI. Acceptance criteria: all data and schema operations exposed to the UI are served by Bus API handlers; no code path executes `bus-api`, `bus-data`, `bus-bfl`, or any other `bus-*` binary. This preserves Bus API’s library-only integration rule. ([bus-api SDD](./bus-api))

FR-SHT-006 Multi-tab resource navigation. The UI MUST list workspace resources and present each resource as a selectable sheet tab. Acceptance criteria: resource list matches Bus API resource discovery behavior and ordering (reflecting `datapackage.json` when present, otherwise discovery by beside-the-table schema conventions). ([bus-api SDD](./bus-api))

FR-SHT-007 Grid view and row CRUD. The UI MUST provide a spreadsheet-like grid to view and edit rows via Bus API row endpoints, obeying schema validation and mutation policies. Acceptance criteria: edits that violate schema or policy are rejected with deterministic error feedback; allowed edits persist and are reflected on refresh. ([bus-api SDD](./bus-api))

FR-SHT-008 Schema view and mechanical schema edits. The UI MUST provide a schema view for the active sheet and MUST support mechanical schema operations by calling Bus API’s schema endpoints (field add/remove/rename, schema patch, key operations) when allowed by server mode (e.g. not in read-only). Acceptance criteria: schema operations match Bus API behavior and refuse destructive changes unless forced per Bus Data semantics as exposed by Bus API. ([bus-api SDD](./bus-api))

FR-SHT-009 Validation UI. The UI MUST provide actions to validate the current resource and the full workspace via Bus API validation endpoints and display deterministic diagnostics. Acceptance criteria: validation results are shown in stable ordering and identify resource/field/row context where applicable. ([bus-api SDD](./bus-api))

FR-SHT-010 Formula-projected display. When Bus API returns formula-projected values, the UI MUST display computed values by default and MUST support an opt-in mode to show formula source alongside computed values when the API is requested to include it. Acceptance criteria: computed values are shown without writing back to CSV; opt-in mode reveals the stored formula source using the API’s non-colliding representation. ([bus-api SDD](./bus-api))

FR-SHT-011 Optional agent chat UI. When agent integration is enabled, the UI MUST provide an IDE-style chat dialog in which the user can converse with an AI agent. The agent MUST have access to run Bus CLI tools in the current workspace working directory so the user can request operations (e.g. add rows, validate, run module commands) and see resulting changes in the sheets view after refresh or equivalent. Acceptance criteria: when enabled, the chat is available; user requests can result in Bus CLI invocations in the workspace; after agent actions that mutate data, the user can refresh the sheet view to see updates. ([bus-agent](./bus-agent))

FR-SHT-012 Agent enable and visibility. Agent integration MUST be optional and controllable in two ways: (1) at startup via command-line parameter (enable or disable), and (2) at runtime from the UI (user can hide or unhide the chat panel without restarting the server). Acceptance criteria: the server can start with agent disabled (default or explicit flag); when disabled, no agent endpoints or chat UI are exposed; when enabled, the user can hide or show the chat panel from the UI.

FR-SHT-013 Event-driven refresh. The UI MUST support subscribing to the embedded [bus-api](./bus-api) event stream (`GET /{token}/v1/events`) and MUST use received mutation events to refresh or invalidate the affected resource, tab, or resource list so that changes made through the API are reflected without requiring a manual full refresh. Acceptance criteria: when the UI subscribes to the event stream and a mutation occurs via the API (e.g. row or schema change from the same session or from another client), the relevant sheet or tab updates to show the new data; events are consumed according to the bus-api event stream contract (SSE, payload shape). Manual refresh remains available and continues to work. Events are emitted only for mutations performed through the API; changes made outside the API (e.g. by the agent running Bus CLI tools) do not produce events, so the user must refresh to see those changes. ([bus-api SDD](./bus-api))

### Non-Functional Requirements

NFR-SHT-001 Minimal authentication surface. The MVP MUST rely on loopback binding + capability URL token and MUST NOT implement accounts, sessions, OAuth, cookies, or stored credentials. ([bus-api SDD](./bus-api))

NFR-SHT-002 No hidden background work. The server MUST NOT mutate workspace data without explicit API requests and MUST NOT run filesystem watchers by default. ([bus-api SDD](./bus-api))

NFR-SHT-003 Deterministic responses and errors. For the same workspace state and request sequence, API responses and error payloads presented in the UI MUST be stable and comparable in tests (stable ordering, stable error codes). This inherits the determinism guarantees of Bus API for backend operations. ([bus-api SDD](./bus-api))

NFR-SHT-004 Concurrency safety. Concurrent writes must not corrupt workspace data; Bus Sheets MUST rely on Bus API’s workspace-level locking strategy for all mutations. ([bus-api SDD](./bus-api))

NFR-SHT-005 Operation gating. The server MUST support a read-only mode that makes all mutating operations return a deterministic error (e.g. 403) while still allowing reads and validation. This is passed through to the embedded Bus API server. ([bus-api SDD](./bus-api))

NFR-SHT-006 Maintainability. The module MUST be library-first with a thin CLI wrapper, and SHOULD keep the React frontend build pipeline isolated and reproducible.

NFR-SHT-007 Performance. The server MUST remain responsive for local use on typical workspace datasets. Acceptance criteria: UI and API responses complete within a documented timeout under normative load; no unbounded in-memory growth for resource listing or row reads within a single request.

NFR-SHT-008 Scalability. The module targets a single workspace per server instance. Acceptance criteria: the design does not assume distributed deployment or multi-tenant sharing; scaling is by running additional instances bound to different workspace roots.

---

## System Architecture

Bus Sheets is a local web app server that embeds two major parts, satisfying FR-SHT-001, FR-SHT-004, and FR-SHT-005.

1. **Embedded Bus API core** (in-process). This is the authoritative backend for workspace CRUD, schema operations, resource discovery, and validation. Bus Sheets does not implement these semantics itself; it delegates to [bus-api](./bus-api), which delegates to [bus-data](./bus-data) (and transitively [bus-bfl](./bus-bfl) for formulas). This satisfies FR-SHT-005 and FR-SHT-006.

2. **Embedded static frontend** (React SPA). The UI is served under the same capability token prefix as the API and calls the API using same-origin relative paths to avoid CORS complexity. The frontend subscribes to the Bus API event stream when the workbook is in use and uses mutation events to refresh the affected sheet or resource list so that API-originated changes appear without manual refresh (FR-SHT-013). This satisfies FR-SHT-004, FR-SHT-006, and FR-SHT-013.

3. **Optional agent integration** (when enabled). When started with agent enabled, the server exposes agent endpoints (e.g. under `/{token}/v1/agent/...`) that delegate to the [bus-agent](./bus-agent) library with the workspace root as working directory. The frontend exposes a chat panel that the user can hide or show at runtime. The agent is given the ability to run Bus CLI tools in that directory so user requests can result in workspace mutations; the user sees changes in the sheets view after refresh. This satisfies FR-SHT-011 and FR-SHT-012. Bus Sheets does not invoke Bus CLI for its own grid or schema operations (those remain via the embedded Bus API); only the agent execution context may run Bus CLI tools in the workspace.

### Routing and base URL

The server prints a single capability base URL for the user to open in a browser:

`http://127.0.0.1:<port>/{token}/`

Under that prefix:

* UI assets and SPA routes are served under `/{token}/...`
* [bus-api](./bus-api) remains available under `/{token}/v1/...` exactly as defined by the bus-api SDD (healthz, resources, rows, schema, validation, openapi, events).

The embedded Bus API exposes an event stream at `GET /{token}/v1/events` (Server-Sent Events). The frontend SHOULD subscribe to this stream and use mutation events to refresh the affected resource or tab so that API-originated changes are reflected without manual refresh (FR-SHT-013). Events are emitted only for mutations performed through this API instance; they are not emitted for changes made by the agent running Bus CLI tools or for external file edits.

Requests not under `/{token}/` return 404.

---

## Key Decisions

KD-SHT-001 “Sheets vibe” naming. The module is named `bus-sheets` to intentionally evoke the familiar spreadsheet mental model: workspace = workbook, resource = sheet/tab.

KD-SHT-002 Same security defaults as Bus API. Loopback-only + capability URL token is the MVP authorization model, avoiding accounts and cookies. ([bus-api SDD](./bus-api))

KD-SHT-003 Bus API as the only workspace backend. The UI backend delegates all operations to Bus API in-process; no CLI execution and no re-implementation of Bus Data semantics. ([bus-api SDD](./bus-api))

KD-SHT-004 Formula display is delegated. Formulas are shown via Bus API’s formula-projected reads; BFL’s range and array mechanics remain a library concern (Bus Data provides the range resolver; BFL supports ranges and arrays as first-class values). ([bus-api SDD](./bus-api))

KD-SHT-005 Agent integration is optional and IDE-style. The agent is exposed as a chat dialog (similar to IDE AI integrations), disabled by default and controllable via CLI flag and runtime UI visibility. The agent runs with the workspace as workdir and can run Bus CLI tools so the user can request multi-step operations and see results in the sheets view. ([bus-agent](./bus-agent))

---

## Component Design and Interfaces

### IF-SHT-001 Go library interface (server core)

The module exposes a Go package that can be used to embed Bus Sheets server behavior.

Normative shape (names illustrative):

* `type Server struct { … }`
* `func NewServer(root string, opt Options) (*Server, error)`
* `func (s *Server) Handler() http.Handler`
* `func (s *Server) Serve(l net.Listener) error`

`Options` includes:

* `ListenAddr`, `Port` (0 allowed)
* `Token` (optional; if empty, generated randomly)
* `TokenBytes` (default 32)
* `TLSCertFile`, `TLSKeyFile` (optional; serve HTTPS when both set)
* `ReadOnly` (pass-through to Bus API)
* `APIVersion` (default `v1`, pass-through to Bus API)
* `EnableModules` (optional pass-through to embedded Bus API; UI does not depend on module endpoints)
* `EnableAgent` (optional; when true, agent endpoints and chat UI are available; default false)

### IF-SHT-002 Embedded Bus API integration

Bus Sheets constructs an embedded Bus API server instance using Bus API’s Go library interface and mounts its handler under `/{token}/v1/…`. Bus Sheets MUST NOT invoke any Bus module CLI. ([bus-api SDD](./bus-api))

### IF-SHT-003 Frontend asset serving

The server serves:

* `index.html` for SPA entry
* hashed static assets under a deterministic prefix (e.g. `/{token}/assets/...`)
* SPA route fallback: any non-API path under `/{token}/` that is not a real asset returns `index.html`

The SPA must be built to support a dynamic base path rooted at `/{token}/` (for example by using relative asset paths and avoiding a hard-coded absolute base).

### IF-SHT-004 Optional agent integration

When `EnableAgent` is true, the server mounts agent endpoints under a defined prefix (e.g. `/{token}/v1/agent/...`). These endpoints delegate to the [bus-agent](./bus-agent) library with the workspace root as working directory. The contract is: the frontend sends user messages to the agent endpoint; the server invokes the agent (via bus-agent) with the workspace as workdir; the agent runtime may run Bus CLI tools in that directory; the server returns agent responses (e.g. streamed or batched) to the frontend. The frontend does not invoke Bus CLI directly; only the agent execution context has that capability. When `EnableAgent` is false, no agent routes are registered and the UI must not display or request the chat panel.

---

## Command Surface

The module exposes `bus-sheets` as a CLI entry point (and via dispatcher as `bus sheets …`).

Commands:

* `bus-sheets serve` (default)

  * Starts the server, prints the capability URL to stdout, writes diagnostics to stderr.
* `bus-sheets version`

  * Prints version info.

Serve flags (module-specific, aligned with Bus API defaults):

* `--listen <addr>` default `127.0.0.1`
* `--port <n>` default `0` (auto)
* `--token <string>` optional (tests)
* `--token-bytes <n>` default `32`
* `--tls-cert <file>` optional (when used with `--tls-key`)
* `--tls-key <file>` optional (when used with `--tls-cert`)
* `--read-only` disables all mutating operations (403) via embedded Bus API ([bus-api SDD](./bus-api))
* `--enable-agent` enables the optional [bus-agent](./bus-agent) chat integration; when set, the UI exposes a chat dialog and the agent can run Bus CLI tools in the workspace. Default: disabled. When disabled, the chat is not shown and no agent endpoints are exposed.

---

## UI Behavior

### Workbook and tabs

* The left/top tab bar lists resources from `GET /{token}/v1/resources`.
* Tab ordering is deterministic and matches the API ordering. ([bus-api SDD](./bus-api))
* Selecting a tab loads:

  * schema: `GET /{token}/v1/resources/{name}/schema`
  * rows: `GET /{token}/v1/resources/{name}/rows` (with paging/limits as a UI concern)

### Grid rendering

* Column headers follow schema field order.
* Cells display typed values as returned by the API (including computed values for formula-projected fields). ([bus-api SDD](./bus-api))
* Primary key fields are treated as identity fields for row operations; MVP SHOULD treat PK cells as non-editable to avoid “row identity changes” ambiguity.

### Editing and mutations

* Cell edits result in `PATCH /{token}/v1/resources/{name}/row/{pk}` with a minimal patch body.
* Add row uses `POST /{token}/v1/resources/{name}/rows`.
* Delete uses `DELETE /{token}/v1/resources/{name}/row/{pk}`.
* UI must surface deterministic error responses from the API (schema constraint failures, forbidden updates/deletes due to policy, read-only mode). ([bus-api SDD](./bus-api))

### Schema editing panel

* Schema inspection is always available.
* Mechanical schema edits call the dedicated schema endpoints (field add/remove/rename, key operations) and show the resulting schema after success. ([bus-api SDD](./bus-api))
* Destructive operations are refused unless explicitly forced per the underlying Bus Data behavior as exposed by the API.

### Validation

* “Validate sheet” triggers `POST /{token}/v1/resources/{name}/validate`.
* “Validate workbook” triggers `POST /{token}/v1/validate`.
* UI groups diagnostics by resource and row when present, preserving deterministic ordering. ([bus-api SDD](./bus-api))

### Formula modes

* Default: show computed values (no formula source).
* Toggle: include formula source by using the API’s opt-in mode (e.g. `include_formula_source=…` as defined by Bus API) and render source in a non-colliding way. ([bus-api SDD](./bus-api))

### Event stream and refresh

The UI subscribes to `GET /{token}/v1/events` (Server-Sent Events) as defined by [bus-api](./bus-api). When a mutation event is received (e.g. `resource.rows.created`, `resource.rows.updated`, `resource.schema.changed`), the UI refreshes or invalidates the affected resource tab or the resource list so that the user sees the change without manually refreshing. Events are emitted only for mutations performed through the embedded API (e.g. edits from the same UI session or from another client); changes made by the agent via Bus CLI or by external file edits do not produce events, so the user must refresh to see those. Manual refresh remains available in all cases.

### Agent chat (when enabled)

When the server is started with `--enable-agent`, the UI shows an optional chat panel (IDE-style). The user can hide or unhide this panel at runtime without restarting the server. In the chat, the user can ask the AI agent to perform operations; the agent has access to run Bus CLI tools in the workspace working directory, so requests can result in data changes, validation runs, or other Bus commands. After the agent performs mutating operations, the user can refresh the sheet view to see updated data. The chat and agent endpoints are not available when agent integration is disabled.

---

## Data Design

Bus Sheets introduces no new on-disk formats or persistent state. All persistent data remains BusDK workspace datasets: CSV files, beside-the-table schema JSON files, and an optional `datapackage.json`. The server holds no persistent state; all reads and writes go through the embedded [bus-api](./bus-api) and thus the [bus-data](./bus-data) stack.

---

## Assumptions and Dependencies

* AD-SHT-001 Bus API library is available and stable enough to embed as an in-process server core. ([bus-api SDD](./bus-api))
* AD-SHT-002 Workspaces live on the local filesystem; the workspace root is the security boundary, enforced by Bus API path safety rules. ([bus-api SDD](./bus-api))
* AD-SHT-003 Formula semantics are provided transitively via Bus Data → BFL; Bus Sheets does not require direct BFL integration. ([bus-bfl SDD](./bus-bfl))
* AD-SHT-004 When agent integration is enabled, the [bus-agent](./bus-agent) library is available and the agent execution context (workdir = workspace root) is allowed to run Bus CLI tools; agent runtimes (e.g. Cursor CLI, Codex) are configured or detected outside bus-sheets per bus-agent semantics.

---

## Security Considerations

Bus Sheets inherits Bus API’s MVP security model:

* Loopback binding by default. ([bus-api SDD](./bus-api))
* Capability URL token gates all UI and API routes. ([bus-api SDD](./bus-api))
* Optional HTTPS when operator provides cert+key (or TLS termination by an external proxy). ([bus-api SDD](./bus-api))
* Workspace root confinement: all operations remain workspace-relative and must not escape the root boundary. ([bus-api SDD](./bus-api))
* Logging should redact the token in request paths by default.

---

## Observability and Logging

Startup prints only the capability base URL to stdout. Diagnostics go to stderr. Logs SHOULD be stable (timestamps off by default) to keep outputs comparable in tests, consistent with Bus API’s deterministic posture. ([bus-api SDD](./bus-api))

---

## Error Handling and Resilience

Invalid CLI usage exits with code 2 and a concise usage error. Runtime failures return deterministic HTTP statuses and JSON error bodies from the embedded Bus API. Bus Sheets surfaces those errors in the UI without rewording away stable codes/fields.

Any request that fails must leave the workspace unchanged, relying on Bus API / Bus Data atomicity guarantees. ([bus-api SDD](./bus-api))

---

## Testing Strategy

* Unit tests:

  * token gating for UI + API (requests outside `/{token}/` are 404)
  * SPA fallback behavior under `/{token}/` does not intercept API routes
  * deterministic asset serving (no dependency on filesystem build output)
* Integration tests:

  * start server with fixed `--token` and fixed `--port`
  * load resources list and schema via HTTP and compare to Bus API responses
  * perform row add/update/delete via the UI backend endpoints and verify on-disk effects match Bus API behavior
  * verify read-only mode returns deterministic 403 on mutating operations ([bus-api SDD](./bus-api))

---

## Deployment and Operations

Not Applicable. The module ships as a single embedded binary for local use; no separate deployment or operational runbook is required beyond starting the server.

---

## Glossary and Terminology

**Workspace / workbook.** The selected workspace root directory opened by Bus Sheets; presented in the UI as a workbook with one tab per resource.

**Resource / sheet.** A CSV plus beside-the-table schema, exposed by [bus-api](./bus-api) and shown as a sheet tab. Resource discovery and ordering follow bus-api (and [bus-data](./bus-data)) conventions.

**Capability URL.** The printed base URL containing the unguessable path token; possession grants access in the MVP security model.

**Formula-projected view.** API-provided computed values for formula-enabled fields without writing back to CSV; opt-in mode can include formula source in a non-colliding representation.

**Agent chat / agent integration.** Optional IDE-style chat dialog backed by [bus-agent](./bus-agent). When enabled, the user can converse with an AI agent that runs with the workspace as working directory and has access to run Bus CLI tools, so the user can request operations and see resulting changes in the sheets view after refresh. Controllable at startup via `--enable-agent` and at runtime via hide/unhide of the chat panel.

**Event stream.** The [bus-api](./bus-api) event stream at `GET /{token}/v1/events` (Server-Sent Events) delivers mutation events for changes performed through the API. Bus Sheets subscribes to it and uses events to refresh the affected sheet or resource list so that API-originated changes appear without manual refresh. Changes made outside the API (e.g. by the agent running Bus CLI) do not produce events.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api">bus-api</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

* [bus-api](./bus-api)
* [bus-bfl](./bus-bfl)
* [bus-data](./bus-data)
* [bus-agent](./bus-agent)

### Document control

Title: bus-sheets module SDD
Project: BusDK
Document ID: `BUSDK-MOD-SHEETS`
Version: 2026-02-13
Status: Draft
Last updated: 2026-02-13
Owner: BusDK development team

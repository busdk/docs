---
title: "bus-factory — development assistant UI (SDD)"
description: "Software Design Document for bus-factory: local token-gated development UI with read-only public Go unit listing and AI panel shell."
---

## bus-factory — development assistant UI

### Introduction and Overview

`bus-factory` provides a local development assistant UI for BusDK module engineering work. The initial release focuses on deterministic, read-only code surface visibility and an AI assistant panel shell.

### Requirements

FR-FAC-001 Local web UI. The module MUST expose `serve` to run a local HTTP UI with loopback defaults.

FR-FAC-002 Token-gated routes. UI and API routes MUST be served under `/{token}/` capability path.

FR-FAC-003 Read-only public unit index. The module MUST expose a read-only API listing exported Go units from the selected workspace root.

FR-FAC-004 Public unit coverage. The listing MUST include exported functions, methods, types (including struct/interface classification), vars, and consts.

FR-FAC-005 Toggleable AI panel. The UI MUST provide a user-toggleable AI assistant panel shell.

FR-FAC-006 Deterministic output. Public unit API output ordering MUST be deterministic.

FR-FAC-007 Superproject module discovery. When root is a BusDK superproject, the API MUST expose detected `bus`/`bus-*` modules and UI MUST present module-first selection before unit inspection.

FR-FAC-008 Default action integration. The module MUST discover user-defined actions from `.bus/dev` and `.bus/run`.

FR-FAC-009 Action execution routing. Non-prompt actions MUST execute through dispatcher commands `bus dev {action}` and `bus run {action}` in selected module/workspace root.

FR-FAC-010 Prompt-action AI routing. `.txt` prompt actions MUST be routed to integrated AI panel input and MUST NOT be executed via `bus dev` or `bus run`.

FR-FAC-011 Browser-open parity. Serve startup MUST support local browser/webview auto-open by default and an explicit `--print-url` mode for script-first workflows.

FR-FAC-012 Approval mediation. The AI service MUST expose pending approval
requests in polling responses and MUST accept explicit approval decisions
(`accept`, `accept_for_session`, `decline`, `cancel`) through an API endpoint.

FR-FAC-013 Approval timeout and cancellation. Pending approvals MUST be cleared
deterministically when resolved, when request context is canceled, or when a
10-minute timeout elapses.

NFR-FAC-001 No network dependency for listing. Public unit indexing is local filesystem + parser only.

NFR-FAC-002 Scriptable CLI behavior. Missing/invalid CLI usage returns exit code 2 with concise stderr diagnostics.

NFR-FAC-003 Standard global flag and logging contract. CLI MUST support BusDK-standard global flags (`-h/-V/-v/-q/-C/-o/-f/--color`) and log-level semantics (`-v` info, `-vv` debug, `--quiet` suppresses non-error logs).

### System Architecture

`bus-factory` has three parts:

- CLI runner (`cmd/bus-factory` + `internal/run`) for command dispatch
- local HTTP serving (`internal/serve`) for token-gated UI + APIs
- public Go unit scanner (`internal/inspect`) for exported declaration indexing

UI root shell composition (header + business pane + toggleable AI pane) is
provided by shared `bus-ui` shell renderer so business-specific content can be
attached without duplicating shell structure per module.
The AI pane itself is rendered via shared `bus-ui` `RenderAIPanel` so
`bus-factory` and `bus-ledger` use the same AI view structure/components.
Frontend observability uses `/v1/client-log` so browser action/error events are
forwarded into server logs using shared `bus-ui` client-log endpoint handling.

### Component Design and Interfaces

Primary interfaces:

- `run.Run(args []string, stdout, stderr io.Writer) int`
- `serve.Start(cfg Config, stdout, stderr io.Writer) error`
- `serve.Handler(cfg Config) (http.Handler, string, error)`
- `inspect.ListPublicUnits(root string) ([]PublicUnit, error)`

Primary HTTP APIs:

- `GET /{token}/v1/modules`
- `GET /{token}/v1/public-units`
- `GET /{token}/v1/public-units?module=<name>`
- `GET /{token}/v1/actions`
- `GET /{token}/v1/actions?module=<name>`
- `POST /{token}/v1/actions/run`
- `GET /{token}/v1/ai/poll`
- `POST /{token}/v1/ai/approval/respond`

Approval lifecycle interface:

- App-server callback: `RequestApproval(ctx, req)` stores request metadata and
  emits `approval/requested`.
- Poll payload includes `pending_approvals` keyed by `request_id`.
- `POST /v1/ai/approval/respond` resolves `request_id` with one decision value
  and emits `approval/responded`.
- Unresolved requests return cancel on `ctx.Done()` or fixed 10-minute timeout.

### Data Design

Public unit records are emitted as JSON with:

- `kind`
- `name`
- `receiver` (methods only)
- `package`
- `file` (workspace-relative)
- `line`

AI poll payload also includes a `pending_approvals` object keyed by string
request ID. Each value carries the original approval `method` and raw `params`
for deterministic UI review and response.

### Sources

- [bus-factory module page](../modules/bus-factory)
- [Approval flow implementation](../../../bus-factory/internal/serve/ai.go)
- [Route wiring for approval endpoint](../../../bus-factory/internal/serve/server.go)

### Document control

Title: bus-factory module SDD  
Project: BusDK  
Document ID: BUSDK-MOD-FAC  
Version: 2026-03-01  
Status: Draft  
Last updated: 2026-03-01  
Owner: BusDK development team

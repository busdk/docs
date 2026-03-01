---
title: bus-ledger — deterministic accounting ledger projections (SDD)
description: Software design for bus-ledger as a deterministic projection engine over immutable journal data for Finnish accountant and auditor workflows.
---

# bus-ledger — deterministic accounting ledger projections (SDD)

## Introduction and Overview

`bus-ledger` is a projection module for accountant-grade and auditor-grade
ledger views over BusDK workspace datasets. The immutable journal is the only
source of truth for postings. `bus-ledger` does not mutate posted data and does
not persist hidden projection state. Every output row is a deterministic
projection from journal rows and module metadata in `bus-accounts`,
`bus-vat`, `bus-dimensions`, and period-lock information.

The module serves a local token-gated API and an embedded WASM frontend. The
frontend is an operator surface over the same read-only projections used by CLI
or export pipelines.

This design targets Finnish accounting workflows and evidence expectations for
`päiväkirja`, `pääkirja`, trial-balance diagnostics, VAT analysis, and
subledger monitoring. Statutory report generation remains in reporting modules,
but the ledger projections are the stable projection layer those reports depend
on.

## Requirements

FR-LED-001 Immutable source model. Posted journal entries are append-only and
projection output must be derived from journal data and metadata modules
without hidden mutable state.

FR-LED-002 Deterministic outputs. Projections must use stable ordering and
stable numeric formatting so repeated runs with identical inputs produce
identical outputs.

FR-LED-003 Double-entry safety. Voucher-level balancing must be guaranteed for
posted vouchers and diagnostics must surface imbalances before period lock.

FR-LED-004 List modes. The list view must provide at least two explicit modes:
day book (`päiväkirja`) and general ledger (`pääkirja`-style line listing).

FR-LED-005 Day book projection. Chronological voucher-oriented output must show
full debit/credit lines and preserve posting sequence.

FR-LED-006 General ledger projection. Account-oriented output must support
period filters and running balance calculation.

FR-LED-007 Subledger projections. AR, AP, fixed-asset, and loan subledgers
must be derivable from journal lines and operational references without custom
hidden tables.

FR-LED-008 VAT ledger projection. VAT-grouped output must support drill-down to
source lines by VAT code and period.

FR-LED-009 Dimensional projection. Ledger output must support filters by
dimension keys and values such as cost center and project.

FR-LED-010 Closing diagnostics. Projection layer must provide pre-close checks
for balancing, VAT consistency, required metadata, and period lock violations.

FR-LED-011 Audit trail projection. User actions and change history must be
queryable in ledger context for evidence workflows.

FR-LED-012 Performance. Projections must avoid repeated full-dataset scans in
hot paths and must use index-friendly iteration for large datasets.

FR-LED-013 Filtering. All projection APIs must support fiscal year, period,
account, dimension, VAT code, and counterparty filters where semantically
applicable.

FR-LED-014 Export suitability. Output structures must be dense tabular data
with stable columns suitable for PDF and spreadsheet generation.

FR-LED-015 Period lock awareness. Projections must include lock-state aware
diagnostics and reject write-like operations in locked periods.

FR-LED-016 Assistant thread continuity. When AI mode is enabled, thread
metadata and user-visible assistant messages must persist in
`.bus/bus-ledger/` so sessions can be resumed without replaying hidden system
bootstrap prompts into the user conversation view.

FR-LED-017 Assistant approvals and steering. Assistant actions that require
approval must be represented as explicit actionable items with deterministic
request identifiers. The control plane must support turn steering while the
turn is active and must reject malformed steer payloads with actionable
diagnostics.

FR-LED-018 Assistant attachment intake. The UI must support panel-wide
drag-and-drop attachment intake, stage dropped files for user confirmation
before send, and import accepted files into deterministic workspace-local
storage under `.bus/bus-ledger/`. When drag source metadata does not expose
filesystem paths, intake must still succeed through browser file-object upload.

FR-LED-019 Observability noise control. Server logging must support repeated
line collapsing for high-frequency duplicate log events while preserving
message order and readability via summary markers (`... and N more`).

FR-LED-020 Browser-to-server diagnostics. Browser runtime diagnostics from the
embedded UI must be forwardable to server logs through a token-gated API route
so embedded-webview issues can be investigated from server-side logs. This
includes explicit UI logger events and global browser error surfaces
(`window.error` and `unhandledrejection`).
AI account-state refresh and account/login event processing must also emit
explicit auth-detection rationale logs (including unresolved payload
diagnostics) so authentication-detection mismatches can be explained from
server logs.

FR-LED-021 Shared UI component usage. Generic assistant UI controls and generic
assistant text rendering must be consumed from `bus-ui` so `bus-ledger` keeps
only ledger-specific composition and behavior wiring.

FR-LED-022 Shared AI runtime state usage. Generic assistant runtime state
(thread/message/attachment/approval/event-tracking state) must be consumed from
`bus-ui` state objects so `bus-ledger` keeps only ledger-specific API payload
state and rendering composition.

## System Architecture

`bus-ledger` is a read-only projection engine layered on top of canonical
datasets and services.

The authoritative write boundary stays in journal and lock modules.
`bus-ledger` reads:
`journal + chart of accounts + VAT metadata + dimensions + lock metadata +
audit events`.

The internal architecture has three levels. The ingestion level resolves
workspace journal data through `bus-journal` APIs and normalizes rows into
typed posting structures. The projection level computes deterministic view rows
for each ledger type. The delivery level exposes projection results through
token-gated API routes and the embedded UI.

An optional assistant extension layer runs independently from projection logic.
When enabled, `bus-ledger` starts a workspace-scoped Codex app-server client
and exposes AI control routes under `v1/ai/*`. The assistant is a user
interface helper only and never becomes a source of accounting truth. Assistant
input supports both turn start and turn steering so users can submit new
messages while a turn is still running. The assistant control plane also
supports thread list/create/select operations so multiple issue-specific
threads can coexist in one workspace session.

Current routes:

- `/{token}/` frontend shell
- `/{token}/v1/transactions` day book list and list-mode selection endpoint
- `/{token}/v1/transactions/{index}` transaction detail projection
- `/{token}/v1/evidence` token-gated evidence file route
- `/{token}/v1/ai/*` optional assistant-control routes (status, login, turns,
  approvals, event stream polling, thread lifecycle including rename, drop import)
- `/{token}/v1/client-log` browser-to-server diagnostics ingress used by the
  embedded UI logger

Projection routes are intentionally read-only. No posting mutation endpoints are
hosted in `bus-ledger`.

## Component Design and Interfaces

`internal/ledger` resolves and normalizes journal rows into deterministic
transaction groupings and entry sequences. It contains grouping logic and
numeric-safe summarization primitives that are reused by projections.

`internal/server` contains projection handlers and filter routing. It maps
request mode and filter parameters to projection functions and returns stable
JSON shapes. It also serves safe evidence files constrained to workspace root.
The same layer owns assistant control handlers and client-log ingestion, and it
centralizes logging policy including duplicate-line collapse with summary
output for noisy repeated events.
CLI startup browser-open behavior is consumed from shared `bus-ui` helpers so
cross-platform opener command mapping is not duplicated in module runtime code.

`internal/ui/wasm` renders dense tabular projections and mode switches without
owning business rules. UI behavior must consume projection fields as-is and
must not introduce alternate accounting logic. In AI mode it manages
thread/list state, module-specific action routing, attachment intake flow, and
resilient asynchronous rendering with panic-safe wrappers. Generic UI
components and generic assistant text rendering are consumed from `bus-ui`
(`pkg/uikit`). Generic assistant runtime state is also consumed from
`bus-ui` (`AIConversationState`) so module-local state is limited to
ledger-specific projection payload state and wiring. AI refresh orchestration
is consumed through interface-based shared host wiring (`AIRefreshHost`) so
`bus-ledger` only provides module callbacks and rendering integration. Shared
WASM event wiring, DOM error-host rendering/binding, selector action binding,
drop-upload response decoding, and field/currency formatting helpers are also
consumed from `bus-ui` so `bus-ledger/internal/ui/wasm` remains focused on
ledger projection composition and module-specific API interactions. Shared
turn-start payload/state transition helpers are also consumed from `bus-ui` so
AI send behavior is not duplicated in module code. Shared drop-state reducers
and shared state-backed refresh-host adapter are consumed from `bus-ui` so
module code keeps only ledger-specific wiring/policy around imports and polling.
Approval and attachment-remove AI action handlers are consumed from `bus-ui`
shared helpers so DOM-target parsing and approval API dispatch stay consistent
across modules.
New/select/archive thread lifecycle actions are also consumed through shared
`bus-ui` helpers.
Send/model input normalization, drop import state transitions, href resolver
composition, and runtime service wiring are consumed through shared `bus-ui`
helpers (`ResolveAISendInput`, `ExecuteAIModelSet`,
`ExecuteAIPathDropImport`, `ExecuteAIFileDropImport`,
`BuildAIMessageHrefResolver`, `BuildEvidenceURLResolver`,
`IsEmbeddableEvidencePath`, `FindSelectedLine`, `ExecuteAISendAction`,
`NewAIRuntimeProfile`, `AIRuntime`, `NewAIDropController`,
`NewAIActionController`).
Generic app-level WASM runtime wiring (logger/error reporter/callback retention
and panic-safe async helpers) is consumed through shared `WASMAppScaffold`
from `bus-ui`.
Rendering
composition uses shared minimal function-component runtime primitives from
`bus-ui` (`RenderComponent`, `RenderCtx.Child`, `UseMemo`) to split large view
functions into deterministic composable units without introducing a virtual DOM.
The entry-load error fallback view is mounted through `bus-ui` compiled
template runtime via reusable mounted text-view helpers (`MountedTextView`) so
repeated error rerenders can update bound text slots without reconstructing the
full view shell. AI polling updates use shared event wiring callbacks and
controller-driven rerender flow through the same deterministic view composition
path as explicit route/action renders.
WASM runtime integration resolves browser globals through shared `bus-ui`
global accessor helpers instead of direct `js.Global()` calls, so tests can
swap global providers deterministically.
`bus-ledger` keeps browser-global reads at bootstrap/composition boundaries and
injects `document`/`location` dependencies into reusable units (controllers,
action handlers, view render helpers) through constructors or function
arguments, so unit logic is testable without implicit global lookups.
Module runtime service dependencies (gateway client, AI API client, client
logger, DOM error reporter, and drop import services) are centralized behind a
runtime struct (`uiRuntime`) and consumed through explicit methods so action
and drop units avoid ad-hoc package-level service globals.
Ledger list/detail projection fetches are routed through shared `bus-ui`
query scaffolding (`ProjectionQueryClient`) with module-local endpoint policy,
so WASM projection loading does not depend on direct scattered `http.Get`
calls. Shared list/detail DTO payload contracts are also consumed from
`bus-ui` so frontend and query layers reuse one typed projection wire model.
Route-selection parsing and AI panel/message render-prop adaptation are also
consumed through shared split-controller helpers in `bus-ui`, keeping
`bus-ledger` controllers focused on projection-specific data orchestration.
Ledger detail-load warnings are kept in ledger-local controller/view state and
rendered in the detail panel, while AI/runtime/action failures stay in the AI
panel error channel, so unrelated warning/error sources do not overwrite each
other.
WASM bootstrap now initializes a single app context owner (`appUI`) that
contains runtime services, AI/layout state objects, and controller instances,
and wires event callbacks directly to those injected instances for deterministic
lifecycle ownership from one place.
Bootstrap composition is split into focused wiring phases (`wireAI`,
`wireDrop`, `wireResize`) so listener lifecycle concerns are isolated from
startup orchestration logic.
Callback-handle retention and delegated AI action-click handler storage are
owned by shared `bus-ui` callback-registry state (`AICallbackRegistry`), while
runtime services (`uiRuntime`) are limited to
gateway/API/logging/error/drop service dependencies.
Listener/timer teardown ownership is explicit through shared disposer lifecycle
helpers: startup wiring registers disposers in `WASMAppScaffold` and app-level
cleanup releases all tracked listeners/timers/callbacks deterministically.
Browser lifecycle hooks (`beforeunload` and `pagehide`) now trigger the same
app cleanup path through shared `bus-ui` lifecycle wiring
(`WireWindowCloseLifecycle`), so production teardown follows the same
deterministic disposer flow as reusable host/test teardown.
Runtime and query services now receive API endpoint builders through injection
so transport/service units do not hardcode package-global route construction.
AI action logic is grouped behind a dedicated shared controller
(`AIActionController`) with method-based dispatch, so action wiring and
side-effect logic remain readable and dependency-injected instead of spread
across unrelated free functions.
Action dispatch routing table initialization is done once at controller
construction and reused for each event dispatch.
Action/drop/render call sites now consume logging and DOM error reporting via
app/controller-owned methods bound to the app context, replacing package-level
service-locator wrappers in WASM UI units.
Shared AI refresh host, drop handling, action dispatch, and mount click
delegation are now fully app-owned/injected so these UI units no longer depend
on package-level mutable runtime singletons.
Ledger view rendering uses controller phase separation (route parse, projection
load, render-prop assembly) and passes prebuilt AI render-message policy into
AI panel props so view helpers stay presentation-only.
Projection loading now reports selected-detail load failures explicitly to panel
state while preserving list rendering, so partial data degradation is visible
and test-guarded instead of silently ignored.
AI thread rename prompt and AI message link-resolution policy are injected into
controller flows, reducing browser-global dependencies inside action/render
units and improving test seams.
List/detail/line projection rendering now uses shared projection helpers from
`bus-ui`: split shell composition (`RenderSplitLayoutRoot`), projection list
panel view-model mapping (`BuildProjectionListPanelVM`), projection detail
presentation (`ProjectionDetailPresenter`), and projection query client setup
with route policies (`NewProjectionQueryClientForRoutes`). Evidence URLs are
resolved through an injected route-policy resolver shared by line panel and AI
message link resolution.
Theme behavior is also aligned through shared `bus-ui` CSS tokens served at
`assets/uikit.css`, including automatic light/dark detection via
`prefers-color-scheme`, while module CSS maps those shared tokens into
ledger-specific visual rules.

Assistant persistence and storage model:

- Thread and conversation persistence is stored under `.bus/bus-ledger/` in the
  workspace scope.
- Imported dropped files are stored under deterministic subpaths of
  `.bus/bus-ledger/` and referenced by metadata included in turn-start context.
- User-visible thread replay excludes hidden bootstrap/system prompt material.

Planned projection interfaces are stable module boundaries:

`ProjectDayBook(filters)`, `ProjectGeneralLedger(filters)`,
`ProjectTrialBalance(filters)`, `ProjectPeriodComparison(filters)`,
`ProjectDimensionalLedger(filters)`, `ProjectVATLedger(filters)`,
`ProjectSubledgerAR(filters)`, `ProjectSubledgerAP(filters)`,
`ProjectSubledgerAssets(filters)`, `ProjectSubledgerLoans(filters)`,
`ProjectAuditTrail(filters)`, `ProjectClosingDiagnostics(filters)`,
`ProjectCashLedger(filters)`.

Each projection returns deterministic tabular rows and a metadata envelope with
projection name, filter signature, and source signature.

## Data Design

Canonical posting inputs:

`JournalVoucher`: voucher identity, posting date, period, status, source
reference, and posting actor metadata.

`JournalLine`: account code, debit/credit values, currency, VAT code and VAT
amounts, dimension map, counterparty reference, due date, and operational
references (`invoice_id`, `asset_id`, `loan_id`, evidence path keys).

`PeriodLock`: fiscal year/period lock state and lock metadata used by
diagnostics and close checks.

Projection data is not persisted as mutable storage. Derived rows are computed
from source datasets per request with deterministic ordering:
`posting_date -> voucher_no -> voucher_id -> line_no -> line_id`.

Required indexes for scalable projection execution:

- posting sequence index by fiscal year, period, posting date, voucher identity
- account-first index for general ledger and running balance
- VAT code index for VAT ledger drill-down
- dimension key/value index for dimensional filters
- counterparty and due-date indexes for AR/AP projections
- operational id indexes for assets and loans
- audit event index by entity and timestamp

Optional acceleration can use deterministic period/account checkpoints for
opening balances, but checkpoints must be reproducible from journal data and
must not become hidden mutable truth.

## Projection Logic

Day book projection groups rows by voucher and keeps chronological posting
order. Output contains voucher header context and complete line list with debit
and credit values.

General ledger projection groups by account and period filter, then computes
opening, line movement, and running balance deterministically.

Trial balance projection aggregates by account and returns opening, debit
movement, credit movement, and closing in one fast table.

Period comparison projection computes opening, movement, and closing per
selected period for side-by-side diagnostics.

Dimensional ledger projection applies dimension predicates before aggregation
and preserves the same deterministic ordering contract as the general ledger.

VAT ledger groups rows by VAT code and period and provides drill-down row
references to source lines.

Subledger projections derive operational states from posting streams: AR/AP
open amounts and due dates from invoice-linked lines, fixed asset movement from
asset-linked lines, and loan principal/interest movement from loan-linked
lines.

Audit trail projection joins posting identifiers with audit events and emits
time-ordered user actions.

Closing diagnostics projection executes pre-lock checks over the filtered
posting domain and emits severity-coded findings.

Cash ledger projection filters to cash and bank account domains for a simplified
cash-based movement view while still preserving journal-derived determinism.

## Finnish Compliance Validation Rules

Posted voucher debit and credit totals must balance exactly. Period boundary
validation must prevent postings to invalid or locked periods. Account codes
must exist in chart-of-accounts metadata for posting date scope. VAT code
validation must enforce known code semantics and base/amount consistency.
Dimension values must exist in `bus-dimensions` definitions when dimensions are
used.

Projection exports must remain reproducible and stable for audit evidence and
court evidence workflows. Posted entries are never silently mutated; corrections
must be additive adjustments or reversals with traceable references.

## Example Output Structures

Day book row envelope:
`voucher_id, voucher_no, posting_date, description, lines[]` where each line
contains `line_no, account, debit, credit, vat_code, dimensions, evidence_ref`.

General ledger row:
`account, posting_date, voucher_no, description, debit, credit, running_balance`.

Trial balance row:
`account, opening, debit_movement, credit_movement, closing`.

VAT ledger row:
`period, vat_code, tax_base, vat_amount, gross, drilldown_refs`.

Closing diagnostics row:
`severity, code, message, voucher_id, line_id, account, period`.

## Assumptions and Dependencies

Workspace datasets are available through BusDK module APIs. `bus-ledger` reads
journal data via `bus-journal`, account metadata via `bus-accounts`, VAT
metadata via `bus-vat`, dimension metadata via `bus-dimensions`, and lock or
audit metadata through their owning modules when enabled.

The current implementation includes production day book and general-ledger list
mode projections and transaction/line drill-down. The remaining projection
families in this SDD are implementation targets and remain tracked as ongoing
module scope expansion. The AI assistant control plane is implemented as an
optional adjunct to projection browsing and does not alter projection
determinism or accounting-source authority boundaries.

## Glossary and Terminology

Day book means chronological journal projection (`päiväkirja`). General ledger
means account-centric posting projection (`pääkirja`). Subledger means
operationally scoped ledger view (AR, AP, assets, loans) derived from journal
references. Projection means deterministic read-only output computed from
canonical datasets.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-books">bus-books</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-dev">bus-dev</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ledger module page](../modules/bus-ledger)
- [bus-journal SDD](./bus-journal)
- [bus-accounts SDD](./bus-accounts)
- [bus-vat SDD](./bus-vat)
- [Standard global flags](../cli/global-flags)

### Document control

Title: bus-ledger module SDD  
Project: BusDK  
Document identifier: sdd/bus-ledger  
Version: 3  
Status: Draft  
Last updated: 2026-02-27  
Owner: BusDK maintainers

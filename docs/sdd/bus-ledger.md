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
  approvals, event stream polling)

Projection routes are intentionally read-only. No posting mutation endpoints are
hosted in `bus-ledger`.

## Component Design and Interfaces

`internal/ledger` resolves and normalizes journal rows into deterministic
transaction groupings and entry sequences. It contains grouping logic and
numeric-safe summarization primitives that are reused by projections.

`internal/server` contains projection handlers and filter routing. It maps
request mode and filter parameters to projection functions and returns stable
JSON shapes. It also serves safe evidence files constrained to workspace root.

`internal/ui/wasm` renders dense tabular projections and mode switches without
owning business rules. UI behavior must consume projection fields as-is and
must not introduce alternate accounting logic.

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
module scope expansion.

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
Version: 2  
Status: Draft  
Last updated: 2026-02-26  
Owner: BusDK maintainers

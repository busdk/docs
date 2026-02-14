---
title: Development status — BusDK modules
description: Evidence-based snapshot of what is usable today and what is missing across BusDK modules, grouped by use case (accounting, workbook UI, compliance, developer workflow, payroll, orphans), derived from tests and PLAN.md in each repository.
---

## Development status

This page summarizes the implementation state of each BusDK module using test evidence as the primary proof of readiness. A capability is treated as verified only when it is covered by at least one test (Go unit test or e2e script) in the module repository. Readiness is grouped by documented use cases so you can see what works today for each journey. Per-module detail, including the specific test files that prove each claim, is in each module’s CLI reference under **Development state**. Implement modules in **Depends on** before the dependent.

### Use cases

- [Accounting workflow](#accounting-workflow) — [Accounting workflow overview](../workflow/accounting-workflow-overview): End-to-end bookkeeping from repo init through master data, attachments, invoices and journal, bank import and reconcile, to period close (validate, VAT, close, lock, reports). Delivers a reviewable audit trail and script-friendly flow.
- [Inventory valuation and COGS postings](#inventory-valuation-and-cogs-postings) — [bus-inventory](../modules/bus-inventory): Inventory register, append-only stock movements, and deterministic as-of valuation outputs suitable for reporting and later posting.
- [Workbook and validated tabular editing](#workbook-and-validated-tabular-editing) — [bus-sheets](../modules/bus-sheets): Lightweight, local, web-based workbook that shows workspace datasets as spreadsheet-like tables, supports create and edit with strict schema validation, and can use formulas and scripted operations for reproducible, auditable calculations. The workbook is the generic entry point; Bus modules can later provide dedicated, task-specific screens that write to the same validated workspace data.
- [Finnish bookkeeping and tax-audit compliance](#finnish-bookkeeping-and-tax-audit-compliance) — [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): Audit trail, retention, VAT returns, and tax-audit pack. Delivers compliance with Finnish legal and tax-audit expectations.
- [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](#finnish-company-reorganisation-yrityssaneeraus--audit-and-evidence-pack) — [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): Audit-ready evidence pack from accounting data (statements or equivalents, interim snapshot, significant assets, creditor/debt and loan registry, budgets and cashflow); BusDK delivers a reviewable, deterministic audit trail in a Git workspace.
- [Developer module workflow](#developer-module-workflow) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config. Delivers consistent developer workflows for BusDK module contributors.
- [Finnish payroll handling (monthly pay run)](#finnish-payroll-handling-monthly-pay-run) — [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): Run monthly payroll from employee register to balanced posting intent; postings feed the journal and later bank reconciliation. Delivers traceable salary and withholding bookkeeping for a small company.
- [Orphan modules](#orphan-modules): Modules not yet mapped to a documented use case.

### Accounting workflow

The [Accounting workflow overview](../workflow/accounting-workflow-overview) describes the intended end-to-end bookkeeping flow: create repo and baseline, define master data (accounts, entities, period), register attachments, record invoices and journal postings, import bank data and reconcile, then validate, run VAT report/export, close and lock the period, and produce reports.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus](../modules/bus#development-state) | 50% (Primary journey) | Single entrypoint; delegates to `bus-<module>`; no-args and missing-subcommand verified. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [bus-init](../modules/bus-init#development-state) | 70% (Broadly usable) | Config-only or full baseline (config + 13 module inits); e2e proves step order and exclusions. | Follow-up e2e/unit refinements. | None known. |
| [bus-config](../modules/bus-config#development-state) | 70% (Broadly usable) | Create/update `datapackage.json` and accounting-entity settings; idempotent init. | Config library; set/get agent; E2E extensions. | None known. |
| [bus-accounts](../modules/bus-accounts#development-state) | 60% (Stable for one use case) | Init, add (all types), list, validate chart of accounts; e2e covers full workflow. | Init contract when both files exist; help `--type`. | None known. |
| [bus-entities](../modules/bus-entities#development-state) | 50% (Primary journey) | Init, add, list, validate counterparties; e2e proves init (incl. dry-run), add, list. | add flags; interactive parity. | None known. |
| [bus-period](../modules/bus-period#development-state) | 70% (Broadly usable) | Init, list, validate, close, lock; close artifacts and state transitions verified by e2e. | Append-only balance; init help; locked-period integrity. | None known. |
| [bus-attachments](../modules/bus-attachments#development-state) | 60% (Stable for one use case) | Init, add, list; idempotent init; evidence layout; e2e covers full workflow. | Workspace-relative paths in diagnostics. | None known. |
| [bus-journal](../modules/bus-journal#development-state) | 60% (Stable for one use case) | Init, add, balance; idempotent init; deterministic balance; e2e covers init/add/balance. | Period integrity; layout; audit fields; interactive add. | bus-period closed-period checks for full workflow. |
| [bus-invoices](../modules/bus-invoices#development-state) | 60% (Stable for one use case) | Init, validate, list; init dry-run; e2e covers init, validate, list. | add (header/lines); pdf; totals validation; E2E for add/pdf. | bus-pdf for `bus invoices pdf`. |
| [bus-bank](../modules/bus-bank#development-state) | 60% (Stable for one use case) | Init, import, list; idempotent init; e2e covers init and import. | Schema validation before append; counterparty_id; dry-run. | None known. |
| [bus-reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) | Help, version, flags; unit tests for run/flags. match/allocate/list not verified. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |
| [bus-validate](../modules/bus-validate#development-state) | 50% (Primary journey) | Workspace and resource validation; unit tests for run and type/constraint checks. | format; stdout/--output; help; min/max; audit and closed-period. | None known. |
| [bus-vat](../modules/bus-vat#development-state) | 70% (Broadly usable) | Init, validate, report, export; deterministic report/export; e2e covers VAT workflow. | Index update; dry-run; rate validation; journal input. | None known. |
| [bus-reports](../modules/bus-reports#development-state) | 50% (Primary journey) | Trial balance, account-ledger; unit tests for run, workspace load, report. No e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [bus-pdf](../modules/bus-pdf#development-state) | 60% (Stable for one use case) | Render from JSON (file); unit tests for run, render, templates. | Command-level test for `render --data @-`. | None known. |

### Inventory valuation and COGS postings

Define inventory items, record stock movements (purchases, sales or consumption, adjustments) as append-only rows with voucher references, and compute deterministic valuation outputs (FIFO or weighted-average) for an as-of date or period end that can feed reports and later journal postings for cost of goods sold.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) | Inventory register and append-only stock movements with voucher traceability; deterministic, auditable as-of valuation outputs for reporting and COGS postings. Run/flags and property tests; init/add/move/valuation not verified. | Add or extend e2e and unit tests to verify init, add, move, valuation and determinism; voucher traceability. | None known. |

### Workbook and validated tabular editing

As a BusDK workspace user you get a lightweight, local, web-based “workbook” that shows workspace datasets as spreadsheet-like tables and lets you create and edit rows with strict schema validation, so you can maintain reliable typed tabular data without accidentally breaking formats. Simple automation hooks — formula-projected fields and, when enabled, an agent that can run Bus CLI tools — support reproducible, auditable calculations and transformations. The workbook is the generic entry point; Bus modules can provide dedicated, task-specific screens that guide you through common workflows and still write to the same validated workspace data. The [bus-sheets](../modules/bus-sheets) module is the canonical implementation of this journey; it embeds [bus-api](../modules/bus-api) in-process and relies on [bus-data](../modules/bus-data) and [bus-bfl](../modules/bus-bfl) for schema, row operations, and formula semantics.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) | Local web UI over workspace; serve and capability URL verified by e2e. Workbook tabs, grid CRUD, schema panel, and validation UI not yet test-backed. | Embed Bus API in-process; embed UI assets; workbook tabs; grid row CRUD and schema panel; validation UI; optional agent chat; read-only mode; integration tests. | bus-api embed and UI assets required before the main user value (grid over workspace) is real. |
| [bus-api](../modules/bus-api#development-state) | 50% (Primary journey) | REST API over workspace; help, version, openapi, serve with token/port. Backend for bus-sheets and tools; row and schema endpoints. | Event stream; module endpoints; row CRUD and validation tests. | None known. |
| [bus-data](../modules/bus-data#development-state) | 60% (Stable for one use case) | Schema, package, table, and row operations; deterministic I/O; e2e and unit tests. Authoritative backend for bus-api (and thus bus-sheets). | Formula projection; range resolution for BFL. | None known. |
| [bus-bfl](../modules/bus-bfl#development-state) | 60% (Stable for one use case) | Parse, eval, render BFL; CLI and conformance verified by e2e and unit tests. Formula engine for bus-data formula-projected fields. | Range and array semantics in bus-data; formula source in API responses. | None known. |
| [bus-agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) | Detect runtimes, render prompts; help and version; global flags. When enabled in bus-sheets, optional chat so the user can ask the agent to run Bus CLI tools in the workspace. | Order/config; AGENTS.md; adapters; bus-sheets integration. | None known. |

The full journey — open workbook, edit rows with schema validation, see formula-projected values, and optionally run agent-driven operations — is not yet covered end-to-end by tests. Today you can start the bus-sheets server and receive a capability URL; the workbook grid, schema panel, and validation actions depend on the embedded API and UI assets that are planned next.

### Finnish bookkeeping and tax-audit compliance

The [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) page defines requirements for audit trail, retention, VAT, and tax-audit delivery. Modules that contribute to this use case overlap with the accounting workflow; the table below highlights readiness for the compliance-facing parts (VAT, close/lock, filing, tax-audit pack).

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-period](../modules/bus-period#development-state) | 70% (Broadly usable) | Close and lock periods; close artifacts; prevents post-close drift. | Append-only balance; locked-period integrity. | None known. |
| [bus-vat](../modules/bus-vat#development-state) | 70% (Broadly usable) | VAT report and export from invoice (and optionally journal) data; period returns. | Index update; journal input; posting/voucher refs. | None known. |
| [bus-validate](../modules/bus-validate#development-state) | 50% (Primary journey) | Workspace and resource validation for coherence before close/filing. | format; audit and closed-period checks. | None known. |
| [bus-reports](../modules/bus-reports#development-state) | 50% (Primary journey) | Trial balance and account-ledger; basis for statements and audit pack. | general-ledger; period; traceable line items (NFR-REP-001). | None known. |
| [bus-filing](../modules/bus-filing#development-state) | 50% (Primary journey) | Delegate to targets (prh, vero); unit tests for run, list_targets, flags. | Bundle assembly; tax-audit-pack; pass-through args test. | Stable bundle contract for filing targets. |
| [bus-filing-prh](../modules/bus-filing-prh#development-state) | 40% (Meaningful task, partial verification) | Bundle and validate for PRH; unit tests for run, bundle, sanitize. No e2e. | PRH content; SBR taxonomy; e2e; README links. | bus-filing bundle contract. |
| [bus-filing-vero](../modules/bus-filing-vero#development-state) | 40% (Meaningful task, partial verification) | Bundle for Vero; unit tests for app, bundle, output. No e2e. | E2E; source refs; prerequisites diagnostics. | bus-filing bundle contract. |

### Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack

The [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack) page describes the use case and evidence-pack scope. This journey is about assembling an audit-ready evidence pack for a restructuring or reorganisation context. It emphasises correctness and traceability of bookkeeping, explicit separation of snapshot reporting (baseline and interim) from ongoing operational postings, loan registry roll-forward and debt visibility, and budget or forecast and liquidity evidence. In practice the application or assessment typically expects recent financial statements or equivalent bookkeeping-based summaries (where no formal statements are required), an interim snapshot, a list of significant assets, and where applicable an independent auditor or expert report in debtor-led filings.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-period](../modules/bus-period#development-state) | 70% (Broadly usable) | Close and lock for snapshots; prevents post-review drift; baseline and interim cut-off. | Append-only balance; init help; locked-period integrity. | None known. |
| [bus-reports](../modules/bus-reports#development-state) | 50% (Primary journey) | Trial balance and ledger lines as audit evidence; basis for statements and schedules. No e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [bus-validate](../modules/bus-validate#development-state) | 50% (Primary journey) | Workspace and resource validation before assembling the evidence pack. | format; stdout/--output; help; min/max; audit and closed-period. | None known. |
| [bus-attachments](../modules/bus-attachments#development-state) | 60% (Stable for one use case) | Link source documents to records; traceability for audit. | Workspace-relative paths in diagnostics. | None known. |
| [bus-journal](../modules/bus-journal#development-state) | 60% (Stable for one use case) | Postings and balancing; audit trail for bookkeeping evidence. | Period integrity; layout; audit fields; interactive add. | bus-period closed-period checks for full workflow. |
| [bus-invoices](../modules/bus-invoices#development-state) | 60% (Stable for one use case) | Source transaction documents and validation for evidence pack. | add (header/lines); pdf; totals validation; E2E for add/pdf. | bus-pdf for `bus invoices pdf`. |
| [bus-bank](../modules/bus-bank#development-state) | 60% (Stable for one use case) | Import statements and transactions; basis for reconciliation evidence. | Schema validation before append; counterparty_id; dry-run. | None known. |
| [bus-reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) | Bank reconciliation as audit-critical evidence; match/allocate/list not verified. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |
| [bus-loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) | Loan registry as auditable schedule; roll-forward concept for creditor/debt visibility. Init/add verified; event/amortize not verified. | event, amortize; e2e. | None known. |
| [bus-budget](../modules/bus-budget#development-state) | 30% (Some basic commands) | Budget and variance as plausibility and going-concern evidence; init/report/add/set not verified. | Init, report, add, set; e2e. | None known. |
| [bus-assets](../modules/bus-assets#development-state) | 50% (Primary journey) | Asset schedule for significant-assets list; validate and post support traceability. No e2e for init/add. | e2e for init/add. | None known. |

### Developer module workflow

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. It supports contributors and automation working inside BusDK module repositories.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-dev](../modules/bus-dev#development-state) | 60% (Stable for one use case) | commit, work, spec, e2e, set; init creates Makefile, .cursor/rules, stubs; e2e proves flags and init. | Per-directory lock; remove -f; AGENTS.md assert; README. | None known. |
| [bus-agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) | Detect runtimes, render prompts; help and version; global flags. | Order/config; AGENTS.md; adapters; bus-sheets integration. | None known. |
| [bus-preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) | Get, set, set-json, unset, list preferences; key-path and format verified by e2e. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Finnish payroll handling (monthly pay run)

The [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run) page describes the journey from prerequisites (accounts, entity, periods) and employee register through a monthly pay run with pay date to balanced posting intent and onward into the journal and bank reconciliation. The table below lists the modules a user touches in this story and their readiness for it; test evidence in each module repository is the basis for the readiness claims.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-payroll](../modules/bus-payroll#development-state) | 40% (Meaningful task, partial verification) | Validate and export: integration tests in `run_test.go` prove validation of payroll datasets and deterministic export CSV for a run. Data layout is `payroll/` (employees, payruns, payments, posting_accounts). init, run, list, employee add/list are specified in CLI reference and SDD but not implemented; no e2e for full pay-run journey. | Align CLI and layout with docs (init, run, list, employee); e2e for run → export → journal. | None known. |
| [bus-accounts](../modules/bus-accounts#development-state) | 60% (Stable for one use case) | Chart of accounts for wage expense, withholding payable, net payable; e2e covers full workflow. | Init contract when both files exist; help `--type`. | None known. |
| [bus-entities](../modules/bus-entities#development-state) | 50% (Primary journey) | Party references for employees; e2e proves init, add, list. | add flags; interactive parity. | None known. |
| [bus-period](../modules/bus-period#development-state) | 70% (Broadly usable) | Period open/close/lock for payroll month and pay date; e2e verifies close and state. | Append-only balance; locked-period integrity. | None known. |
| [bus-journal](../modules/bus-journal#development-state) | 60% (Stable for one use case) | Append payroll posting output; init, add, balance verified by e2e. | Period integrity; layout; audit fields. | bus-period closed-period checks for full workflow. |
| [bus-bank](../modules/bus-bank#development-state) | 60% (Stable for one use case) | Import bank statements for pay-day transfers; e2e covers init and import. | Schema validation before append; dry-run. | None known. |
| [bus-reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) | Match bank rows to payroll-related journal entries; match/allocate/list not verified. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |

The full journey from empty workspace through employee register and `bus payroll run` to journal append is not yet covered by e2e tests. In practice, users can today maintain payroll data under `payroll/`, run `bus payroll validate` and `bus payroll export <run-id>`, and append the export output to the journal manually or via script; the automated run and employee add path remains planned.

### Orphan modules

These modules are not yet mapped to a documented use case. Bus-sheets, bus-api, bus-data, and bus-bfl are mapped to [Workbook and validated tabular editing](#workbook-and-validated-tabular-editing) above. Shown with overall completeness and value promise.

No orphan modules exist at the moment.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./module-repository-structure">Module repository structure and dependency rules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK SDD](../sdd)
- [Module CLI reference](../modules/index)
- [bus-sheets](../modules/bus-sheets) and [bus-sheets SDD](../sdd/bus-sheets)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Module repository structure and dependency rules](./module-repository-structure)
- Each module repository’s PLAN.md and tests in the BusDK superproject

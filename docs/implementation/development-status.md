---
title: Development status — BusDK modules
description: Evidence-based snapshot of what is usable today and what is missing across BusDK modules, grouped by use case and derived from tests and PLAN.md in each repository.
---

## Development status

This page summarizes the implementation state of each BusDK module using test evidence as the primary proof of readiness. A capability is treated as verified only when it is covered by at least one test (Go unit test or e2e script) in the module repository. Readiness is grouped by documented use cases so you can see what works today for each journey. Per-module detail, including the specific test files that prove each claim, is in each module’s CLI reference under **Development state**. Implement modules in **Depends on** before the dependent.

### Use cases

- [Accounting workflow](#accounting-workflow) — [Accounting workflow overview](../workflow/accounting-workflow-overview): End-to-end bookkeeping from repo init through master data, attachments, invoices and journal, bank import and reconcile, to period close (validate, VAT, close, lock, reports). Delivers a reviewable audit trail and script-friendly flow.
- [Finnish bookkeeping and tax-audit compliance](#finnish-bookkeeping-and-tax-audit-compliance) — [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): Audit trail, retention, VAT returns, and tax-audit pack. Delivers compliance with Finnish legal and tax-audit expectations.
- [Developer module workflow](#developer-module-workflow) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config. Delivers consistent developer workflows for BusDK module contributors.
- [Orphan modules](#orphan-modules): Modules not yet mapped to a documented use case.

---

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

---

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

---

### Developer module workflow

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. It supports contributors and automation working inside BusDK module repositories.

| Module | Readiness | Value | Planned next | Blocker |
|--------|-----------|-------|--------------|---------|
| [bus-dev](../modules/bus-dev#development-state) | 60% (Stable for one use case) | commit, work, spec, e2e, set; init creates Makefile, .cursor/rules, stubs; e2e proves flags and init. | Per-directory lock; remove -f; AGENTS.md assert; README. | None known. |
| [bus-agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) | Detect runtimes, render prompts; help and version; global flags. | Order/config; AGENTS.md; adapters; bus-sheets integration. | None known. |
| [bus-preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) | Get, set, set-json, unset, list preferences; key-path and format verified by e2e. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

---

### Orphan modules

These modules are not yet mapped to a documented use case, or they are infrastructure used by multiple journeys. Shown with overall completeness and value promise.

| Module | Completeness | Value | New use case? |
|--------|--------------|-------|---------------|
| [bus-data](../modules/bus-data#development-state) | 60% (Stable for one use case) | Schema/package/table/row operations; deterministic I/O; e2e and unit tests. | No; infra for bus-api and bus-sheets. |
| [bus-api](../modules/bus-api#development-state) | 50% (Primary journey) | REST API over workspace; help, version, openapi, serve with token/port. | No; used by bus-sheets and tools. |
| [bus-sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) | Start server and capability URL; global flags and version. e2e proves serve and version. | No; spreadsheet UI over workspace. |
| [bus-bfl](../modules/bus-bfl#development-state) | 60% (Stable for one use case) | Parse, eval, render BFL; CLI and conformance verified by e2e and unit tests. | No; formula engine for bus-data. |
| [bus-budget](../modules/bus-budget#development-state) | 30% (Some basic commands) | Unit tests for flags and variance logic; no e2e. Init/report/add/set not verified. | Optional accounting; workflow doc exists. |
| [bus-assets](../modules/bus-assets#development-state) | 50% (Primary journey) | validate, schedule, post; unit tests. No e2e for init/add. | Optional accounting (fixed assets). |
| [bus-loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) | Init, add; unit tests for run and flags. No e2e; event/amortize not verified. | Optional accounting (loans). |
| [bus-inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) | Run/flags and property tests; no e2e. Init/add/move/valuation not verified. | Optional accounting (inventory). |
| [bus-payroll](../modules/bus-payroll#development-state) | 40% (Meaningful task, partial verification) | Validate, export; unit tests for flags and run. No e2e for full payroll. | Optional accounting (payroll). |

---

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
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Module repository structure and dependency rules](./module-repository-structure)
- Each module repository’s PLAN.md and tests in the BusDK superproject

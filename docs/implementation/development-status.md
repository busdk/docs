---
title: Development status — BusDK modules
description: Evidence-based snapshot of what is usable today and what is missing across BusDK modules, grouped by use case (accounting, sale invoicing, workbook UI, compliance, developer workflow, payroll, orphans), derived from tests and PLAN.md in each repository.
---

## Development status

This page summarizes the implementation state of each BusDK module using test evidence as the primary proof of readiness. A capability is treated as verified only when it is covered by at least one test (Go unit test or e2e script) in the module repository. Readiness is grouped by documented use cases so you can see what works today for each journey. Per-module detail, including the specific test files that prove each claim, is in each module’s CLI reference under **Development state**. Implement modules in **Depends on** before the dependent.

### Use cases index

- [Accounting workflow](#accounting-workflow) — [Accounting workflow overview](../workflow/accounting-workflow-overview): create repo and baseline, define master data and evidence, record invoices and journal, import bank and reconcile, close period with validate/VAT/reports.
- [Sale invoicing (sending invoices to customers)](#sale-invoicing-sending-invoices-to-customers) — [Sale invoicing](../workflow/sale-invoicing): create sales invoices, render PDFs, and send to customers (outbound journey).
- [Inventory valuation and COGS postings](#inventory-valuation-and-cogs-postings) — [Inventory valuation and COGS](../workflow/inventory-valuation-and-cogs): define items, record movements with vouchers, compute as-of valuation for reporting and COGS postings.
- [Spreadsheet workbooks](#spreadsheet-workbooks) — [Workbook and validated tabular editing](../workflow/workbook-and-validated-tabular-editing): local web workbook over workspace datasets with schema-validated editing and formula projection.
- [Finnish bookkeeping and tax-audit compliance](#finnish-bookkeeping-and-tax-audit-compliance) — [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): audit trail, retention, VAT and periodic reporting, tax-audit pack.
- [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](#finnish-company-reorganisation-yrityssaneeraus--audit-and-evidence-pack) — [Finnish company reorganisation — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): evidence pack from accounting data for court-supervised reorganisation.
- [Developer module workflow with Cursor CLI](#developer-module-workflow-with-cursor-cli) — [Developer module workflow](../implementation/developer-module-workflow#developer-module-workflow-with-cursor-cli): scaffold modules, run plan/work/spec/e2e with Cursor.
- [Developer module workflow with Gemini CLI](#developer-module-workflow-with-gemini-cli) — [Developer module workflow](../implementation/developer-module-workflow#developer-module-workflow-with-gemini-cli): same workflow with Gemini runtime.
- [Developer module workflow with Claude CLI](#developer-module-workflow-with-claude-cli) — [Developer module workflow](../implementation/developer-module-workflow#developer-module-workflow-with-claude-cli): same workflow with Claude runtime.
- [Developer module workflow with Codex CLI](#developer-module-workflow-with-codex-cli) — [Developer module workflow](../implementation/developer-module-workflow#developer-module-workflow-with-codex-cli): same workflow with Codex runtime.
- [Finnish payroll handling (monthly pay run)](#finnish-payroll-handling-monthly-pay-run) — [Finnish payroll handling](../workflow/finnish-payroll-monthly-pay-run): employee register, monthly pay run, posting intent to journal, bank reconciliation.
- [Orphan modules](#orphan-modules) — Modules not mapped to a documented use case.

### Accounting workflow

See [Accounting workflow overview](../workflow/accounting-workflow-overview) for the intended flow. The end-user bookkeeping web UI for this flow is [books](../modules/bus-books#development-state) (design in [bus-books SDD](../sdd/bus-books)). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [books](../modules/bus-books#development-state) | 20% (Basic structure) — serve and capability URL verified by e2e; token gating, workspace checks, embedded API, default backends, minimal UI, read-only 403 by unit tests; no bookkeeping screen flow test-covered; user cannot complete any workflow step in the UI. | Inbox and core screens (Journal, Periods, VAT, Bank, Attachments, Validate); integration tests (PLAN.md). | None known. |
| [bus](../modules/bus#development-state) | 50% (Primary journey) – single entrypoint; no-args and missing-subcommand verified; e2e for dispatch would raise confidence. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [init](../modules/bus-init#development-state) | 70% (Broadly usable) – config-only or full baseline verified by e2e; step order and `--no-<module>` exclusions proven. | Help list each per-module flag and `--no-<module>` (PLAN.md). | None known. |
| [config](../modules/bus-config#development-state) | 90% (Broadly usable) – init and set verified by e2e and unit tests; workspace-config step complete; set no-flags no-op not verified. | Set no-flags no-op (no write, no message) per PLAN.md. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 70% (Broadly usable) – chart lifecycle and sole-proprietor verified; define-master-data step completable. | Document journal add regression test location or add when [journal](../modules/bus-journal) available (PLAN.md). | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list verified; user can define counterparties. | Go library path accessors (NFR-ENT-002). | None known. |
| [period](../modules/bus-period#development-state) | 90% — add/open/close/lock and year-rollover opening verified; user can complete period lifecycle. | Optional: automatic result-to-equity transfer at year end. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – Register evidence and list; init/add/list and workspace-relative diagnostics verified. | Go library path accessors (NFR-ATT-002); optional --dry-run (PLAN.md). | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – Record-postings and balance steps usable; init, add, balance, dry-run, NFR-JRN-001 verified. | Optional add-from-stdin (PLAN.md); README/help alignment. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [balances](../modules/bus-balances#development-state) | 60% (Stable) – Opening/cutover: user can complete init, add, import (incl. --allow-unknown-accounts), validate, list, apply and replace; e2e and unit tests verify effective-record, replace-marker, balanced transaction. | Optional: [period](../modules/bus-period) library; e2e bus journal validate when bus on PATH. | None known. |
| [invoices](../modules/bus-invoices#development-state) | 80% (Broadly usable) — record-invoices and postings step completable; init, add, validate (totals and VAT), list with all filters, postings verified by e2e and unit tests; pdf not verified in e2e. | Help alignment (add --due-date optional, init workspace root); optional attachment_id validation (FR-005). | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% — init and import verified by e2e; list with filters and TSV verified; user can complete bank step before reconcile. | Schema validation before append; counterparty_id; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 80% — reconciliation step completable; match, allocate, list and validation failures verified by unit and e2e. | Reject invoice status canceled in match (PLAN.md); bank path from [bank](../modules/bus-bank) Go library. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% — Run and schema/invariant checks verified; user can run pre-close validation and get pass/fail and diagnostics; format and empty stdout would complete contract. | format text/tsv; empty stdout and --output no-op; audit and closed-period. | None known. |
| [vat](../modules/bus-vat#development-state) | 80% (Broadly usable) – init (incl. --dry-run), validate (incl. rate check, vat_registered=false, --period, --source journal), report/export from invoice or journal with source_refs, index update, closed-period/--force, path API verified by e2e and unit tests; user can complete close-step VAT from either source. | None in PLAN.md. | None known. |
| [reports](../modules/bus-reports#development-state) | 90% (Broadly usable) – Trial-balance, general-ledger, profit-and-loss, balance-sheet, account-ledger with text/csv/json/markdown, KPA/PMA, TASE/tuloslaskelma PDF and `--layout` verified by e2e; user can complete report step. | None in PLAN.md. | None known. |
| [pdf](../modules/bus-pdf#development-state) | 70% — Render step verified; user can produce PDF from file/stdin; `bus invoices pdf` not in [invoices](../modules/bus-invoices). | None in PLAN.md. | None known. |

### Sale invoicing (sending invoices to customers)

See [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing) for the outbound journey: creating sales invoices, rendering PDFs, and sending them to customers. This is distinct from the accounting workflow, which also records incoming and third-party invoices. Module readiness for the sale-invoicing path:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [bus](../modules/bus#development-state) | 50% (Primary journey) – single entrypoint; no-args and missing-subcommand verified; e2e for dispatch would raise confidence. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [init](../modules/bus-init#development-state) | 70% (Broadly usable) – config-only or full baseline verified by e2e; step order and `--no-<module>` exclusions proven. | Help list each per-module flag and `--no-<module>` (PLAN.md). | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list verified; user can define customers. | Go library path accessors (NFR-ENT-002). | None known. |
| [accounts](../modules/bus-accounts#development-state) | 70% (Broadly usable) – chart for income/VAT accounts verified. | Document journal add regression test or add when [journal](../modules/bus-journal) available (PLAN.md). | None known. |
| [invoices](../modules/bus-invoices#development-state) | 80% (Broadly usable) — create, validate, list, postings verified; pdf step blocked by [pdf](../modules/bus-pdf). | Help alignment (add --due-date optional, init workspace root); optional attachment_id validation (FR-005). | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [pdf](../modules/bus-pdf#development-state) | 70% — PDF generation step verified; user can produce PDF from file/stdin; `bus invoices pdf` not in [invoices](../modules/bus-invoices). | None in PLAN.md. | None known. |

### Inventory valuation and COGS postings

See [Inventory valuation and COGS postings](../workflow/inventory-valuation-and-cogs). This use case covers defining inventory items, recording append-only movements with voucher references, and computing as-of valuation for reporting and COGS postings. Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) – validate, status, move (current CLI and inventory/ layout) verified by unit and e2e; init, add, valuation not implemented. | Root layout; init, add, move (SDD), valuation; e2e/unit tests for full journey. | None known. |

### Spreadsheet workbooks

See [Spreadsheet workbooks](../workflow/workbook-and-validated-tabular-editing). This use case covers a local web-based workbook over workspace datasets with schema-validated editing and formula projection. Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) — serve and capability URL verified by e2e; token gating by unit tests; grid, schema panel, validation UI not test-backed; no workbook journey step completable. | Embed [api](../modules/bus-api) in-process; UI assets; workbook tabs; grid CRUD and schema panel; validation UI. | [api](../modules/bus-api) embed and UI assets required before grid over workspace is real. |
| [api](../modules/bus-api#development-state) | 80% — User can complete API-driven discovery, CRUD, validation, schema read/mutation; event stream and read-only verified; stable key ordering for validate success pending. | Stable JSON key ordering for POST /resources/{name}/validate success (PLAN.md). | None known. |
| [data](../modules/bus-data#development-state) | 80% (Stable) — user can complete package/resource lifecycle, schema evolution, table and workbook-style read (cell/range, --header, --anchor-col/--anchor-row, --decimal-sep, --formula), and row mutate; workbook doc in SDD/CLI reference pending. | Document table workbook in SDD and CLI reference (KD-DAT-005). | None known. |
| [bfl](../modules/bus-bfl#development-state) | 60% (Stable) – parse, format, validate, eval, funcset list and CLI contract verified by e2e and unit tests; formula engine ready for [data](../modules/bus-data) projection. | Range and array semantics in data; formula source in API responses. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% — detect, render, set, format, run with Cursor stub and resolution order verified by e2e; optional sheets chat not test-backed. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |

### Finnish bookkeeping and tax-audit compliance

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit). Module readiness for the compliance-facing parts (VAT, close/lock, filing, tax-audit pack):

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 90% — close, lock, opening with append-only and locked state verified. | Optional: automatic result-to-equity at year end. | None known. |
| [vat](../modules/bus-vat#development-state) | 80% (Broadly usable) – VAT report and export from invoice or journal with voucher/invoice refs in output verified; index update, closed-period/--force, rate validation, validate --period and --source journal verified. | None in PLAN.md. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% — Workspace validation for coherence before close/filing verified; audit and closed-period would strengthen. | format text/tsv; empty stdout; audit and closed-period checks. | None known. |
| [reports](../modules/bus-reports#development-state) | 90% (Broadly usable) – Reports, traceability (basis in JSON), KPA/PMA, TASE/tuloslaskelma PDF verified by e2e; user can complete compliance report step. | None in PLAN.md. | None known. |
| [filing](../modules/bus-filing#development-state) | 60% (Stable) – delegation to prh/vero/tax-audit-pack, list, flags, pass-through, workdir/env verified by e2e and unit tests. | Bundle assembly or document delegation (FR-FIL-001); tax-audit-pack parameter set (OQ-FIL-001). | Stable bundle contract for filing targets. |
| [filing-prh](../modules/bus-filing-prh#development-state) | 50% — Validate and bundle from fixture verified by e2e and unit tests; PRH content and SBR taxonomy would complete filing. | PRH content in bundles (FR-PRH-002); SBR taxonomy in iXBRL; README links. | [filing](../modules/bus-filing) bundle contract. |
| [filing-vero](../modules/bus-filing-vero#development-state) | 50% — produce and verify Vero bundle from fixture; FR-VERO-002, NFR-VERO-001, NFR-VERO-002 verified by e2e and unit tests; full journey blocked by [filing](../modules/bus-filing#development-state) bundle contract. | Apply DOCS_UPDATE in docs repo (SDD Risks, pre-export layout, OQ-VERO-001 per PLAN.md). | [filing](../modules/bus-filing#development-state) bundle contract. |

### Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack

See [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 90% — close, lock, opening for snapshots verified. | Optional: automatic result-to-equity at year end. | None known. |
| [reports](../modules/bus-reports#development-state) | 90% (Broadly usable) – Trial balance and ledgers as audit evidence; KPA/PMA and TASE/tuloslaskelma PDF verified by e2e; user can produce evidence-pack reports. | None in PLAN.md. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% — Workspace validation before evidence pack verified; same gaps as accounting (format, empty stdout, audit/closed-period). | format text/tsv; empty stdout; audit and closed-period. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – Link source documents to records for audit; traceability verified. | Go library path accessors (NFR-ATT-002); optional --dry-run (PLAN.md). | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – Append path, balance, NFR-JRN-001 verified; audit columns in period CSV. | Optional add-from-stdin (PLAN.md); README/help alignment. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [invoices](../modules/bus-invoices#development-state) | 80% (Broadly usable) — invoice evidence-pack baseline verified; init, add, validate, list, postings verified; pdf not in journey. | Help alignment (add --due-date optional, init workspace root); optional attachment_id validation (FR-005). | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% — import and list verified; basis for reconciliation evidence. | Schema validation before append; counterparty_id; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 80% — reconciliation evidence path verified; match, allocate, list and validation failures verified. | Reject invoice status canceled in match (PLAN.md); bank path from [bank](../modules/bus-bank) Go library. | None known. |
| [loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) – loan registry, list, validate, balances, schedule, postings verified by unit and e2e; event and amortize not implemented. | event, amortize subcommands (PLAN.md); e2e for full journey. | None known. |
| [budget](../modules/bus-budget#development-state) | 30% (Some basic commands) – init, validate, variance verified; add/set/report and root layout not verified. | Root layout; report, add, set; e2e for report/add/set. | None known. |
| [assets](../modules/bus-assets#development-state) | 90% (Broadly usable) – init (incl. FR-INIT-004), add, validate, schedule, depreciate, dispose, post and path accessors verified; FR-AST-003, FR-AST-004 and dispose required-args verified by unit and e2e; user can complete asset lifecycle and produce postings for evidence pack. | None in PLAN.md. | None known. |

### Developer module workflow with Cursor CLI

See [Developer module workflow with Cursor CLI](./developer-module-workflow#developer-module-workflow-with-cursor-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 60% (Stable) — init, set, flags, context, pipeline list/preview verified by e2e; plan/work/spec/e2e/stage/commit and repo-local pipeline override by unit tests with stub agent; user can complete init and run workflow steps. | Top-level list (PLAN.md); action/script generate once [agent](../modules/bus-agent#development-state) exposes stdout API. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% — detect, render, set, run with Cursor stub and resolution order verified by e2e; user can select runtime and run a prompt. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Gemini CLI

See [Developer module workflow with Gemini CLI](./developer-module-workflow#developer-module-workflow-with-gemini-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) — same CLI; init and flags verified by e2e; run/work/spec/e2e with Gemini not test-covered. | Top-level list (PLAN.md); e2e work/spec/e2e with Gemini; action/script generate once [agent](../modules/bus-agent#development-state) exposes stdout API. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); set runtime gemini and BUS_AGENT=gemini tested; run with Gemini not exercised in e2e. | E2e that runs `run --agent gemini` with real or hermetic Gemini; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Claude CLI

See [Developer module workflow with Claude CLI](./developer-module-workflow#developer-module-workflow-with-claude-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) — same CLI; init and flags verified by e2e; run/work/spec/e2e with Claude not test-covered. | Top-level list (PLAN.md); e2e work/spec/e2e with Claude; action/script generate once [agent](../modules/bus-agent#development-state) exposes stdout API. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); run with Claude CLI not exercised in e2e. | E2e that runs `run --agent claude` with real or hermetic Claude; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Codex CLI

See [Developer module workflow with Codex CLI](./developer-module-workflow#developer-module-workflow-with-codex-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) — same CLI; init and flags verified by e2e; run/work/spec/e2e with Codex not test-covered. | Top-level list (PLAN.md); e2e work/spec/e2e with Codex; action/script generate once [agent](../modules/bus-agent#development-state) exposes stdout API. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); run with Codex CLI not exercised in e2e. | E2e that runs `run --agent codex` with real or hermetic Codex; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Finnish payroll handling (monthly pay run)

See [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [payroll](../modules/bus-payroll#development-state) | 20% (Validate and export only) – validate and export verified by e2e and unit tests with payroll/ layout; init, run, list, employee not implemented; user cannot complete pay-run journey. | Workspace-root layout; init, run, list, employee (PLAN.md); e2e run→export→journal. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 70% (Broadly usable) – chart lifecycle and sole-proprietor verified; user can define accounts prerequisite for wage expense, withholding, net payable. | E2E or README link for [journal](../modules/bus-journal) add regression; AGENTS.md update. | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list and `--id`/`--name` verified; user can define party references for employees. | Go library path accessors (NFR-ENT-002). | None known. |
| [period](../modules/bus-period#development-state) | 90% — period open/close/lock and opening for payroll month verified. | Optional: automatic result-to-equity at year end. | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – Posting path ready for payroll export; init, add, balance, closed-period reject verified. | Optional add-from-stdin (PLAN.md); README/help alignment. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [bank](../modules/bus-bank#development-state) | 60% — import and list verified for pay-day statement flow. | Schema validation before append; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 80% — payroll bank reconciliation step completable; match, allocate, list and validation failures verified. | Reject invoice status canceled in match (PLAN.md); bank path from [bank](../modules/bus-bank) Go library. | None known. |

The full journey from empty workspace through employee register and `bus payroll run` to journal append is not yet covered by e2e tests. Users can today maintain payroll data under `payroll/` (by hand or another tool), run `bus payroll validate` and `bus payroll export <run-id>`, and append the export output to the journal manually or via script; init, run, list, and employee add/list are not implemented.

### Orphan modules

Modules not mapped to any documented use case appear here with overall completeness, value promise, and whether a new use case document should be added. Module names are shown without the `bus-` prefix and linked to the module CLI reference.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [replay](../modules/bus-replay#development-state) | 90% — Full snapshot export and apply verified by golden and e2e; roundtrip and idempotency when bus on PATH; in-process apply for config/accounts add. | None in PLAN.md. | None known. |
| [run](../modules/bus-run#development-state) | 60% — Define/list/set/unset and run script token and pipeline; stop-on-first-failure, path escape, ambiguity, disabled script, expansion limits verified; prompt run stub-only. | Document script execution method for .sh/.bat/.ps1 (PLAN.md). | None known. |

**replay:** 90% overall. Journey: user can export workspace to a deterministic replay log and apply it into a clean workspace for migration and parity; full accounting snapshot export and apply verified by golden and e2e; roundtrip and idempotency when bus on PATH. No new use case doc needed — operator/automation tool, not a step in a documented end-user workflow.

**run:** 60% overall. Value promise: run user-defined prompt actions, script actions, and pipelines by name with a single entrypoint. Journey: user can define/list/set/unset and run script tokens and pipelines; context, list, pipeline preview, management commands, stop-on-first-failure, path escape, ambiguity, disabled script, and expansion limits verified by unit and e2e tests; prompt run verified with stub agent only. No new use case doc needed — generic runner, not journey-specific.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./regulated-report-pdfs">Regulated report PDFs (TASE and tuloslaskelma)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK SDD](../sdd)
- [Module CLI reference](../modules/index)
- [bus-sheets](../modules/bus-sheets) and [bus-sheets SDD](../sdd/bus-sheets)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing)
- [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Module repository structure and dependency rules](./module-repository-structure)
- Each module repository’s PLAN.md and tests in the BusDK superproject

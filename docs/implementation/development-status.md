---
title: Development status — BusDK modules
description: Evidence-based snapshot of what is usable today and what is missing across BusDK modules, grouped by use case (accounting, sale invoicing, workbook UI, compliance, developer workflow, payroll, orphans), derived from tests and PLAN.md in each repository.
---

## Development status

This page summarizes the implementation state of each BusDK module using test evidence as the primary proof of readiness. A capability is treated as verified only when it is covered by at least one test (Go unit test or e2e script) in the module repository. Readiness is grouped by documented use cases so you can see what works today for each journey. Per-module detail, including the specific test files that prove each claim, is in each module’s CLI reference under **Development state**. Implement modules in **Depends on** before the dependent.

### Accounting workflow

See [Accounting workflow overview](../workflow/accounting-workflow-overview) for the intended flow. Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [bus](../modules/bus#development-state) | 50% (Primary journey) – single entrypoint; no-args and missing-subcommand verified; e2e for dispatch would raise confidence. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [init](../modules/bus-init#development-state) | 70% (Broadly usable) – config-only or full baseline verified by e2e; step order and `--no-<module>` exclusions proven. | Help list each per-module flag and `--no-<module>` (PLAN.md). | None known. |
| [config](../modules/bus-config#development-state) | 70% (Broadly usable) – init and configure verified by e2e and unit tests; idempotent init and deterministic entity updates; set/get agent and config library not implemented. | Config library and set agent / get agent (PLAN.md). | None known. |
| [accounts](../modules/bus-accounts#development-state) | 60% (Stable) – init, add (all five types), list, validate and init contract verified; e2e covers full chart workflow; user can complete define-master-data chart step. | Optional SDD follow-ups. | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list verified by e2e and unit tests; user can define counterparties for the workflow. | None in PLAN; optional SDD follow-ups. | None known. |
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) — init, open, list, validate, close, lock verified; merge-conflict and non-Git hints would complete. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – Register evidence and list; init/add/list and workspace-relative diagnostics verified. | None in PLAN. | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – init, add, balance, period integrity and layout/audit columns verified; interactive add not verified. | Optional: interactive add. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [invoices](../modules/bus-invoices#development-state) | 60% (Stable) – init, validate, list verified by e2e and unit tests; user can bootstrap and list; add and pdf not implemented. | add (header/lines); pdf; totals validation; E2E for add/pdf. | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% — init and import verified by e2e; list with filters and TSV verified; user can complete bank step before reconcile. | Schema validation before append; counterparty_id; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – help, version, flags verified; match/allocate/list not verified. | match, allocate, list; journal linking; command-level tests. | Missing verified match/allocate blocks reconciliation step. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation; unit tests for run and type/constraint checks. | format; stdout/--output; audit and closed-period checks. | None known. |
| [vat](../modules/bus-vat#development-state) | 70% (Broadly usable) – init, validate, report, export; e2e covers VAT workflow; deterministic output. | Index update; dry-run; rate validation; journal input. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance, account-ledger; unit tests for run and report; no e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [pdf](../modules/bus-pdf#development-state) | 70% (Broadly usable) – render from file and stdin verified by e2e and unit tests; list-templates, flags, overwrite, chdir verified. | None in PLAN. | None known. |

### Sale invoicing (sending invoices to customers)

See [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing) for the outbound journey: creating sales invoices, rendering PDFs, and sending them to customers. This is distinct from the accounting workflow, which also records incoming and third-party invoices. Module readiness for the sale-invoicing path:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [bus](../modules/bus#development-state) | 50% (Primary journey) – single entrypoint; no-args and missing-subcommand verified; e2e for dispatch would raise confidence. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [init](../modules/bus-init#development-state) | 70% (Broadly usable) – config-only or full baseline verified by e2e; step order and `--no-<module>` exclusions proven. | Help list each per-module flag and `--no-<module>` (PLAN.md). | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list verified by e2e and unit tests; user can define customers (counterparties) for invoicing. | None in PLAN; optional SDD follow-ups. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 60% (Stable) – init, add (all five types), list, validate and init contract verified; e2e covers full chart workflow; revenue accounts for invoice lines. | Optional SDD follow-ups. | None known. |
| [invoices](../modules/bus-invoices#development-state) | 60% (Stable) – init, validate, list verified by e2e and unit tests; user can bootstrap and list; add and pdf not implemented. | add (header/lines); pdf; totals validation; E2E for add/pdf. | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [pdf](../modules/bus-pdf#development-state) | 70% (Broadly usable) – render from file and stdin verified by e2e and unit tests; list-templates, flags, overwrite, chdir verified. | None in PLAN. | None known. |

### Inventory valuation and COGS postings

See [Inventory valuation and COGS postings](../workflow/inventory-valuation-and-cogs). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) – validate, status, move (current CLI and inventory/ layout) verified by unit and e2e; init, add, valuation not implemented. | Root layout; init, add, move (SDD), valuation; e2e/unit tests for full journey. | None known. |

### Spreadsheet workbooks

See [Spreadsheet workbooks](../workflow/workbook-and-validated-tabular-editing). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) – serve and capability URL verified by e2e; grid, schema panel, validation UI not test-backed. | Embed API in-process; UI assets; workbook tabs; grid CRUD and schema panel; validation UI. | [api](../modules/bus-api) embed and UI assets required before grid over workspace is real. |
| [api](../modules/bus-api#development-state) | 50% — Startup, capability URL, healthz, openapi, event stream verified; resources/rows/schema/validation not test-covered. | bus-data integration and e2e for resources, rows, schema, validation; module endpoints. | None known. |
| [data](../modules/bus-data#development-state) | 60% (Stable) – schema, package, table, row and formula projection verified by e2e and unit tests; backend for [api](../modules/bus-api) and [sheets](../modules/bus-sheets). | Resource add/remove/rename; schema key and foreign-key commands; field remove/rename (PLAN.md). | None known. |
| [bfl](../modules/bus-bfl#development-state) | 60% (Stable) – parse, format, validate, eval, funcset list and CLI contract verified by e2e and unit tests; formula engine ready for [data](../modules/bus-data) projection. | Range and array semantics in data; formula source in API responses. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% — detect, render, set, format, run with Cursor stub and resolution order verified by e2e; optional sheets chat not test-backed. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |

### Finnish bookkeeping and tax-audit compliance

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit). Module readiness for the compliance-facing parts (VAT, close/lock, filing, tax-audit pack):

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) — close and lock with append-only and locked state verified. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [vat](../modules/bus-vat#development-state) | 70% (Broadly usable) – VAT report and export from invoice (and optionally journal) data. | Index update; journal input; posting/voucher refs. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation for coherence before close/filing. | format; audit and closed-period checks. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance and account-ledger; basis for statements and audit pack. | general-ledger; period; traceable line items (NFR-REP-001). | None known. |
| [filing](../modules/bus-filing#development-state) | 60% (Stable) – delegation to prh/vero/tax-audit-pack, list, flags, pass-through, workdir/env verified by e2e and unit tests. | Bundle assembly or document delegation (FR-FIL-001); tax-audit-pack parameter set (OQ-FIL-001). | Stable bundle contract for filing targets. |
| [filing-prh](../modules/bus-filing-prh#development-state) | 50% — Validate and bundle from fixture verified by e2e and unit tests; PRH content and SBR taxonomy would complete filing. | PRH content in bundles (FR-PRH-002); SBR taxonomy in iXBRL; README links. | [filing](../modules/bus-filing) bundle contract. |
| [filing-vero](../modules/bus-filing-vero#development-state) | 50% (Primary journey) – export and verify from fixture verified by e2e and unit tests; user can produce and verify a Vero bundle. | Source refs (FR-VERO-002); prerequisites diagnostics. | [filing](../modules/bus-filing) bundle contract. |

### Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack

See [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) — close and lock for snapshots verified. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance and ledger as audit evidence; no e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation before assembling evidence pack. | format; stdout/--output; audit and closed-period. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – Link source documents to records for audit; traceability verified. | None in PLAN. | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – postings, balancing, period reject and audit columns verified. | Optional: interactive add. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [invoices](../modules/bus-invoices#development-state) | 60% (Stable) – init and validation verified; list supports evidence-pack baseline; add and pdf not implemented. | add (header/lines); pdf; totals validation; E2E for add/pdf. | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% — import and list verified; basis for reconciliation evidence. | Schema validation before append; counterparty_id; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – match/allocate/list not verified; blocks reconciliation evidence. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |
| [loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) – loan registry, list, validate, balances, schedule, postings verified by unit and e2e; event and amortize not implemented. | event, amortize subcommands (PLAN.md); e2e for full journey. | None known. |
| [budget](../modules/bus-budget#development-state) | 30% (Some basic commands) – init, validate, variance verified; add/set/report and root layout not verified. | Root layout; report, add, set; e2e for report/add/set. | None known. |
| [assets](../modules/bus-assets#development-state) | 50% (Primary journey) – validate, schedule, post verified; posting and schedule support evidence pack; init/add not implemented. | init, add, depreciate, dispose (SDD CLI); root layout; --dry-run. | None known. |

### Developer module workflow with Cursor CLI

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows with Cursor CLI: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. Cursor runs from the repository root so its native AGENTS.md loading applies. **E2e coverage:** `bus-dev` `tests/e2e_bus_dev.sh` proves init (AGENTS.md, Makefile, `.cursor/rules`, stubs), flags, set, invalid `--agent`, per-directory lock, context catalog and `--output`, post-init restrictions (only plan/spec/work/e2e), and pipeline list builtin; `bus-agent` `tests/e2e_bus_agent.sh` proves detect, render, help, version, and **run with Cursor** (stub executable in PATH; stderr mentions cursor). Work/spec/e2e with a real Cursor CLI are not run in e2e. Runtime behavior is defined in the [bus-agent](../modules/bus-agent) CLI reference under “Project instructions (AGENTS.md)”.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 60% (Stable) – user can init module root, set agent/run-config, use flags and context, list builtin pipelines, run plan/work/spec/e2e/stage/commit (e2e + unit with stub agent). | action/script generate once [agent](../modules/bus-agent) exposes stdout API; AGENTS.md assert; README. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% — detect, render, set, run with Cursor stub and resolution order verified by e2e; user can select runtime and run a prompt. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Gemini CLI

See [Developer module workflow with Gemini CLI](./developer-module-workflow#developer-module-workflow-with-gemini-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI; init and flags verified by e2e; run/work/spec/e2e with Gemini not tested. | E2e that runs work/spec/e2e with Gemini; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); set runtime gemini and BUS_AGENT=gemini tested; run with Gemini not exercised in e2e. | E2e that runs `run --agent gemini` with real or hermetic Gemini; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Claude CLI

See [Developer module workflow with Claude CLI](./developer-module-workflow#developer-module-workflow-with-claude-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI; init and flags verified by e2e; run/work/spec/e2e with Claude not tested. | E2e that runs work/spec/e2e with Claude; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); run with Claude CLI not exercised in e2e. | E2e that runs `run --agent claude` with real or hermetic Claude; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Codex CLI

See [Developer module workflow with Codex CLI](./developer-module-workflow#developer-module-workflow-with-codex-cli). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI; init and flags verified by e2e; run/work/spec/e2e with Codex not tested. | E2e that runs work/spec/e2e with Codex; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% — detect/selection contract only (e2e stub); run with Codex CLI not exercised in e2e. | E2e that runs `run --agent codex` with real or hermetic Codex; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Finnish payroll handling (monthly pay run)

See [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run). Module readiness:

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [payroll](../modules/bus-payroll#development-state) | 20% (Validate and export only) – validate and export verified by e2e and unit tests with payroll/ layout; init, run, list, employee not implemented; user cannot complete pay-run journey. | Workspace-root layout; init, run, list, employee (PLAN.md); e2e run→export→journal. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 60% (Stable) – chart of accounts for wage expense, withholding, net payable; e2e and unit tests cover full workflow; user can define accounts prerequisite. | Optional SDD follow-ups. | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list and `--id`/`--name` aliases verified by e2e and unit tests; user can define party references for employees. | None in PLAN; optional SDD follow-ups. | None known. |
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) — period open/close/lock for payroll month verified. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [journal](../modules/bus-journal#development-state) | 70% (Broadly usable) – append posting path verified; init, add, balance, closed-period reject verified. | Optional: interactive add. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [bank](../modules/bus-bank#development-state) | 60% — import and list verified for pay-day statement flow. | Schema validation before append; dry-run for init. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – match/allocate/list not verified; blocks payroll bank reconciliation. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |

The full journey from empty workspace through employee register and `bus payroll run` to journal append is not yet covered by e2e tests. Users can today maintain payroll data under `payroll/` (by hand or another tool), run `bus payroll validate` and `bus payroll export <run-id>`, and append the export output to the journal manually or via script; init, run, list, and employee add/list are not implemented.

### Orphan modules

Modules not mapped to any documented use case appear here with overall completeness, value promise, and whether a new use case document should be added. Module names are shown without the `bus-` prefix and linked to the module CLI reference.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [run](../modules/bus-run#development-state) | 50% (Primary journey) – context, pipeline/action/script list and set/unset (repo), run script token, global flags; e2e and unit tests. Run with prompt (agent) and stop-on-first-failure not verified. | Unit test for run sequence stop-on-first-failure (PLAN.md). | None known. |

**run:** 50% overall. Value promise: run user-defined prompt actions, script actions, and pipelines by name with a single entrypoint. No new use case doc needed — generic runner, not journey-specific.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./developer-module-workflow">Developer module workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
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

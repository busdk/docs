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
- [Developer module workflow with Cursor CLI](#developer-module-workflow-with-cursor-cli) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config with Cursor CLI; **only developer runtime with e2e coverage** (init, flags, set, agent detect and run stub).
- [Developer module workflow with Gemini CLI](#developer-module-workflow-with-gemini-cli) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config with Gemini CLI; repo-local `.gemini` context. Not exercised in e2e.
- [Developer module workflow with Claude CLI](#developer-module-workflow-with-claude-cli) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config with Claude Code; per-run AGENTS.md injection. Not exercised in e2e.
- [Developer module workflow with Codex CLI](#developer-module-workflow-with-codex-cli) — [bus-dev](../modules/bus-dev): Scaffold modules, commit/work/spec/e2e, set agent and run-config with Codex; repo-local CODEX_HOME. Not exercised in e2e.
- [Finnish payroll handling (monthly pay run)](#finnish-payroll-handling-monthly-pay-run) — [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): Run monthly payroll from employee register to balanced posting intent; postings feed the journal and later bank reconciliation. Delivers traceable salary and withholding bookkeeping for a small company.
- [Orphan modules](#orphan-modules): Modules not yet mapped to a documented use case.

### Accounting workflow

The [Accounting workflow overview](../workflow/accounting-workflow-overview) describes the intended end-to-end bookkeeping flow: create repo and baseline, define master data (accounts, entities, period), register attachments, record invoices and journal postings, import bank data and reconcile, then validate, run VAT report/export, close and lock the period, and produce reports.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [bus](../modules/bus#development-state) | 50% (Primary journey) – single entrypoint; no-args and missing-subcommand verified; e2e for dispatch would raise confidence. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [init](../modules/bus-init#development-state) | 70% (Broadly usable) – config-only or full baseline (config + 13 inits); e2e proves step order and exclusions. | Follow-up e2e/unit refinements. | None known. |
| [config](../modules/bus-config#development-state) | 70% (Broadly usable) – create/update datapackage and entity settings; idempotent init verified. | Config library; set/get agent; E2E extensions. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 60% (Stable) – init, add (all types), list, validate; e2e covers full chart workflow; init contract and --type help implemented. | Optional SDD follow-ups. | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – init, add, list verified; user can define counterparties for the workflow. | None in PLAN; optional SDD follow-ups. | None known. |
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) – init, list, validate, close, lock; append-only close/lock and balanced-journal check verified by e2e. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – init, add, list; idempotent init and evidence layout; e2e covers full workflow. | Workspace-relative paths in diagnostics. | None known. |
| [journal](../modules/bus-journal#development-state) | 60% (Stable) – init, add, balance and NFR-JRN-001 closed-period reject verified by e2e and unit tests; layout and audit fields not verified. | Layout (journals.csv/journal-YYYY); audit fields; interactive add. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [invoices](../modules/bus-invoices#development-state) | 60% (Stable) – init, validate, list; e2e covers init, validate, list; add/pdf not verified. | add (header/lines); pdf; totals validation; E2E for add/pdf. | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% (Stable) – init, import, list; e2e covers init and import. | Schema validation before append; counterparty_id; dry-run. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – help, version, flags verified; match/allocate/list not verified. | match, allocate, list; journal linking; command-level tests. | Missing verified match/allocate blocks reconciliation step. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation; unit tests for run and type/constraint checks. | format; stdout/--output; audit and closed-period checks. | None known. |
| [vat](../modules/bus-vat#development-state) | 70% (Broadly usable) – init, validate, report, export; e2e covers VAT workflow; deterministic output. | Index update; dry-run; rate validation; journal input. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance, account-ledger; unit tests for run and report; no e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [pdf](../modules/bus-pdf#development-state) | 60% (Stable) – render from JSON (file); unit tests for run, render, templates. | Command-level test for `render --data @-`. | None known. |

### Inventory valuation and COGS postings

Define inventory items, record stock movements (purchases, sales or consumption, adjustments) as append-only rows with voucher references, and compute deterministic valuation outputs (FIFO or weighted-average) for an as-of date or period end that can feed reports and later journal postings for cost of goods sold.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) – run/flags and property tests verified; init, add, move, valuation not verified. | e2e and unit tests for init, add, move, valuation and determinism; voucher traceability. | None known. |

### Workbook and validated tabular editing

As a BusDK workspace user you get a lightweight, local, web-based “workbook” that shows workspace datasets as spreadsheet-like tables and lets you create and edit rows with strict schema validation, so you can maintain reliable typed tabular data without accidentally breaking formats. Simple automation hooks — formula-projected fields and, when enabled, an agent that can run Bus CLI tools — support reproducible, auditable calculations and transformations. The workbook is the generic entry point; Bus modules can provide dedicated, task-specific screens that guide you through common workflows and still write to the same validated workspace data. The [bus-sheets](../modules/bus-sheets) module is the canonical implementation of this journey; it embeds [bus-api](../modules/bus-api) in-process and relies on [bus-data](../modules/bus-data) and [bus-bfl](../modules/bus-bfl) for schema, row operations, and formula semantics.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) – serve and capability URL verified by e2e; grid, schema panel, validation UI not test-backed. | Embed API in-process; UI assets; workbook tabs; grid CRUD and schema panel; validation UI. | [api](../modules/bus-api) embed and UI assets required before grid over workspace is real. |
| [api](../modules/bus-api#development-state) | 50% (Primary journey) – help, version, openapi, serve with token/port; row and schema endpoints. | Event stream; module endpoints; row CRUD and validation tests. | None known. |
| [data](../modules/bus-data#development-state) | 60% (Stable) – schema, package, table, row operations; e2e and unit tests; backend for api and sheets. | Formula projection; range resolution for BFL. | None known. |
| [bfl](../modules/bus-bfl#development-state) | 60% (Stable) – parse, eval, render BFL; CLI and conformance verified by e2e and unit tests. | Range and array semantics in data; formula source in API responses. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) – detect runtimes, render prompts; help, version, global flags verified. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |

The full journey — open workbook, edit rows with schema validation, see formula-projected values, and optionally run agent-driven operations — is not yet covered end-to-end by tests. Today you can start the bus-sheets server and receive a capability URL; the workbook grid, schema panel, and validation actions depend on the embedded API and UI assets that are planned next.

### Finnish bookkeeping and tax-audit compliance

The [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) page defines requirements for audit trail, retention, VAT, and tax-audit delivery. Modules that contribute to this use case overlap with the accounting workflow; the table below highlights readiness for the compliance-facing parts (VAT, close/lock, filing, tax-audit pack).

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) – close and lock periods; append-only and balanced-journal check verified by e2e. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [vat](../modules/bus-vat#development-state) | 70% (Broadly usable) – VAT report and export from invoice (and optionally journal) data. | Index update; journal input; posting/voucher refs. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation for coherence before close/filing. | format; audit and closed-period checks. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance and account-ledger; basis for statements and audit pack. | general-ledger; period; traceable line items (NFR-REP-001). | None known. |
| [filing](../modules/bus-filing#development-state) | 50% (Primary journey) – delegate to targets (prh, vero); unit tests for run, list_targets, flags. | Bundle assembly; tax-audit-pack; pass-through args test. | Stable bundle contract for filing targets. |
| [filing-prh](../modules/bus-filing-prh#development-state) | 40% (Meaningful task, partial verification) – bundle and validate for PRH; unit tests for run, bundle, sanitize; no e2e. | PRH content; SBR taxonomy; e2e; README links. | [filing](../modules/bus-filing) bundle contract. |
| [filing-vero](../modules/bus-filing-vero#development-state) | 40% (Meaningful task, partial verification) – bundle for Vero; unit tests for app, bundle, output; no e2e. | E2E; source refs; prerequisites diagnostics. | [filing](../modules/bus-filing) bundle contract. |

### Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack

The [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack) page describes the use case and evidence-pack scope. This journey is about assembling an audit-ready evidence pack for a restructuring or reorganisation context. It emphasises correctness and traceability of bookkeeping, explicit separation of snapshot reporting (baseline and interim) from ongoing operational postings, loan registry roll-forward and debt visibility, and budget or forecast and liquidity evidence. In practice the application or assessment typically expects recent financial statements or equivalent bookkeeping-based summaries (where no formal statements are required), an interim snapshot, a list of significant assets, and where applicable an independent auditor or expert report in debtor-led filings.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) – close and lock for snapshots; append-only and balanced-journal check verified. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [reports](../modules/bus-reports#development-state) | 50% (Primary journey) – trial balance and ledger as audit evidence; no e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [validate](../modules/bus-validate#development-state) | 50% (Primary journey) – workspace and resource validation before assembling evidence pack. | format; stdout/--output; audit and closed-period. | None known. |
| [attachments](../modules/bus-attachments#development-state) | 60% (Stable) – link source documents to records; traceability for audit. | Workspace-relative paths in diagnostics. | None known. |
| [journal](../modules/bus-journal#development-state) | 60% (Stable) – postings, balancing, and closed-period reject verified; audit trail fields planned. | Layout; audit fields; interactive add. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [invoices](../modules/bus-invoices#development-state) | 60% (Stable) – source transaction documents and validation for evidence pack. | add (header/lines); pdf; totals validation; E2E for add/pdf. | [pdf](../modules/bus-pdf) for `bus invoices pdf`. |
| [bank](../modules/bus-bank#development-state) | 60% (Stable) – import statements and transactions; basis for reconciliation evidence. | Schema validation before append; counterparty_id; dry-run. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – match/allocate/list not verified; blocks reconciliation evidence. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |
| [loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) – loan registry; init/add verified; event/amortize not verified. | event, amortize; e2e. | None known. |
| [budget](../modules/bus-budget#development-state) | 30% (Some basic commands) – init/report/add/set not verified. | Init, report, add, set; e2e. | None known. |
| [assets](../modules/bus-assets#development-state) | 50% (Primary journey) – asset schedule for significant-assets list; validate and post; no e2e for init/add. | e2e for init/add. | None known. |

### Developer module workflow with Cursor CLI

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows with Cursor CLI: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. Cursor runs from the repository root so its native AGENTS.md loading applies. **E2e coverage:** `bus-dev` `tests/e2e_bus_dev.sh` proves init (AGENTS.md, Makefile, `.cursor/rules`, stubs), flags, set, invalid `--agent`, per-directory lock, context catalog and `--output`, post-init restrictions (only plan/spec/work/e2e), and pipeline list builtin; `bus-agent` `tests/e2e_bus_agent.sh` proves detect, render, help, version, and **run with Cursor** (stub executable in PATH; stderr mentions cursor). Work/spec/e2e with a real Cursor CLI are not run in e2e. Runtime behavior is defined in the [bus-agent](../modules/bus-agent) CLI reference under “Project instructions (AGENTS.md)”.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 60% (Stable) – commit, work, spec, e2e, set; init creates Makefile, .cursor/rules, stubs; e2e proves flags, init, per-directory lock, context, pipeline list builtin, and post-init restrictions. | action/script generate (bus-agent stdout API); AGENTS.md assert; README. | None known. |
| [agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) – detect, render, run with Cursor (stub) verified by e2e; stderr mentions cursor. | Order/config; AGENTS.md; adapters; sheets integration. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Gemini CLI

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows with Gemini CLI: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. Gemini may rely on repo-local `.gemini/settings.json` and `.geminiignore` so AGENTS.md is discovered as intended (additive merges only; no user-global Gemini edits). **Not exercised in e2e:** no test runs bus-dev or bus-agent with Gemini; only the generic detect/selection contract is tested (e2e uses stubs; run with real Gemini is untested).

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI as Cursor; init and flags verified only for Cursor-oriented e2e; run/work/spec/e2e with Gemini not tested. | E2e that runs work/spec/e2e with Gemini; per-directory lock; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% (Some basic commands) – detect/selection contract only (e2e stub); set runtime gemini and BUS_AGENT=gemini tested; run with real Gemini not exercised. | E2e that runs `run --agent gemini` with real or hermetic Gemini; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Claude CLI

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows with Claude Code: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. Claude prefers per-run injection of AGENTS.md (with a clearly marked, additive repo-local shim as fallback). **Not exercised in e2e:** no test runs bus-dev or bus-agent with Claude; only the generic detect/selection contract is tested; run with real Claude CLI is untested.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI as Cursor; init and flags verified only for Cursor-oriented e2e; run/work/spec/e2e with Claude not tested. | E2e that runs work/spec/e2e with Claude; per-directory lock; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% (Some basic commands) – detect/selection contract only; run with real Claude CLI not exercised in e2e. | E2e that runs `run --agent claude` with real or hermetic Claude; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Developer module workflow with Codex CLI

The [bus-dev](../modules/bus-dev) module is the canonical entry for developer workflows with Codex: scaffold new modules, run commit/work/spec/e2e, and set agent and run-config. Codex runs with repo-local state (e.g. CODEX_HOME set to a repo-local directory) so no global state is used or mutated; AGENTS.md is discovered natively when the workdir is the repo root. **Not exercised in e2e:** no test runs bus-dev or bus-agent with Codex; only the generic detect/selection contract is tested; run with real Codex CLI is untested.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [dev](../modules/bus-dev#development-state) | 30% (Some basic commands) – same CLI as Cursor; init and flags verified only for Cursor-oriented e2e; run/work/spec/e2e with Codex not tested. | E2e that runs work/spec/e2e with Codex; per-directory lock; AGENTS.md assert. | None known. |
| [agent](../modules/bus-agent#development-state) | 30% (Some basic commands) – detect/selection contract only; run with real Codex CLI not exercised in e2e. | E2e that runs `run --agent codex` with real or hermetic Codex; order/config; adapters. | None known. |
| [preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) – get, set, set-json, unset, list; key-path and format verified by e2e (runtime-agnostic). | Key-path validation for list; canonical JSON; path resolution tests. | None known. |

### Finnish payroll handling (monthly pay run)

The [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run) page describes the journey from prerequisites (accounts, entity, periods) and employee register through a monthly pay run with pay date to balanced posting intent and onward into the journal and bank reconciliation. The table below lists the modules a user touches in this story and their readiness for it; test evidence in each module repository is the basis for the readiness claims.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [payroll](../modules/bus-payroll#development-state) | 40% (Meaningful task, partial verification) – validate and export verified by integration tests; init, run, list, employee not implemented; no e2e for full pay-run. | Align CLI and layout with docs (init, run, list, employee); e2e for run → export → journal. | None known. |
| [accounts](../modules/bus-accounts#development-state) | 60% (Stable) – chart of accounts for wage expense, withholding, net payable; e2e covers full workflow; init contract and --type help implemented. | Optional SDD follow-ups. | None known. |
| [entities](../modules/bus-entities#development-state) | 50% (Primary journey) – party references for employees verified; init, add, list and add aliases covered by e2e. | None in PLAN; optional SDD follow-ups. | None known. |
| [period](../modules/bus-period#development-state) | 70% (Broadly usable) – period open/close/lock for payroll month and pay date; e2e verifies close, lock, and balanced-journal check. | Merge-conflict surface; non-Git workspace hint. | None known. |
| [journal](../modules/bus-journal#development-state) | 60% (Stable) – append posting output; init, add, balance and closed-period reject verified by e2e. | Layout; audit fields. | [period](../modules/bus-period) writing closed-period file for full workflow. |
| [bank](../modules/bus-bank#development-state) | 60% (Stable) – import bank statements for pay-day transfers; e2e covers init and import. | Schema validation before append; dry-run. | None known. |
| [reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) – match/allocate/list not verified; blocks payroll bank reconciliation. | match, allocate, list; journal linking; tests. | Missing verified match/allocate blocks reconciliation step. |

The full journey from empty workspace through employee register and `bus payroll run` to journal append is not yet covered by e2e tests. In practice, users can today maintain payroll data under `payroll/`, run `bus payroll validate` and `bus payroll export <run-id>`, and append the export output to the journal manually or via script; the automated run and employee add path remains planned.

### Orphan modules

Modules not mapped to any documented use case appear here with overall completeness, value promise, and whether a new use case document should be added. Module names are shown without the `bus-` prefix and linked to the module CLI reference.

| Module | Readiness | Biggest next | Biggest blocker |
|--------|-----------|--------------|-----------------|
| [run](../modules/bus-run#development-state) | 50% (Primary journey) – context, pipeline/action/script list and set/unset (repo), run script token, global flags; e2e and unit tests. Run with prompt (agent) and stop-on-first-failure not verified. | Unit test for run sequence stop-on-first-failure (PLAN.md). | None known. |

**run:** 50% overall. Value promise: run user-defined prompt actions, script actions, and pipelines by name with a single entrypoint. No new use case doc needed — generic runner, not journey-specific.

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

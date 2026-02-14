---
title: Development status — BusDK modules
description: Evidence-based snapshot of what is usable today and what is missing across BusDK modules, derived from tests and PLAN.md in each repository.
---

## Development status

This page summarizes the implementation state of each BusDK module using test evidence as the primary proof of readiness. A capability is treated as verified only when it is covered by at least one test (Go unit test or e2e script) in the module repository. Per-module detail, including the specific test files that prove each claim, is in each module’s CLI reference under **Development state**. Implement modules in the **Depends on** column before the dependent.

### By module

| Module | Completeness | Value | Planned next | Blocker |
|--------|--------------|-------|--------------|---------|
| [bus](../cli/command-structure#development-state) | 50% (Primary journey) | Dispatcher delegates to `bus-<module>` and orchestrates `bus init`; no-args and missing-subcommand behavior verified by unit tests. | E2E for dispatch; `bus help` when bus-help missing. | None known. |
| [bus-init](../modules/bus-init#development-state) | 70% (Broadly usable) | Initialize workspace config only or full baseline (config + 13 module inits) with optional exclusions. | Follow-up e2e/unit refinements. | None known. |
| [bus-config](../modules/bus-config#development-state) | 70% (Broadly usable) | Create and update `datapackage.json` and accounting-entity settings; idempotent init. | Config library; `set`/`get agent`; E2E extensions. | None known. |
| [bus-data](../modules/bus-data#development-state) | 60% (Stable for one use case) | Schema and resource operations: init, show, patch; table and package validation; deterministic I/O. | `--resource`; extended resource ops; bus-api integration. | None known. |
| [bus-api](../modules/bus-api#development-state) | 50% (Primary journey) | Serve REST API over workspace; help, version, openapi; serve with token and port. | bus-data integration; security/TLS; E2E against API. | bus-data integration for full resource semantics. |
| [bus-sheets](../modules/bus-sheets#development-state) | 20% (Basic structure) | Start local web server and get capability URL; global flags and version. | Embed Bus API; workbook UI; grid CRUD; validation UI. | bus-api embed and UI assets. |
| [bus-dev](../modules/bus-dev#development-state) | 60% (Stable for one use case) | Developer scaffold: commit, work, spec, e2e, set; init creates Makefile, .cursor/rules, stubs. | Per-directory lock; remove `-f`; AGENTS.md assert; README. | None known. |
| [bus-agent](../modules/bus-agent#development-state) | 40% (Meaningful task, partial verification) | Detect runtimes, render prompts; help and version; global flags. | Order/config; AGENTS.md; adapters; bus-sheets integration. | None known. |
| [bus-preferences](../modules/bus-preferences#development-state) | 70% (Broadly usable) | Get, set, set-json, unset, list preferences; key-path and format behavior verified. | Key-path validation for list; canonical JSON; path resolution tests. | None known. |
| [bus-bfl](../modules/bus-bfl#development-state) | 60% (Stable for one use case) | Parse, eval, render BFL expressions; CLI flags and help; conformance and eval behavior. | CI; `eval` exit 2 for missing `--context`. | None known. |
| [bus-accounts](../modules/bus-accounts#development-state) | 60% (Stable for one use case) | Init, add (all account types), list, validate chart of accounts; e2e covers full workflow. | Init contract when both files exist; help `--type`; income/revenue alignment. | None known. |
| [bus-entities](../modules/bus-entities#development-state) | 50% (Primary journey) | Init, add, list, validate counterparties; init idempotent and add/list verified by e2e. | `add` flags; interactive parity; workspace-root layout. | None known. |
| [bus-period](../modules/bus-period#development-state) | 70% (Broadly usable) | Init, list, validate, close, lock; balance and close artifacts; e2e covers period lifecycle. | Append-only balance; close/lock refinements; init help. | None known. |
| [bus-journal](../modules/bus-journal#development-state) | 60% (Stable for one use case) | Init, add, balance; idempotent init; deterministic balance output; e2e covers init/add/balance. | Period integrity; layout; audit fields; interactive add. | bus-period closed-period checks for full workflow. |
| [bus-attachments](../modules/bus-attachments#development-state) | 60% (Stable for one use case) | Init, add, list; idempotent init; evidence file layout; e2e covers full workflow. | Workspace-relative paths in diagnostics. | None known. |
| [bus-invoices](../modules/bus-invoices#development-state) | 60% (Stable for one use case) | Init, validate, list with filters; init dry-run; e2e covers init, validate, list. | `add` (header/lines); `pdf`; totals validation; E2E for add/pdf. | bus-pdf for `bus invoices pdf`. |
| [bus-vat](../modules/bus-vat#development-state) | 70% (Broadly usable) | Init, validate, report, export; deterministic report/export; e2e covers VAT workflow. | Index update; dry-run; rate validation; journal input. | None known. |
| [bus-bank](../modules/bus-bank#development-state) | 60% (Stable for one use case) | Init, import, list; idempotent init; e2e covers init and import. | Schema validation before append; counterparty_id; dry-run. | None known. |
| [bus-reconcile](../modules/bus-reconcile#development-state) | 30% (Some basic commands) | Help, version, global flags; unit tests for run/flags. No e2e; match/allocate/list not verified. | match, allocate, list; journal linking; dataset location; tests. | Missing verified match/allocate blocks reconciliation workflow. |
| [bus-assets](../modules/bus-assets#development-state) | 50% (Primary journey) | Validate, schedule, post; unit tests for run, flags, schedule/post logic. No e2e for init/add. | Root layout; init, add, depreciate, dispose; dry-run. | None known. |
| [bus-loans](../modules/bus-loans#development-state) | 40% (Meaningful task, partial verification) | Init, add; unit tests for run and flags. No e2e; event/amortize not verified. | event, amortize; idempotent init; root layout; ref validation; tests. | None known. |
| [bus-inventory](../modules/bus-inventory#development-state) | 30% (Some basic commands) | Run/flags and property tests; no e2e. Init/add/move/valuation not verified. | quiet/verbose; root layout; init, add, move, valuation. | None known. |
| [bus-payroll](../modules/bus-payroll#development-state) | 40% (Meaningful task, partial verification) | Validate, export; unit tests for flags and run. No e2e for full payroll run. | Scope vs docs; README; `--no-color` test. | None known. |
| [bus-budget](../modules/bus-budget#development-state) | 30% (Some basic commands) | Unit tests for flags and variance logic; no e2e. Init/report/add/set not verified. | Help; root layout; init; report, add, set. | None known. |
| [bus-reports](../modules/bus-reports#development-state) | 50% (Primary journey) | Trial balance, account-ledger; unit tests for run, workspace load, report. No e2e. | general-ledger; period; stable format; budget; KPA/PMA. | None known. |
| [bus-validate](../modules/bus-validate#development-state) | 50% (Primary journey) | Workspace and resource validation; unit tests for run and type/constraint checks. | format; stdout/--output; help; min/max; audit and closed-period. | None known. |
| [bus-pdf](../modules/bus-pdf#development-state) | 60% (Stable for one use case) | Render from JSON (file); unit tests for run, render, templates. | Command-level test for `render --data @-`. | None known. |
| [bus-filing](../modules/bus-filing#development-state) | 50% (Primary journey) | Delegate to target executables; unit tests for run, list_targets, flags. | Bundle assembly; params; targets doc; pass-through args test. | Stable bundle contract for filing targets. |
| [bus-filing-prh](../modules/bus-filing-prh#development-state) | 40% (Meaningful task, partial verification) | Bundle and validate workflows; unit tests for run, bundle, sanitize. No e2e. | PRH content; SBR taxonomy; e2e; README links. | bus-filing bundle contract. |
| [bus-filing-vero](../modules/bus-filing-vero#development-state) | 40% (Meaningful task, partial verification) | Bundle workflows; unit tests for app, bundle, output. No e2e. | E2E; source refs; prerequisites diagnostics. | bus-filing bundle contract. |

### Overall picture

Readiness is driven by what tests actually prove. Modules with e2e scripts that cover the main user flow (init, add, list, validate or equivalent) score in the 60–70% range; those with only unit tests for run/flags or partial flows score 30–50%. The spreadsheet UI (bus-sheets) and reconciliation (bus-reconcile) have the largest gap between documented scope and verified behavior. The accounting workflow in [Accounting workflow overview](../workflow/accounting-workflow-overview) is partially supported: init, master data (accounts, entities), period control, attachments, journal, invoices, bank, VAT, and reports have meaningful verified coverage; reconcile, filing targets, and bus-sheets need more test-backed work. The authoritative source for what remains per module is each repository’s PLAN.md.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./module-repository-structure">Module repository structure and dependency rules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation conventions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK SDD](../sdd)
- [Module CLI reference](../modules/index)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Module repository structure and dependency rules](./module-repository-structure)
- Each module repository’s PLAN.md and tests in the BusDK superproject

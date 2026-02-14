---
title: Development status — BusDK modules
description: Snapshot of implementation state for each BusDK module and the Bus as a whole, derived from each repository’s PLAN.md.
---

## Development status

This page summarizes the implementation state of each BusDK module as tracked in each repository’s PLAN.md. Those plans list prioritized, unchecked work items verified against the module SDD and CLI reference; completed work is not listed. The snapshot below shows how much remains per module and where the focus lies. The authoritative source for up-to-date detail is each module’s PLAN.md in the superproject. Components that have no PLAN.md are listed separately as unknown state — they may be finished or may have untracked remaining work.

### Priority and dependencies

Some modules depend on others for implementation (Go library calls) or for correct end-to-end behavior (workflow and dataset contracts). Implementing or stabilizing the dependency first unblocks the dependent module and avoids rework.

**Library implementation order.** [bus-data](../modules/bus-data) is the shared mechanical layer: it has no Go dependency on other bus-* modules and owns workspace dataset and schema semantics. [bus-api](../modules/bus-api) must call the bus-data library only (no CLI invocation) for all workspace endpoints; its PLAN explicitly adds bus-data as a Go dependency and implements endpoints by calling that library. So bus-data (and [bus-bfl](../modules/bus-bfl), which bus-data uses for formula validation and projection) should be implemented or stabilized before bus-api can deliver full parity. [bus-sheets](../modules/bus-sheets) embeds the Bus API in-process and delegates all data and schema operations to it; bus-sheets therefore depends on bus-api (and transitively bus-data). Implementing in the order bus-data → bus-api → bus-sheets allows each layer to build and test against a stable backend. [bus-config](../modules/bus-config) provides a Go library with GetDefaultAgent / SetDefaultAgent that [bus-agent](../modules/bus-agent) and the CLI use for default agent selection; finishing the bus-config library and `set agent` / `get agent` makes agent default behavior consistent across tools.

**Workflow and dataset order.** Domain modules integrate through [shared datasets and schemas](../architecture/independent-modules), not through Go imports. For workflows to behave correctly, some ordering still helps. [bus-init](../modules/bus-init) orchestrates config init and then each module’s init; each module’s init contract (idempotent when both dataset and schema exist, clear failure when only one exists) should be in place so `bus init all` is reliable. [bus-period](../modules/bus-period) owns open/close/lock state; [bus-journal](../modules/bus-journal) enforces period integrity (reject postings in closed periods), and [bus-reports](../modules/bus-reports), [bus-vat](../modules/bus-vat), and the filing modules all assume period and journal data are present and, where relevant, periods closed. So stabilizing period and journal (including append-only period control and journal layout per SDD) unblocks reports, VAT, and filing. [bus-reconcile](../modules/bus-reconcile) match/allocate depends on [bus-bank](../modules/bus-bank) datasets and on [bus-invoices](../modules/bus-invoices) or journal data. [bus-filing](../modules/bus-filing) assembles bundles from validated closed-period data and delegates to [bus-filing-prh](../modules/bus-filing-prh) and [bus-filing-vero](../modules/bus-filing-vero); those target modules list prerequisites such as period closed and filing orchestration. [bus-invoices](../modules/bus-invoices) delegates PDF generation to [bus-pdf](../modules/bus-pdf). [bus-loans](../modules/bus-loans) validates counterparty and account IDs against [bus-accounts](../modules/bus-accounts) and [bus-entities](../modules/bus-entities) when those datasets exist. [bus-reports](../modules/bus-reports) optionally reads the budget dataset from [bus-budget](../modules/bus-budget). None of these are hard Go dependencies, but finishing the “upstream” module first (e.g. period and journal before filing) keeps feature completeness and tests aligned.

| Dependent module | Depends on (library or workflow) |
|------------------|----------------------------------|
| bus-api | bus-data (Go library); formula features via bus-data’s use of bus-bfl |
| bus-sheets | bus-api (embedded in-process); optionally bus-agent for chat UI |
| bus-agent | bus-config (default agent store: GetDefaultAgent / SetDefaultAgent) |
| bus-journal | bus-period (period integrity: reject postings in closed periods) |
| bus-reports | bus-journal, bus-period; optionally bus-budget |
| bus-vat | journal-area and invoice data; period semantics |
| bus-reconcile | bus-bank; bus-invoices and/or bus-journal |
| bus-filing | closed-period, validated data; delegates to bus-filing-prh, bus-filing-vero |
| bus-filing-prh, bus-filing-vero | bus-filing orchestration; period closed and prerequisites |
| bus-invoices | bus-pdf (for `bus invoices pdf`) |
| bus-loans | bus-accounts, bus-entities (reference validation when datasets present) |

### By module

| Module | Open items | Focus of remaining work |
|--------|------------|--------------------------|
| [bus-init](../modules/bus-init) | 1 | Subcommands `defaults` and `all` per SDD/CLI; unit and e2e tests. |
| [bus-config](../modules/bus-config) | 4 | Bus configuration Go library; `set agent` / `get agent`; E2E tests. |
| [bus-data](../modules/bus-data) | 10 | Resource add/remove/rename; schema key, foreign-key, field operations; `--resource` resolution. |
| [bus-api](../modules/bus-api) | 12 | bus-data integration for all workspace endpoints; workspace root security and lock; TLS, CORS, module backends; OpenAPI and E2E. |
| [bus-sheets](../modules/bus-sheets) | 17 | Embed Bus API in-process; embed UI assets; workbook UI, grid CRUD, schema panel, validation UI; SSE; optional agent; integration tests. |
| [bus-dev](../modules/bus-dev) | 4 | Per-directory lock; remove `-f`/`--format`; E2E init (AGENTS.md); README stage/exit-codes. |
| [bus-agent](../modules/bus-agent) | 7 | Backend order and default output format; order/enable configuration; AGENTS.md discovery; per-runtime instruction adapters; deterministic fallback. |
| [bus-preferences](../modules/bus-preferences) | 3 | Key-path validation for `list`; canonical JSON for get/list; unit tests for path resolution. |
| [bus-bfl](../modules/bus-bfl) | 2 | CI workflow for tests; `eval` exit 2 when `--context` omitted. |
| [bus-accounts](../modules/bus-accounts) | 3 | Full init contract when both files exist; help for `--type`; optional income/revenue alignment. |
| [bus-entities](../modules/bus-entities) | 3 | Align `add` flags with SDD; interactive/scripting parity; align command surface with docs. |
| [bus-period](../modules/bus-period) | 5 | Append-only period control; journal balance validation; close/lock diagnostics; init help; locked-period integrity. |
| [bus-journal](../modules/bus-journal) | 5 | Period integrity; journal layout (index + period files); Finnish audit fields; interactive add; account by name. |
| [bus-attachments](../modules/bus-attachments) | 1 | Workspace-relative paths in CSV I/O diagnostics. |
| [bus-invoices](../modules/bus-invoices) | 7 | `add`, `<invoice-id> add`, `<invoice-id> validate`, `pdf`; header/line totals; E2E and help. |
| [bus-vat](../modules/bus-vat) | 5 | vat-returns index on export; `--dry-run` for init; invoice rate validation; journal-area input; audit references. |
| [bus-bank](../modules/bus-bank) | 5 | Schema validation before append; counterparty_id; link to attachments; `--dry-run` init; e2e partial init. |
| [bus-reconcile](../modules/bus-reconcile) | 7 | `match`, `allocate`, `list`; journal linking; dataset location; command-level tests. |
| [bus-assets](../modules/bus-assets) | 8 | Workspace-root layout; init, add, depreciate, dispose; `--dry-run`; voucher refs in postings. |
| [bus-loans](../modules/bus-loans) | 8 | `event`, `amortize`; idempotent init; workspace-root layout; `add` flags; event types; reference validation; tests. |
| [bus-inventory](../modules/bus-inventory) | 6 | Quiet/verbose mutual exclusion; workspace-root layout; init, add, move, valuation per SDD. |
| [bus-payroll](../modules/bus-payroll) | 3 | Scope/layout vs docs; README `make check`; `--no-color` test. |
| [bus-budget](../modules/bus-budget) | 6 | Help to stdout/exit 0; workspace-root layout; init idempotency; report, add, set. |
| [bus-reports](../modules/bus-reports) | 7 | general-ledger; trial-balance `--as-of`; `--period`; text format; traceability; optional budget; KPA/PMA. |
| [bus-validate](../modules/bus-validate) | 5 | `--format text`/tsv; empty stdout on success; help; Table Schema min/max; audit and closed-period checks. |
| [bus-pdf](../modules/bus-pdf) | 1 | Command-level test for `render` with `--data @-`. |
| [bus-filing](../modules/bus-filing) | 5 | FR-FIL-001 bundle assembly; parameter set (OQ-FIL-001); doc targets; pass-through args test; tax-audit-pack test. |
| [bus-filing-prh](../modules/bus-filing-prh) | 4 | PRH content in bundles; full SBR taxonomy; e2e tests; README links. |
| [bus-filing-vero](../modules/bus-filing-vero) | 3 | E2E tests; FR-VERO-002 source refs; deterministic prerequisite diagnostics. |

### Unknown state (no PLAN.md)

The following superproject components do not have a PLAN.md in their repository. Development status is not tracked there; they may be feature-complete or may have undocumented remaining work.

| Component | Role |
|-----------|------|
| **bus** | CLI dispatcher: delegates to `bus-<module>` subcommands and orchestrates `bus init`; no PLAN.md in repo. |

### Overall picture

Across the 27 modules there are roughly 150 open PLAN items. Recurring themes are alignment with the SDD and CLI reference (workspace-root-only datasets, idempotent init with clear partial-state failure, standard global flags), missing subcommands or options (add, list, report, `--dry-run`), validation and integrity (schema before write, period/lock checks, audit-trail fields), and test coverage (E2E, command-level, CI). The data and API layer (bus-data, bus-api) and the spreadsheet UI (bus-sheets) carry the largest remaining scope; many domain modules are close to spec once init layout, a few subcommands, and tests are finished. The filing modules (bus-filing, bus-filing-prh, bus-filing-vero) depend on stable bundle contracts and taxonomy work. Keeping PLAN.md updated and verified against the docs in each repo is the single source of truth for what “done” means per module.

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
- [Independent modules (integration through shared datasets)](../architecture/independent-modules)
- [Module repository structure and dependency rules](./module-repository-structure)
- Each module repository’s PLAN.md in the BusDK superproject

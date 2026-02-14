---
title: Development status — BusDK modules
description: Snapshot of implementation state for each BusDK module and the Bus as a whole, derived from each repository’s PLAN.md.
---

## Development status

This page summarizes the implementation state of each BusDK module as tracked in each repository’s PLAN.md. Those plans list prioritized, unchecked work items verified against the module SDD and CLI reference; completed work is not listed. The snapshot below shows how much remains per module and where the focus lies. The authoritative source for up-to-date detail is each module’s PLAN.md in the superproject. Components that have no PLAN.md are listed separately as unknown state — they may be finished or may have untracked remaining work.

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
- Each module repository’s PLAN.md in the BusDK superproject

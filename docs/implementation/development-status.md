---
title: Development status — BusDK modules
description: Snapshot of implementation state for each BusDK module and the Bus as a whole, derived from each repository’s PLAN.md.
---

## Development status

This page summarizes the implementation state of each BusDK module as tracked in each repository’s PLAN.md. Those plans list prioritized, unchecked work items verified against the module SDD and CLI reference; completed work is not listed. The snapshot below shows how much remains per module and where the focus lies. The authoritative source for up-to-date detail is each module’s PLAN.md in the superproject. Implement modules in the **Depends on** column before the dependent; per-module details and links to dependencies are in each module’s CLI reference under **Development state**.

### By module

| Module | Open | Focus | Depends on |
|--------|------|-------|------------|
| [bus](../cli/command-structure) | 3 | `help` when bus-help missing; e2e tests; CONTRIBUTING/README | — |
| [bus-init](../modules/bus-init) | 1 | Subcommands `defaults` / `all`; tests | — |
| [bus-config](../modules/bus-config) | 4 | Config library; `set`/`get agent`; E2E | — |
| [bus-data](../modules/bus-data) | 10 | Resource/schema ops; `--resource` | — |
| [bus-api](../modules/bus-api) | 12 | bus-data integration; security; TLS; E2E | [data](../modules/bus-data#development-state), bfl |
| [bus-sheets](../modules/bus-sheets) | 17 | Embed API; UI; grid; validation; agent | [api](../modules/bus-api#development-state) |
| [bus-dev](../modules/bus-dev) | 4 | Lock; remove `-f`; E2E; README | — |
| [bus-agent](../modules/bus-agent) | 7 | Order; config; AGENTS.md; adapters | [config](../modules/bus-config#development-state) |
| [bus-preferences](../modules/bus-preferences) | 3 | Key-path validation; canonical JSON; tests | — |
| [bus-bfl](../modules/bus-bfl) | 2 | CI; `eval` exit 2 for missing `--context` | — |
| [bus-accounts](../modules/bus-accounts) | 3 | Init contract; help `--type`; income/revenue | — |
| [bus-entities](../modules/bus-entities) | 3 | `add` flags; interactive parity; surface | — |
| [bus-period](../modules/bus-period) | 5 | Append-only; balance; close/lock; init help | — |
| [bus-journal](../modules/bus-journal) | 5 | Period integrity; layout; audit; interactive | [period](../modules/bus-period#development-state) |
| [bus-attachments](../modules/bus-attachments) | 1 | Workspace-relative paths in diagnostics | — |
| [bus-invoices](../modules/bus-invoices) | 7 | add; validate; pdf; totals; E2E | [pdf](../modules/bus-pdf#development-state) |
| [bus-vat](../modules/bus-vat) | 5 | Index; dry-run; rate validation; journal input | period, journal |
| [bus-bank](../modules/bus-bank) | 5 | Schema validation; counterparty_id; dry-run | — |
| [bus-reconcile](../modules/bus-reconcile) | 7 | match; allocate; list; location; tests | [bank](../modules/bus-bank#development-state), invoices, journal |
| [bus-assets](../modules/bus-assets) | 8 | Root layout; init/add/depreciate/dispose | — |
| [bus-loans](../modules/bus-loans) | 8 | event; amortize; init; add; ref validation | [accounts](../modules/bus-accounts#development-state), [entities](../modules/bus-entities#development-state) |
| [bus-inventory](../modules/bus-inventory) | 6 | Flags; root layout; init/add/move/valuation | — |
| [bus-payroll](../modules/bus-payroll) | 3 | Scope vs docs; README; no-color test | — |
| [bus-budget](../modules/bus-budget) | 6 | Help; root layout; init; report/add/set | — |
| [bus-reports](../modules/bus-reports) | 7 | general-ledger; trial-balance; period; budget | [journal](../modules/bus-journal#development-state), [period](../modules/bus-period#development-state) |
| [bus-validate](../modules/bus-validate) | 5 | format; stdout; help; min/max; audit | — |
| [bus-pdf](../modules/bus-pdf) | 1 | Test `render --data @-` | — |
| [bus-filing](../modules/bus-filing) | 5 | Bundle assembly; params; targets; tests | period, journal |
| [bus-filing-prh](../modules/bus-filing-prh) | 4 | PRH content; SBR taxonomy; e2e; links | [filing](../modules/bus-filing#development-state) |
| [bus-filing-vero](../modules/bus-filing-vero) | 3 | E2E; source refs; prerequisites | [filing](../modules/bus-filing#development-state) |

### Overall picture

Across the bus dispatcher and 27 modules there are roughly 153 open PLAN items. Recurring themes are alignment with the SDD and CLI reference (workspace-root-only datasets, idempotent init with clear partial-state failure, standard global flags), missing subcommands or options (add, list, report, `--dry-run`), validation and integrity (schema before write, period/lock checks, audit-trail fields), and test coverage (E2E, command-level, CI). The data and API layer (bus-data, bus-api) and the spreadsheet UI (bus-sheets) carry the largest remaining scope; many domain modules are close to spec once init layout, a few subcommands, and tests are finished. The filing modules (bus-filing, bus-filing-prh, bus-filing-vero) depend on stable bundle contracts and taxonomy work. Keeping PLAN.md updated and verified against the docs in each repo is the single source of truth for what “done” means per module.

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

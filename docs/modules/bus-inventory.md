---
title: bus-inventory — manage inventory items and movements
description: bus inventory maintains item master data and stock movement ledgers as schema-validated repository data.
---

## `bus-inventory` — manage inventory items and movements

### Synopsis

`bus inventory init [-C <dir>] [global flags]`  
`bus inventory add --item-id <id> --name <name> --unit <unit> --valuation-method <method> --inventory-account <account> --cogs-account <account> [--desc <text>] [--sku <sku>] [-C <dir>] [global flags]`  
`bus inventory move --item-id <id> --date <date> --qty <number> --direction <in|out|adjust> [--unit-cost <amount>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`  
`bus inventory valuation --as-of <YYYY-MM-DD> [--item-id <id>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus inventory` maintains item master data and stock movement ledgers as schema-validated repository data. It produces valuation outputs for accounting and reporting. Movements are append-only; corrections are new records.

### Commands

- `init` creates the baseline inventory datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` adds a new inventory item to the item master.
- `move` appends a stock movement (in, out, or adjust) for an item.
- `valuation` computes valuation output as of a given date.

### Options

`add` accepts `--item-id`, `--name`, `--unit`, `--valuation-method`, `--inventory-account`, `--cogs-account`, and optional `--desc`, `--sku`. `move` accepts `--item-id`, `--date`, `--qty`, `--direction <in|out|adjust>`, and optional `--unit-cost`, `--desc`, `--voucher`. `valuation` accepts `--as-of <YYYY-MM-DD>` and optional `--item-id`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus inventory --help`.

### Files

Inventory item and movement datasets and their beside-the-table schemas in the inventory area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `inventory/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value promise:** Manage inventory items and movements so valuation and COGS can feed [bus-reports](./bus-reports) and the workspace has a single source for stock and movements.

**Use cases:** [Inventory valuation and COGS postings](../implementation/development-status#inventory-valuation-and-cogs-postings).

**Completeness:** 30% (Some basic commands) — validate, status, and move (current CLI and `inventory/` layout) verified by unit and e2e tests; init, add, and valuation are not implemented; full SDD-aligned journey not verified.

**Use case readiness:** Inventory valuation and COGS postings: 30% — user can validate datasets, view on-hand status, and append movements; cannot init workspace, add items via CLI, or run valuation.

**Current:** `internal/app/run_test.go` and `tests/e2e_bus_inventory.sh` prove validate, status, move (`--sku`/`--type`/`--qty`/`--note`), global flags (`-C`, `-o`, `-q`, `-v`, `--color`, `--format`, `--`), usage, and quiet/verbose mutual exclusion. `internal/cli/flags_test.go` and `internal/cli/flags_prop_test.go` prove flag parsing. `internal/inventory/inventory_prop_test.go` proves validation, status determinism, and append. Data lives under `inventory/`; SDD-aligned init, add, valuation and workspace-root layout are not implemented.

**Planned next:** Root layout and init, add, move (SDD flags), valuation per PLAN.md; e2e and unit tests for init, add, move, valuation and determinism (advances Inventory valuation and COGS postings).

**Blockers:** None known.

**Depends on:** None.

**Used by:** Inventory data feeds COGS and valuation in [bus-reports](./bus-reports).

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-loans">bus-loans</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-payroll">bus-payroll</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Inventory items](../master-data/inventory-items/index)
- [Owns master data: Inventory movements](../master-data/inventory-movements/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-inventory](../sdd/bus-inventory)
- [Data contract: Table schema contract](../data/table-schema-contract)


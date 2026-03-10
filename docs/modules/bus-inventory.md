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

Command names follow [CLI command naming](../cli/command-naming).

`bus inventory` maintains item master data and stock movement ledgers as schema-validated repository data.
It produces valuation output for accounting and reporting.
Movements are append-only; corrections are new records.
The owned `items.csv` and `movements.csv` datasets can resolve either as ordinary CSV or as `PCSV-1` fixed-block CSV through workspace storage metadata.

### Commands

`init` creates the baseline inventory datasets and schemas. If they already exist in full, `init` warns and exits 0 without changing anything. If they exist only partially, `init` fails and does not modify files.

`add` inserts an item into item master data. `move` appends stock movement records (`in`, `out`, or `adjust`). By default movement primary keys keep the legacy random-hex behavior, but a workspace can override them through `busdk.accounting_entity.id_generation.types.inventory_movement_id` in `datapackage.json`. `valuation` computes valuation output as of the selected date.

### Options

For `add`, required flags are `--item-id`, `--name`, `--unit`, `--valuation-method`, `--inventory-account`, and `--cogs-account`. Optional flags are `--desc` and `--sku`.

For `move`, required flags are `--item-id`, `--date`, `--qty`, and `--direction <in|out|adjust>`. Optional flags are `--unit-cost`, `--desc`, and `--voucher`.
When `--direction` is `in` or `adjust`, omitting `--unit-cost` is invalid usage
and returns exit status 2.

For `valuation`, `--as-of <YYYY-MM-DD>` is required and `--item-id` is optional.
`--format` is accepted only for `status` and `valuation`. If `--item-id` is
supplied for a non-existent item, valuation succeeds with an empty result.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus inventory --help`.

### Files

Inventory item and movement datasets and their beside-the-table schemas in the inventory area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `inventory/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../modules/index#data-path-contract-for-read-only-cross-module-access)).

When `datapackage.json` selects `PCSV-1` for one or both inventory-owned tables, `init`, `add`, `move`, `status`, `valuation`, and `validate` all use the shared storage-aware table layer from `bus-data`. The baseline schemas written by `init` become `PCSV-1` compatible by adding a visible `_pad` field and the needed storage metadata. Plain CSV workspaces keep their current behavior.

### Examples

```bash
bus inventory init
bus inventory add \
  --item-id ITEM-001 \
  --name "Notebook" \
  --unit pcs \
  --valuation-method fifo \
  --inventory-account 1460 \
  --cogs-account 4100
bus inventory move --item-id ITEM-001 --date 2026-01-10 --qty 100 --direction in --unit-cost 2.40
bus inventory move --item-id ITEM-001 --date 2026-01-20 --qty 35 --direction out
bus inventory valuation --as-of 2026-01-31 --format tsv --output ./out/inventory-valuation-2026-01.tsv
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus inventory add --item-id SKU-100 --name "Widget A" --unit pcs --valuation-method fifo --inventory-account 1460 --cogs-account 4100
inventory add --item-id SKU-100 --name "Widget A" --unit pcs --valuation-method fifo --inventory-account 1460 --cogs-account 4100

# same as: bus inventory move --item-id SKU-100 --date 2026-02-15 --qty 20 --direction in --unit-cost 3.10
inventory move --item-id SKU-100 --date 2026-02-15 --qty 20 --direction in --unit-cost 3.10

# same as: bus inventory valuation --as-of 2026-02-28 --item-id SKU-100 --format json
inventory valuation --as-of 2026-02-28 --item-id SKU-100 --format json
```

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
- [Module reference: bus-inventory](../modules/bus-inventory)
- [Data contract: Table schema contract](../data/table-schema-contract)

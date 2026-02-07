## bus-inventory

### Name

`bus inventory` — manage inventory items and movements.

### Synopsis

`bus inventory <command> [options]`

### Description

`bus inventory` maintains item master data and stock movement ledgers as schema-validated repository data. It produces valuation outputs for accounting and reporting. Movements are append-only; corrections are new records.

### Commands

- `init` creates the baseline inventory datasets and schemas.
- `add-item` adds a new inventory item to the item master.
- `record-movement` appends a stock movement (in, out, or adjust) for an item.
- `valuation` computes valuation output as of a given date.

### Options

`add-item` accepts `--item-id`, `--name`, `--unit`, `--valuation-method`, `--inventory-account`, `--cogs-account`, and optional `--desc`, `--sku`. `record-movement` accepts `--item-id`, `--date`, `--qty`, `--direction <in|out|adjust>`, and optional `--unit-cost`, `--desc`, `--voucher`. `valuation` accepts `--as-of <YYYY-MM-DD>` and optional `--item-id`. For global flags and command-specific help, run `bus inventory --help`.

### Files

Inventory item and movement datasets and their beside-the-table schemas in the inventory area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### See also

Module SDD: [bus-inventory](../sdd/bus-inventory)  
Data contract: [Table schema contract](../data/table-schema-contract)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-payroll">bus-payroll</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

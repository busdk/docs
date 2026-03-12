---
title: bus budget — record budgets and run budget vs actual reports
description: "CLI reference for bus budget: maintain budget datasets by account and period, add or set amounts, and emit budget vs actual variance from journal data."
---

## `bus-budget` — record budgets and run budget vs actual reports

### Synopsis

`bus budget init [-C <dir>] [global flags]`  
`bus budget add --account <account-id> --year <YYYY> --period <MM|Qn> --amount <decimal> [-C <dir>] [global flags]`  
`bus budget set --account <account-id> --year <YYYY> --period <MM|Qn> --amount <decimal> [-C <dir>] [global flags]`  
`bus budget report (--year <YYYY> | --period <period>) [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus budget` maintains budget datasets keyed by account and period.
It also produces budget-vs-actual variance outputs from journal data.
Budgets are stored as schema-validated repository data.
The owned `budgets.csv` dataset can resolve either as ordinary CSV or as `PCSV-1` fixed-block CSV through shared `bus-data` storage policy. Ordinary CSV is the default when no explicit workspace, module, or resource storage policy exists.

### Commands

`init` creates baseline budget datasets and schemas. If they already exist in full, `init` warns and exits 0 without changes. If they exist only partially, `init` fails and does not modify files.

`add` inserts a budget row for an account and period. `set` upserts by account, year, and period. `report` emits budget-versus-actual variance output.

### Options

`add` and `set` accept `--account <account-id>`, `--year <YYYY>`, `--period <MM|Qn>`, and `--amount <decimal>`.

`report` accepts either `--year <YYYY>` or `--period <period>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus budget --help`.

### Files

Budget datasets such as `budgets.csv` and their beside-the-table schemas in the budgeting area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `budgets/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../modules/index#data-path-contract-for-read-only-cross-module-access)).

When the workspace `datapackage.json` selects `PCSV-1` for the budget dataset, `init`, `add`, `set`, and `report` use shared storage-aware table operations from `bus-data`. Plain CSV workspaces keep their current behavior, and `bus-budget` itself does not privately parse `_pcsv` metadata. The baseline schema written by `init` is compatible with `PCSV-1` and includes a visible padding field plus update-policy metadata.

### Examples

```bash
bus budget init
bus budget add --account 6100 --year 2026 --period 01 --amount 1200
bus budget set --account 6100 --year 2026 --period 01 --amount 1500
bus budget report --year 2026 --format tsv --output ./out/budget-vs-actual-2026.tsv
bus budget report --period 2026Q1 --format json --output ./out/budget-vs-actual-2026q1.json
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus budget add --account 6200 --year 2026 --period 02 --amount 800
budget add --account 6200 --year 2026 --period 02 --amount 800

# same as: bus budget set --account 6200 --year 2026 --period 02 --amount 900
budget set --account 6200 --year 2026 --period 02 --amount 900

# same as: bus budget report --period 2026Q1 --format tsv
budget report --period 2026Q1 --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-payroll">bus-payroll</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reports">bus-reports</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Budgets](../master-data/budgets/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module reference: bus-budget](../modules/bus-budget)
- [Workflow: Budgeting and budget vs actual](../workflow/budgeting-and-budget-vs-actual)

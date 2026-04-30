---
title: bus-payroll — validate payroll data and export postings
description: bus payroll validates payroll datasets and exports deterministic journal posting lines for a selected final payrun.
---

## `bus-payroll` — validate payroll data and export postings

### Synopsis

`bus payroll [-C <dir>] [global flags] validate`  
`bus payroll [-C <dir>] [global flags] export <payrun-id>`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus payroll` validates payroll datasets and exports deterministic posting rows for a selected final payrun.
Data is schema-validated and append-only for auditability.
Use `bus payroll validate --help` and `bus payroll export --help` for the exact current syntax and examples.

### Commands

`validate` checks payroll datasets and schemas in the workspace root. `export` validates first, then emits deterministic posting CSV for the selected final payrun. The module reads the owned payroll datasets through the shared storage layer, so the same commands work when those tables are backed by ordinary CSV or `PCSV-1`.

### Options

`export` takes `<payrun-id>` as a positional argument.
Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus payroll --help`.

### Files

Payroll datasets and their beside-the-table schemas are read from the workspace root (for example `employees.csv`, `payruns.csv`, `payments.csv`, and `posting_accounts.csv`). Path resolution is owned by this module; other tools obtain paths via this module’s API (see [Data path contract](../modules/index#data-path-contract-for-read-only-cross-module-access)). The read path is storage-aware, so payroll workspaces may keep those owned tables as ordinary CSV or `PCSV-1` resources.

### Examples

```bash
bus payroll validate
bus payroll export PAYRUN-2026-01
bus payroll -C ./workspace export PAYRUN-2026-01 --format tsv --output ./out/payroll-postings-2026-01.tsv
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus payroll validate
payroll validate

# same as: bus payroll export PAYRUN-2026-02 --format tsv
payroll export PAYRUN-2026-02 --format tsv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-inventory">bus-inventory</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-budget">bus-budget</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Employees](../master-data/employees/index)
- [Owns master data: Payroll runs](../master-data/payroll-runs/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module reference: bus-payroll](../modules/bus-payroll)
- [Workflow: Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)

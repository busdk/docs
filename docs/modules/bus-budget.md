## bus-budget

### Name

`bus budget` — record budgets and run budget vs actual reports.

### Synopsis

`bus budget <command> [options]`

### Description

`bus budget` maintains budget datasets keyed by account and period and produces budget versus actual variance outputs from journal data. Budgets are stored as schema-validated repository data.

### Commands

- `init` creates the baseline budget datasets and schemas.
- `add` adds a budget row for an account and period.
- `set` upserts a budget row by account, year, and period.
- `report` emits budget vs actual variance output.

### Options

`report` accepts `--year <YYYY>` or `--period <period>`. `add` and `set` accept `--account <account-id>`, `--year <YYYY>`, `--period <MM|Qn>`, and `--amount <decimal>`. For global flags and command-specific help, run `bus budget --help`.

### Files

Budget datasets such as `budgets.csv` and their beside-the-table schemas in the budgeting area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

---

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
- [Module SDD: bus-budget](../sdd/bus-budget)
- [Workflow: Budgeting and budget vs actual](../workflow/budgeting-and-budget-vs-actual)


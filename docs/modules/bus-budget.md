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

Command names follow [CLI command naming](../cli/command-naming). `bus budget` maintains budget datasets keyed by account and period and produces budget versus actual variance outputs from journal data. Budgets are stored as schema-validated repository data.

### Commands

- `init` creates the baseline budget datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` adds a budget row for an account and period.
- `set` upserts a budget row by account, year, and period.
- `report` emits budget vs actual variance output.

### Options

`report` accepts `--year <YYYY>` or `--period <period>`. `add` and `set` accept `--account <account-id>`, `--year <YYYY>`, `--period <MM|Qn>`, and `--amount <decimal>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus budget --help`.

### Files

Budget datasets such as `budgets.csv` and their beside-the-table schemas in the budgeting area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `budgets/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value:** Maintain budget dataset so [bus-reports](./bus-reports) can produce budget-vs-actual and optional planning workflows have a single source for budget figures.

**Use cases:** Orphan: no documented use case yet (optional accounting — [budgeting workflow](../workflow/budgeting-and-budget-vs-actual) exists).

**Completeness:** 30% (Some basic commands) — unit tests for flags and variance logic exist; no e2e. Init, report, add, and set not verified.

**Current:** Unit tests in `cmd/bus-budget/main_test.go`, `internal/validate/validate_property_test.go`, and `internal/budget/variance_property_test.go` prove flags and variance behavior. No e2e; init, report, add, set are not covered by tests.

**Planned next:** Help alignment; root layout; idempotent init; report, add, set subcommands.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-reports](./bus-reports) optionally reads the budget dataset for budget-vs-actual.

See [Development status](../implementation/development-status).

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


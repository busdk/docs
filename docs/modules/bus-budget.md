# bus-budget

Bus Budget maintains budget CSVs keyed by account and period, validates budgets
against schemas and the chart of accounts, and produces variance output by
comparing budgets to actuals.

## How to run

Run `bus budget` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes budget datasets in the budgeting area (for example
`budgets.csv`), uses reference data from
[`bus accounts`](./bus-accounts) and actuals from
[`bus journal`](./bus-journal), and stores each JSON Table
Schema beside its CSV dataset.

## Outputs and side effects

It writes updated budget CSVs, emits variance reports in text or structured
formats, and produces validation diagnostics for missing or invalid mappings.

## Integrations

It reads actuals from [`bus journal`](./bus-journal) and
accounts from [`bus accounts`](./bus-accounts), feeding
[`bus reports`](./bus-reports) and management summaries.

## See also

Repository: ./modules/bus-budget

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-reconcile](./bus-reconcile) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-payroll](./bus-payroll)
<!-- busdk-docs-nav end -->

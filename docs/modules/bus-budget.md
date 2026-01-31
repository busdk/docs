## bus-budget

Bus Budget maintains budget CSVs keyed by account and period, validates budgets
against schemas and the chart of accounts, and produces variance output by
comparing budgets to actuals.

### How to run

Run `bus budget` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes budget datasets in the budgeting area (for example
`budgets.csv`), uses reference data from
[`bus accounts`](./bus-accounts) and actuals from
[`bus journal`](./bus-journal), and stores each JSON Table
Schema beside its CSV dataset.

### Outputs and side effects

It writes updated budget CSVs, emits variance reports in text or structured
formats, and produces validation diagnostics for missing or invalid mappings.

### Integrations

It reads actuals from [`bus journal`](./bus-journal) and
accounts from [`bus accounts`](./bus-accounts), feeding
[`bus reports`](./bus-reports) and management summaries.

### See also

Repository: https://github.com/busdk/bus-budget

For budget dataset layout and variance workflow context, see [Budget area](../layout/budget-area) and [Budgeting and budget vs actual](../workflow/budgeting-and-budget-vs-actual).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reconcile">bus-reconcile</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-payroll">bus-payroll</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

## bus-payroll

Bus Payroll maintains employee and payroll run datasets, validates payroll
totals and required attributes, and produces journal posting outputs for
salaries and taxes.

### How to run

Run `bus payroll` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes payroll datasets in the payroll area, uses reference data
from [`bus accounts`](./bus-accounts) and
[`bus entities`](./bus-entities), and relies on JSON Table
Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes updated payroll CSVs, emits posting outputs for
[`bus journal`](./bus-journal), and produces validation
diagnostics for inconsistent payroll data.

### Integrations

It posts to [`bus journal`](./bus-journal) and contributes to
[`bus reports`](./bus-reports), linking to
[`bus entities`](./bus-entities) for employee identities.

### See also

Repository: https://github.com/busdk/bus-payroll

For schema expectations and workflow context, see [Table schema contract](../data/table-schema-contract) and [Accounting workflow overview](../workflow/accounting-workflow-overview).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-inventory">bus-inventory</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

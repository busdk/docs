# bus-payroll

Bus Payroll maintains employee and payroll run datasets, validates payroll
totals and required attributes, and produces journal posting outputs for
salaries and taxes.

## How to run

Run `bus payroll` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes payroll datasets in the payroll area, uses reference data
from [`bus accounts`](./bus-accounts) and
[`bus entities`](./bus-entities), and relies on JSON Table
Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes updated payroll CSVs, emits posting outputs for
[`bus journal`](./bus-journal), and produces validation
diagnostics for inconsistent payroll data.

## Integrations

It posts to [`bus journal`](./bus-journal) and contributes to
[`bus reports`](./bus-reports), linking to
[`bus entities`](./bus-entities) for employee identities.

## See also

Repository: ./modules/bus-payroll

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-budget](./bus-budget) · **Index:** [Modules](./) · **Next:** [bus-inventory](./bus-inventory)
<!-- busdk-docs-nav end -->

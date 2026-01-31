# bus-inventory

Bus Inventory maintains item master data and stock movement ledgers, supports
valuation outputs for accounting and reporting, and validates inventory datasets
with Table Schemas.

## How to run

Run `bus inventory` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes inventory item and movement datasets in the inventory area,
with each JSON Table Schema stored beside its CSV dataset.

## Outputs and side effects

It writes updated inventory CSVs and valuation outputs, and emits diagnostics
for invalid quantities or missing item references.

## Integrations

It feeds valuation and posting inputs to
[`bus journal`](./bus-journal) and
[`bus reports`](./bus-reports), using
[`bus accounts`](./bus-accounts) for inventory account mapping.

## See also

Repository: ./modules/bus-inventory

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-payroll](./bus-payroll) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-validate](./bus-validate)
<!-- busdk-docs-nav end -->

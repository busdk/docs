## bus-inventory

Bus Inventory maintains item master data and stock movement ledgers, supports
valuation outputs for accounting and reporting, and validates inventory datasets
with Table Schemas.

### How to run

Run `bus inventory` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes inventory item and movement datasets in the inventory area,
with each JSON Table Schema stored beside its CSV dataset.

### Outputs and side effects

It writes updated inventory CSVs and valuation outputs, and emits diagnostics
for invalid quantities or missing item references.

### Integrations

It feeds valuation and posting inputs to
[`bus journal`](./bus-journal) and
[`bus reports`](./bus-reports), using
[`bus accounts`](./bus-accounts) for inventory account mapping.

### See also

Repository: https://github.com/busdk/bus-inventory

For dataset structure and audit trail expectations, see [Table schema contract](../data/table-schema-contract) and [Append-only and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-payroll">bus-payroll</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

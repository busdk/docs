## bus-entities

Bus Entities maintains entity reference datasets as schema-validated CSV,
normalizes names, IDs, and banking details for matching, and provides stable
entity IDs for linking across modules.

### How to run

Run `bus entities` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `init`: Create entity reference datasets and schemas.
- `list`: List entities and reference identifiers.
- `add`: Append new entities or import entity rows.

### Data it reads and writes

It reads and writes entity datasets in the entities/reference area, with each
JSON Table Schema stored beside its CSV dataset.

### Outputs and side effects

It writes updated entity CSV datasets and emits validation diagnostics for
missing or conflicting identities.

### Finnish compliance responsibilities

Bus Entities MUST maintain stable entity identifiers so vouchers, invoices, and bank records can retain counterparty references across the retention period. It MUST keep entity reference data available for audit trail verification whenever those entities are linked to vouchers or postings.

### Integrations

It is used by [`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus reconcile`](./bus-reconcile),
[`bus vat`](./bus-vat), and
[`bus attachments`](./bus-attachments) for stable links.

### See also

Repository: https://github.com/busdk/bus-entities

For reference data organization and schema expectations, see [Data package organization](../data/data-package-organization) and [Table schema contract](../data/table-schema-contract).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-accounts">bus-accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-period">bus-period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

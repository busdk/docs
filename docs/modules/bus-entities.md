# bus-entities

Bus Entities maintains entity reference datasets as schema-validated CSV,
normalizes names, IDs, and banking details for matching, and provides stable
entity IDs for linking across modules.

## How to run

Run `bus entities` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes entity datasets in the entities/reference area, with each
JSON Table Schema stored beside its CSV dataset.

## Outputs and side effects

It writes updated entity CSV datasets and emits validation diagnostics for
missing or conflicting identities.

## Integrations

It is used by [`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus reconcile`](./bus-reconcile),
[`bus vat`](./bus-vat), and
[`bus attachments`](./bus-attachments) for stable links.

## See also

Repository: ./modules/bus-entities

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-accounts](./bus-accounts) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-period](./bus-period)
<!-- busdk-docs-nav end -->

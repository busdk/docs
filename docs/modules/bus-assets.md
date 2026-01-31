# bus-assets

Bus Assets keeps a fixed-asset register as schema-validated CSV datasets,
generates depreciation schedules with clear audit trails, and produces
depreciation postings for [`bus journal`](./bus-journal) and
period close tooling.

## How to run

Run `bus assets` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes fixed asset register datasets in the assets area, with each
JSON Table Schema stored beside its CSV dataset.

## Outputs and side effects

It writes updated register and schedule CSVs, emits depreciation postings or
posting suggestions for the journal, and provides validation and reconciliation
diagnostics.

## Integrations

It posts to [`bus journal`](./bus-journal) and participates in
[`bus period`](./bus-period) closing workflows, using
[`bus accounts`](./bus-accounts) for account mapping and
reporting.

## See also

Repository: ./modules/bus-assets

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-journal](./bus-journal) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-loans](./bus-loans)
<!-- busdk-docs-nav end -->

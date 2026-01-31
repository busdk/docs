# bus-attachments

Bus Attachments stores attachments (PDFs, images, etc.) in a
workspace-controlled location, maintains metadata as CSV datasets validated
with Table Schemas, and enables cross-module links from invoices, journal
entries, and bank records.

## How to run

Run `bus attachments` … and use `--help`
for available subcommands and arguments.

## Data it reads and writes

It reads and writes attachment metadata CSVs in the attachments area, manages
binary documents stored under a predictable folder structure, and stores each
JSON Table Schema beside its CSV dataset.

## Outputs and side effects

It writes metadata rows for new and updated documents and emits diagnostics for
missing files or schema violations.

## Finnish compliance responsibilities

Bus Attachments MUST assign stable `attachment_id` values and store immutable metadata (filename, media type, hash). It MUST support links from vouchers, journal entries, invoices, and bank records to attachment metadata, and it MUST retain evidence references even when files are stored outside Git.

See [Finnish bookkeeping and tax-audit compliance](../spec/compliance/fi-bookkeeping-and-tax-audit).

## Integrations

It links to records in [`bus invoices`](./bus-invoices),
[`bus journal`](./bus-journal),
[`bus bank`](./bus-bank), and
[`bus reconcile`](./bus-reconcile).

## See also

Repository: ./modules/bus-attachments

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-period](./bus-period) · **Index:** [Modules](./) · **Next:** [bus-invoices](./bus-invoices)
<!-- busdk-docs-nav end -->

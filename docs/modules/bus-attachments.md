## bus-attachments

Bus Attachments stores attachments (PDFs, images, etc.) in a
workspace-controlled location, maintains metadata as CSV datasets validated
with Table Schemas, and enables cross-module links from invoices, journal
entries, and bank records.

### How to run

Run `bus attachments` … and use `--help`
for available subcommands and arguments.

### Data it reads and writes

It reads and writes attachment metadata CSVs in the attachments area, manages
binary documents stored under a predictable folder structure, and stores each
JSON Table Schema beside its CSV dataset.

### Outputs and side effects

It writes metadata rows for new and updated documents and emits diagnostics for
missing files or schema violations.

### Finnish compliance responsibilities

Bus Attachments MUST assign stable `attachment_id` values and store immutable metadata (filename, media type, hash). It MUST support links from vouchers, journal entries, invoices, and bank records to attachment metadata, and it MUST retain evidence references even when files are stored outside Git.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It links to records in [`bus invoices`](./bus-invoices),
[`bus journal`](./bus-journal),
[`bus bank`](./bus-bank), and
[`bus reconcile`](./bus-reconcile).

### See also

Repository: https://github.com/busdk/bus-attachments

For attachment storage conventions and audit expectations, see [Invoice PDF storage](../layout/invoice-pdf-storage) and [Append-only and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

## bus-invoices

Bus Invoices keeps sales and purchase invoices in schema-validated CSV
datasets, validates totals, VAT amounts, and line consistency, and optionally
produces posting outputs for [`bus journal`](./bus-journal).

### How to run

Run `bus invoices` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `init`: Create invoice datasets and schemas in the repository root.
- `create`: Create a sales or purchase invoice record.
- `list`: List invoices by status, period, or counterparty.
- `pdf`: Render invoice PDFs from stored invoice data.
- `generate-pdf`: Alias for `pdf` when the module exposes it.

### Data it reads and writes

It reads and writes invoice header and line datasets in the repository root
(for example `sales-invoices.csv` and `sales-invoice-lines.csv`), uses
reference data from [`bus entities`](./bus-entities),
[`bus accounts`](./bus-accounts), and VAT rates, and relies on
JSON Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes updated invoice CSVs and status changes, emits validation diagnostics
for missing references or mismatched totals, and produces journal posting
outputs when configured.

### Finnish compliance responsibilities

Bus Invoices MUST assign stable invoice identifiers and maintain systematic, non-reusable invoice numbering, and it MUST capture voucher-relevant metadata (dates, counterparty, totals, VAT breakdown) that meets Finnish VAT invoice content requirements. It MUST link invoices to attachments and to any generated journal entries, and it MUST represent corrections as new records (credit notes or adjustment invoices), not overwrites.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It links to [`bus attachments`](./bus-attachments) for invoice
documents and feeds [`bus journal`](./bus-journal),
[`bus bank`](./bus-bank),
[`bus reconcile`](./bus-reconcile), and
[`bus vat`](./bus-vat).

### See also

Repository: https://github.com/busdk/bus-invoices

For invoice dataset layout and workflow details, see [Invoices area](../layout/invoices-area) and [Create sales invoice](../workflow/create-sales-invoice).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

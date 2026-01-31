## bus-invoices

Bus Invoices keeps sales and purchase invoices in schema-validated CSV
datasets, validates totals, VAT amounts, and line consistency, and optionally
produces posting outputs for [`bus journal`](./bus-journal).

### How to run

Run `bus invoices` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes invoice header and line datasets in the invoices area, uses
reference data from [`bus entities`](./bus-entities),
[`bus accounts`](./bus-accounts), and VAT rates, and relies on
JSON Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes updated invoice CSVs and status changes, emits validation diagnostics
for missing references or mismatched totals, and produces journal posting
outputs when configured.

### Finnish compliance responsibilities

Bus Invoices MUST assign stable invoice identifiers and maintain deterministic invoice numbering, and it MUST capture voucher-relevant metadata (dates, counterparty, totals, VAT breakdown). It MUST link invoices to attachments and to any generated journal entries, and it MUST represent corrections as new records (credit notes or adjustment invoices), not overwrites.

See [Finnish bookkeeping and tax-audit compliance](../spec/compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It links to [`bus attachments`](./bus-attachments) for invoice
documents and feeds [`bus journal`](./bus-journal),
[`bus bank`](./bus-bank),
[`bus reconcile`](./bus-reconcile), and
[`bus vat`](./bus-vat).

### See also

Repository: https://github.com/busdk/bus-invoices

For invoice dataset layout and workflow details, see [Invoices area](../spec/layout/invoices-area) and [Create sales invoice](../spec/workflow/create-sales-invoice).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

## `invoice_row_id` (invoice row identity)

`invoice_row_id` is the stable identity of a sales invoice row. Bookkeeping uses row identity for traceability when postings, exports, or later corrections need to point to the exact commercial line that drove the accounting decision.

Row identity keeps the audit trail precise when an invoice contains multiple lines with different VAT treatments or revenue accounts.

Example values: `SI-2026-000123-1`, `SI-2026-000123-2`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./invoice-id">invoice_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)


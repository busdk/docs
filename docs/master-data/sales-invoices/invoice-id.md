---
title: "`invoice_id` (invoice identity)"
description: invoice_id is the stable identity of a sales invoice.
---

## `invoice_id` (invoice identity)

`invoice_id` is the stable identity of a sales invoice. Bookkeeping uses it to link invoice rows, documents, payments, and any resulting ledger postings so the audit trail remains navigable from a posting back to the original invoice evidence.

Sales invoices also become open items for matching. A stable invoice identity keeps matching and exports deterministic even when invoices are corrected later.

Example values: `SI-2026-000123`, `SI-2026-000124`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Sales invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./client-id">client_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Create sales invoice](../../workflow/create-sales-invoice)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


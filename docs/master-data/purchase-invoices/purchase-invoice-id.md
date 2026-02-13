---
title: `purchase_invoice_id` (invoice identity)
description: purchase_invoice_id is the stable identity of a purchase invoice.
---

## `purchase_invoice_id` (invoice identity)

`purchase_invoice_id` is the stable identity of a purchase invoice. Bookkeeping uses it to link documents, supplier, posting specification lines, and bank matching so the audit trail remains navigable from a posting back to the vendor invoice evidence.

Stable invoice identity also supports deduplication and makes exports and later corrections traceable.

Example values: `PI-2026-000045`, `PI-2026-000046`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./purchase-company-id">purchase_company_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


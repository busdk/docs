---
title: "`invoice_number` (supplier invoice number)"
description: invoice_number is the supplier’s invoice number.
---

## `invoice_number` (supplier invoice number)

`invoice_number` is the supplier’s invoice number. Bookkeeping uses it for audit trails, disputes, vendor statement reconciliation, and deduplication so the same vendor invoice is not booked twice.

Keeping supplier invoice numbers explicit makes review and export workflows cleaner because references to vendor documents remain stable.

Example values: `INV-77881`, `2026-00045`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./purchase-company-id">purchase_company_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./date">date</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


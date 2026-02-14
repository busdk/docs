---
title: "`date` (invoice date)"
description: date is the purchase invoice date.
---

## `date` (invoice date)

`date` is the purchase invoice date. Bookkeeping uses it to anchor period selection and VAT timing logic, and it is part of the evidence context when reviewing purchases by month.

When invoice date is explicit, period-based completeness checks and reports can be run without reopening the vendor invoice document.

Example values: `2026-02-05`, `2026-02-20`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoice-number">invoice_number</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./duedate">duedate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


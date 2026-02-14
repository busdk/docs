---
title: "`reference_number` (payment matching key)"
description: reference_number is the payment reference used for matching bank payments to the purchase invoice when available.
---

## `reference_number` (payment matching key)

`reference_number` is the payment reference used for matching bank payments to the purchase invoice when available. Bookkeeping uses it as a high-signal matching key, especially when transaction descriptions are incomplete.

Even when references are not always present, keeping them explicit improves reconciliation accuracy and audit navigation.

Example values: `1234567890`, `2026000045`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./duedate">duedate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./iban">iban</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


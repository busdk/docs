---
title: "`iban` (supplier payment account)"
description: iban records the supplier’s payment account for the invoice.
---

## `iban` (supplier payment account)

`iban` records the supplier’s payment account for the invoice. Bookkeeping uses it to support payment preparation, to match bank payments, and to detect suspicious changes in supplier payment details during review.

When payment account information is explicit, reconciliation can rely on structured matching signals rather than free-text descriptions.

Example values: `FI2112345600000785`, `FI5544443333222211`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reference-number">reference_number</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./total-sum">total_sum</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


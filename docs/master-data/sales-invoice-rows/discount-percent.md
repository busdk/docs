---
title: "`discount_percent` (discount impact)"
description: discount_percent records the discount applied to the invoice row, expressed as a percentage of the row price.
---

## `discount_percent` (discount impact)

`discount_percent` records the discount applied to the invoice row, expressed as a percentage of the row price. Bookkeeping needs row-level discount information because discount changes net sales and VAT calculations and affects how income is evidenced and reviewed.

When discounts are explicit, reports and validations can reconstruct net amounts deterministically and avoid “hidden discount” interpretations from descriptions.

Example values: `0`, `10`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./price">price</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-percent">vat_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)


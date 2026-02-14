---
title: "`price` (unit price)"
description: price is the unit price for the invoice row.
---

## `price` (unit price)

`price` is the unit price for the invoice row. Together with quantity and discount, bookkeeping uses unit price to reconstruct totals consistently and to validate that net and VAT amounts were computed as expected.

Explicit unit prices improve reviewability because a reviewer can spot outliers without opening the invoice document.

Example values: `99.00`, `150.00`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./amount">amount</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./discount-percent">discount_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)


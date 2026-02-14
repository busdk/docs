---
title: "`is_capitalizable` (asset vs expense intent)"
description: is_capitalizable indicates whether the purchase line should be treated as an asset acquisition rather than an immediate expense.
---

## `is_capitalizable` (asset vs expense intent)

`is_capitalizable` indicates whether the purchase line should be treated as an asset acquisition rather than an immediate expense. Bookkeeping uses this as an intent signal at booking time so later fixed-asset workflows can be consistent and reviewable.

This field does not replace asset bookkeeping. It captures the decision context early, when the invoice is being reviewed.

Example values: `true`, `false`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./dimension">dimension</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase posting specifications</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./asset-class-hint">asset_class_hint</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


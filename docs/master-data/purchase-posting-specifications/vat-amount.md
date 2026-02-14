---
title: "`vat_amount` (VAT amount)"
description: vat_amount is the VAT amount for the purchase posting line.
---

## `vat_amount` (VAT amount)

`vat_amount` is the VAT amount for the purchase posting line. Recording VAT amount can reduce rounding disputes and keep exports stable even if calculation rules evolve, because the booked amount remains explicit.

When VAT amounts are explicit per line, reviewers can validate VAT splits without recalculating from net values during audit work.

Example values: `240.00`, `0.00`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-rate">vat_rate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase posting specifications</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-deductible-percent">vat_deductible_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


---
title: "`vat_rate` (VAT percentage)"
description: vat_rate is the VAT percentage for the purchase posting line when it is not reliably derivable from other fields.
---

## `vat_rate` (VAT percentage)

`vat_rate` is the VAT percentage for the purchase posting line when it is not reliably derivable from other fields. Bookkeeping benefits from explicit rate at the posting decision level because it avoids ambiguity and supports consistent VAT amount calculations.

BusDK examples use the current Finnish VAT rate set as the canonical sample values: `25.5`, `13.5`, `10`, `0`.

Older Finnish rates such as `24` and `14` can still appear in historical purchase rows and must remain valid as data, but they should not be treated as defaults for new records.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-treatment">vat_treatment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase posting specifications</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-amount">vat_amount</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


---
title: "`vat_percent` (applied percentage, alias)"
description: vat_percent is the applied VAT percentage, used as an alias name in some datasets and UIs.
---

## `vat_percent` (applied percentage, alias)

`vat_percent` is the applied VAT percentage, used as an alias name in some datasets and UIs. For bookkeeping, the key requirement is the same as for [`vat_rate`](./vat-rate): the applied percentage must be explicit at line level so VAT amounts and VAT reporting can be reviewed and exported deterministically.

BusDK examples use the current Finnish VAT rate set as the canonical sample values: `25.5`, `13.5`, `10`, `0`.

Older Finnish rates such as `24` and `14` can still appear in historical rows and must remain valid as data, but they should not be treated as defaults for new records.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-rate">vat_rate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-treatment">vat_treatment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


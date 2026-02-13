---
title: `vat_treatment` (reason and handling code)
description: vat_treatment is a short code that explains the VAT handling category behind the rate.
---

## `vat_treatment` (reason and handling code)

`vat_treatment` is a short code that explains the VAT handling category behind the rate. A percentage alone is not enough for automation because the same percentage, especially 0%, can correspond to different legal treatments such as domestic 0, export, reverse charge, or exempt.

Bookkeeping uses the treatment code to keep VAT reporting and validation deterministic and to make the rationale reviewable later without re-reading invoice narratives.

In BusDK documentation, VAT treatment codes also define how invoices must be marked so the VAT handling remains reviewable from the invoice evidence itself. The mapping is documented in [Invoice markings for VAT treatments](./invoice-markings).

Example values: `domestic_standard`, `reverse_charge`, `intra_eu_supply`, `export`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-percent">vat_percent</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-deductible-percent">vat_deductible_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


## `vat_rate` (applied percentage)

The VAT rate applied to a sale or purchase must be stored per line, or otherwise derivable without ambiguity, because rates can differ by item and can change over time. For bookkeeping, the applied rate is part of the accounting evidence that supports the VAT amounts and the posting decision.

When VAT rate is explicit at the point of posting intent, VAT reporting and validation can be performed deterministically without re-interpreting free-text descriptions.

BusDK examples use the current Finnish VAT rate set as the canonical sample values: `25.5`, `13.5`, `10`, `0`.

Older Finnish rates such as `24` and `14` can still appear in historical rows and must remain valid as data, but they should not be treated as defaults for new records.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-percent">vat_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


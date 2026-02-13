---
title: `country_code` (jurisdiction hint)
description: country_code records the party’s country as a short code, such as FI.
---

## `country_code` (jurisdiction hint)

`country_code` records the party’s country as a short code, such as FI. Bookkeeping uses country as a jurisdiction hint because it affects VAT treatment and sometimes required invoice content.

When country is explicit, VAT handling can be deterministic and reviewable without inferring jurisdiction from free-text addresses or VAT numbers.

Example values: `FI`, `SE`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-number">vat_number</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./default-sales-account-id">default_sales_account_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)


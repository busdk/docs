---
title: "`default_sales_account_id` (classification default for sales)"
description: default_sales_account_id is the party’s default income account suggestion.
---

## `default_sales_account_id` (classification default for sales)

`default_sales_account_id` is the party’s default income account suggestion. Bookkeeping uses it to pre-fill the most likely sales account for new invoice rows so sales classification becomes review rather than repeated manual selection.

Defaults should be treated as suggestions that remain overrideable per invoice row, because the correct account can still vary by what was sold.

Example values: `acc-3000`, `acc-3010`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./country-code">country_code</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./default-expense-account-id">default_expense_account_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)


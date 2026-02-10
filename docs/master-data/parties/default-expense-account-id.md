## `default_expense_account_id` (classification default for purchases)

`default_expense_account_id` is the party’s default expense or asset account suggestion for purchase classification. Bookkeeping uses it to pre-fill the most likely account for vendor invoices so purchase classification becomes close to automatic for common suppliers.

Defaults should remain overrideable per invoice or posting line, because real purchases can include exceptions such as assets, non-deductible costs, or mixed-category invoices.

Example values: `acc-4000`, `acc-4300`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./default-sales-account-id">default_sales_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./default-vat-treatment">default_vat_treatment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)


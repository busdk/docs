## `is_active` (operational control)

`is_active` indicates whether an account is available for new postings. Inactive accounts prevent accidental classification to deprecated accounts while keeping historical postings intact and reviewable.

Bookkeeping automation should avoid selecting inactive accounts for new items, but reporting must still include them when reviewing historical periods.

Example values: `true`, `false`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ledger-category-id">ledger_category_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../vat-treatment/index">VAT treatment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)


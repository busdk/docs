## Deactivate a ledger account

Prevent new postings to an inactive account while keeping history intact.

Owner: [bus accounts](../../modules/bus-accounts).

Deactivate accounts to prevent new postings to inactive targets while keeping historical postings intact. Automation should avoid selecting inactive accounts for new classification.

In the current CLI surface, deactivation is performed by setting `is_active` to `false` in `accounts.csv` and then running `bus accounts validate` (or `bus validate`) to ensure the result is schema-valid and consistent.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./categorize">Categorize a ledger account</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


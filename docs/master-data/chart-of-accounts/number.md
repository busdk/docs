## `number` (human-facing account number)

`number` is the human-facing account number used in exports, reporting, and review. Account numbers should be unique within the accounting entity and treated as stable identifiers in day-to-day bookkeeping work.

Stable account numbers make postings readable and auditable over time, because reviewers can recognize and validate accounts without relying on mutable names.

Example values: `1910`, `3000`.

Account numbering schemes are conventions chosen by the workspace. BusDK does not require any specific numbering ranges and accepts arbitrary numbers as long as the chart of accounts remains internally consistent and the reporting structure (`ledger_category_id`) can group accounts into the required financial statement categories.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ledger-account-id">ledger_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./name">name</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)


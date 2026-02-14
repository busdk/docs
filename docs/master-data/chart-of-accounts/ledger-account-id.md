---
title: "`ledger_account_id` (account identity)"
description: ledger_account_id is the stable identity of a ledger account in the chart of accounts.
---

## `ledger_account_id` (account identity)

`ledger_account_id` is the stable identity of a ledger account in the chart of accounts. Bookkeeping uses it as the reference from invoice rows, purchase posting specifications, and bank transactions so classification decisions do not depend on matching by name.

When account identity is stable, postings, exports, and audit trails remain consistent even if account names are refined over time.

Example values: `acc-1910`, `acc-3000`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./number">number</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)


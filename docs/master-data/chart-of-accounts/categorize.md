---
title: Categorize a ledger account
description: Attach the account to a reporting category so statements remain readable.
---

## Categorize a ledger account

Attach the account to a reporting category so statements remain readable.

Owner: [bus accounts](../../modules/bus-accounts).

Categorize accounts so profit and loss and balance sheet views remain consistent. Categories are what keep statements readable even when postings are made at account level.

In the current CLI surface, categorization is performed by updating the account’s `ledger_category_id` in `accounts.csv` and then running `bus accounts validate` (or `bus validate`) to ensure the result is schema-valid and consistent.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./add">Add a ledger account</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./deactivate">Deactivate a ledger account</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


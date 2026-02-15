---
title: Accounts area (chart of accounts and references)
description: The accounts area holds the chart of accounts and related reference data.
---

## Accounts area (chart of accounts and references)

The accounts area holds the chart of accounts and related reference data.
`accounts.csv` contains ledger accounts with fields such as account
code/number, name, category/type (Asset, Liability, Equity, Income, Expense),
optional description, and possibly hierarchical relationships through parent
accounts. A corresponding schema such as `accounts.schema.json` sits beside the
dataset file and enforces uniqueness and valid types. The path to the chart of accounts is owned by [bus-accounts](../modules/bus-accounts); other modules that need to read it obtain the path from that module (see [bus-accounts SDD](../sdd/bus-accounts)). Additional reference datasets
such as `entities.csv` may exist if counterparty identity tracking is needed
beyond invoice free-text fields; path ownership for each dataset follows the same pattern (owning module exposes path for read-only access).

Account numbering conventions are workspace policy. Examples in BusDK documentation may use familiar Finnish-style numbers such as `1910` and `3000`, but BusDK does not require any specific numbering ranges as long as the chart is internally consistent and supports the reporting groupings you need.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../layout/index">BusDK Design Spec: Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./budget-area">Budgeting area</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

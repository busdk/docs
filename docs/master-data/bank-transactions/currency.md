---
title: "`currency` (money movement currency)"
description: currency is the bank transaction currency.
---

## `currency` (money movement currency)

`currency` is the bank transaction currency. Bookkeeping needs currency explicit to interpret amounts correctly and to keep matching and exports safe, especially if a bank account or transaction feed can contain non-base currency movements.

Even when most activity is in EUR, explicit currency prevents silent errors.

Example values: `EUR`, `SEK`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./amount">amount</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./reference">reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


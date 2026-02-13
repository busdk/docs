---
title: `amount` (money movement amount)
description: amount is the bank transaction amount.
---

## `amount` (money movement amount)

`amount` is the bank transaction amount. Bookkeeping requires exact amounts for reconciliation, matching, and posting, because even small rounding or parsing differences break deterministic exports and audit trails.

When amounts are stored precisely, matching invoices and validating totals becomes straightforward.

Example values: `-1255.00`, `15.90`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./value-date">value_date</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./currency">currency</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


---
title: `value_date` (value date)
description: value_date is the value date for the bank transaction.
---

## `value_date` (value date)

`value_date` is the value date for the bank transaction. Bookkeeping uses it as supporting context to explain timing differences during reconciliation, even when `booking_date` is the primary date used for posting periods.

When value date is available, review workflows can explain “why it hit the account later” without opening external statements.

Example values: `2026-02-10`, `2026-02-13`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./booking-date">booking_date</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./amount">amount</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


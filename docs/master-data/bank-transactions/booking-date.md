---
title: `booking_date` (posting period date)
description: booking_date is the date typically used to select the accounting period for bank postings.
---

## `booking_date` (posting period date)

`booking_date` is the date typically used to select the accounting period for bank postings. Bookkeeping needs an explicit, filterable posting date so month-based reports and reconciliation views can be generated deterministically.

When booking date is explicit, “what belongs to this month” can be answered without inference.

Example values: `2026-02-10`, `2026-02-11`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bank-account-id">bank_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./value-date">value_date</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


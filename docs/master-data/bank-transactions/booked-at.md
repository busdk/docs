---
title: "`booked_at` (booking timestamp)"
description: booked_at records when the bank transaction was considered booked for bookkeeping purposes.
---

## `booked_at` (booking timestamp)

`booked_at` records when the bank transaction was considered booked for bookkeeping purposes. Bookkeeping uses it to support audit trails and to explain when a reconciliation decision was finalized.

This is the same workflow field as [`booked_at` in bookkeeping status and review workflow](../workflow-metadata/booked-at).

Example values: `2026-02-10T15:04:05Z`, `2026-02-11T10:00:00Z`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./accounting-status">accounting_status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./booked-by">booked_by</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


---
title: "`accounting_status` (review state)"
description: accounting_status expresses where the bank transaction is in the bookkeeping workflow, such as new, matched, ready, booked, or ignored.
---

## `accounting_status` (review state)

`accounting_status` expresses where the bank transaction is in the bookkeeping workflow, such as new, matched, ready, booked, or ignored. Bookkeeping uses status to separate “needs review” from “already handled” items in a reconciliation queue.

This is the same workflow field as [`accounting_status` in bookkeeping status and review workflow](../workflow-metadata/accounting-status).

Example values: `new`, `matched`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-deductible-percent">vat_deductible_percent</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./booked-at">booked_at</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


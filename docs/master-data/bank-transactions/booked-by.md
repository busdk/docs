---
title: "`booked_by` (booking actor)"
description: booked_by records who confirmed the bank transaction booking decision.
---

## `booked_by` (booking actor)

`booked_by` records who confirmed the bank transaction booking decision. Bookkeeping uses it as part of the audit trail for reconciliation and classification, especially when exceptions are handled manually.

This is the same workflow field as [`booked_by` in bookkeeping status and review workflow](../workflow-metadata/booked-by).

Example values: `jane.doe`, `accountant`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./booked-at">booked_at</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./accounting-note">accounting_note</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


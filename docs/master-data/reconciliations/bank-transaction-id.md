---
title: "`bank_transaction_id` (bank transaction reference)"
description: bank_transaction_id references the bank transaction being reconciled.
---

## `bank_transaction_id` (bank transaction reference)

`bank_transaction_id` references the bank transaction being reconciled. Reconciliations bind settlement history to imported statement facts by referencing the stable transaction identifier from the bank transaction dataset.

This field reuses [`bank_transaction_id` from bank transactions](../bank-transactions/bank-transaction-id).

Example values: `txn-2026-02-10-0001`, `txn-2026-02-10-0002`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reconciliation-id">reconciliation_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./target-kind">target_kind</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Bank transactions](../bank-transactions/index)
- [Reconcile bank transactions](../../modules/bus-reconcile)


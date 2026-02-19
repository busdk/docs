---
title: Match a bank transaction
description: Record a one-to-one reconciliation link between a bank transaction and exactly one target record.
---

## Match a bank transaction

Record a one-to-one reconciliation link between a bank transaction and exactly one target record.

Matching is strict and deterministic. Use match when the bank transaction amount and currency equal the target amount exactly and the bank transaction has not already been reconciled. For partial payments, settlement batches, and splits across multiple targets, use allocation instead.

For high-volume reconciliation where candidates are generated and reviewed first, use the proposal and batch-apply workflow described in [Deterministic reconciliation proposals and batch apply](../../workflow/deterministic-reconciliation-proposals-and-batch-apply).

Owner: [bus reconcile](../../modules/bus-reconcile).

This action writes records in [Reconciliations](./index).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./allocate">Allocate a bank transaction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)
- [Deterministic reconciliation proposals and batch apply](../../workflow/deterministic-reconciliation-proposals-and-batch-apply)

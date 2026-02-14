---
title: Allocate a bank transaction
description: Record allocations for a bank transaction that is split across multiple targets, such as partial payments, settlement batches, or fees booked separately…
---

## Allocate a bank transaction

Record allocations for a bank transaction that is split across multiple targets, such as partial payments, settlement batches, or fees booked separately from an invoice.

Allocation is strict and deterministic. Allocations are expressed as one or more rows that each reference a stable target record identifier, and the allocation amounts must sum to the bank transaction amount exactly. Allocation amounts are expressed in the same currency as the bank transaction.

Owner: [bus reconcile](../../modules/bus-reconcile).

This action writes records in [Reconciliations](./index).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./match">Match a bank transaction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./list">List reconciliations</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)


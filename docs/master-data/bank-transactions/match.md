---
title: Match a bank transaction
description: Link cash movement to an invoice or journal entry so open items close deterministically.
---

## Match a bank transaction

Link cash movement to an invoice or journal entry so open items close deterministically.

Owner: [bus bank](../../modules/bus-bank).

Match transactions to invoices or journal entries to close open items deterministically. Matching is where you turn “cash movement happened” into “this invoice is paid” or “this event is booked”.

Matching decisions are stored as [Reconciliations](../reconciliations/index) and written by [bus reconcile](../../modules/bus-reconcile).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import">Import bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./classify">Classify a non-invoice bank transaction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


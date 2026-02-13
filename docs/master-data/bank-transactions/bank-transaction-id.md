---
title: `bank_transaction_id` (bank transaction identity)
description: bank_transaction_id is the stable identity of the bank transaction as imported from the bank statement source.
---

## `bank_transaction_id` (bank transaction identity)

`bank_transaction_id` is the stable identity of the bank transaction as imported from the bank statement source. Bookkeeping uses it for deduplication, reconciliation, and audit trails so the same cash movement is not booked twice.

Stable transaction identity also makes matching and exports deterministic across repeated imports.

Example values: `txn-2026-02-10-0001`, `txn-2026-02-10-0002`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bank-account-id">bank_account_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


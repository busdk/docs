---
title: `bank_account_id` (bank account link)
description: bank_account_id links the bank transaction to the bank account it belongs to.
---

## `bank_account_id` (bank account link)

`bank_account_id` links the bank transaction to the bank account it belongs to. Bookkeeping uses this link to keep statement review, reconciliation, and posting tied to the correct cash account.

This is a reference to [`bank_account_id` on bank accounts](../bank-accounts/bank-account-id).

Example values: `bankacct-001`, `bankacct-002`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bank-transaction-id">bank_transaction_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./booking-date">booking_date</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


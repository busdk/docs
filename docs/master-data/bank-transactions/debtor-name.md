---
title: "`debtor_name` (counterparty name, debtor)"
description: debtor_name records the debtor party name from the bank transaction.
---

## `debtor_name` (counterparty name, debtor)

`debtor_name` records the debtor party name from the bank transaction. Bookkeeping uses counterparty names for matching when references are missing and for explaining statement entries during review, especially for non-invoice transactions.

Names also help link transactions to known parties when account identifiers are absent or unreliable.

Example values: `Acme Oy`, `Example Customer AB`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./rf-reference">rf_reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./creditor-name">creditor_name</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


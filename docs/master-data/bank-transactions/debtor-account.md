---
title: "`debtor_account` (counterparty account, debtor)"
description: debtor_account records the debtor account identifier from the bank transaction, such as an IBAN when available.
---

## `debtor_account` (counterparty account, debtor)

`debtor_account` records the debtor account identifier from the bank transaction, such as an IBAN when available. Bookkeeping uses counterparty account identifiers to improve party matching confidence and to support review, especially when names are ambiguous.

Account identifiers also help detect suspicious or unexpected counterparties in payment review workflows.

Example values: `FI2112345600000785`, `FI5544443333222211`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./creditor-name">creditor_name</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./creditor-account">creditor_account</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


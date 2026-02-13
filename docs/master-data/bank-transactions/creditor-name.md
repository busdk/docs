---
title: `creditor_name` (counterparty name, creditor)
description: creditor_name records the creditor party name from the bank transaction.
---

## `creditor_name` (counterparty name, creditor)

`creditor_name` records the creditor party name from the bank transaction. Bookkeeping uses counterparty names to explain statement entries in review workflows and as a matching signal when references are missing or noisy.

Names are particularly important for fees, taxes, and settlements where no invoice reference exists.

Example values: `Example Supplier AB`, `Tax authority`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./debtor-name">debtor_name</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./debtor-account">debtor_account</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


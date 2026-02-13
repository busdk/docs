---
title: `ledger_account_id` (classification target for non-invoice events)
description: ledger_account_id is the classification target used when a bank transaction is not a direct invoice payment, such as fees, taxes, loan repayments, and…
---

## `ledger_account_id` (classification target for non-invoice events)

`ledger_account_id` is the classification target used when a bank transaction is not a direct invoice payment, such as fees, taxes, loan repayments, and settlement movements. Bookkeeping needs explicit classification targets so posting can be automated beyond importing the statement.

This is a reference to [`ledger_account_id` in the chart of accounts](../chart-of-accounts/ledger-account-id).

Example values: `acc-6570`, `acc-1760`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./purchase-company-id">purchase_company_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-treatment">vat_treatment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


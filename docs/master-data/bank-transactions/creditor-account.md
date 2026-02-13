---
title: `creditor_account` (counterparty account, creditor)
description: creditor_account records the creditor account identifier from the bank transaction, such as an IBAN when available.
---

## `creditor_account` (counterparty account, creditor)

`creditor_account` records the creditor account identifier from the bank transaction, such as an IBAN when available. Bookkeeping uses counterparty account identifiers to improve matching and to validate that payments went to the expected account.

This field is particularly useful for reviewing supplier payments and detecting exceptions where payment details differ from known vendor information.

Example values: `FI2112345600000785`, `FI5544443333222211`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./debtor-account">debtor_account</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./matched-sale-invoice-id">matched_sale_invoice_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


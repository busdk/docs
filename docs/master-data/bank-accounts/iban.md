---
title: "`iban` (bank account IBAN)"
description: iban identifies the bank account.
---

## `iban` (bank account IBAN)

`iban` identifies the bank account. Bookkeeping uses it for validation and for matching workflows that rely on knowing which account transactions belong to, and it helps reviewers confirm payment instructions and spot suspicious changes.

Keeping IBAN explicit also supports integrations and exports where bank accounts must be identified unambiguously.

Example values: `FI2112345600000785`, `FI5544443333222211`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bank-account-id">bank_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bic">bic</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)


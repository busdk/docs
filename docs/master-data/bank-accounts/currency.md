---
title: `currency` (account currency)
description: currency is the bank account currency.
---

## `currency` (account currency)

`currency` is the bank account currency. Bank transaction amounts are denominated in the bank account currency, and bookkeeping needs currency explicit to interpret amounts correctly and keep exports safe as multi-currency activity appears.

Even when you currently operate only in EUR, explicit currency prevents silent assumptions and makes mismatches detectable.

Example values: `EUR`, `SEK`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bic">bic</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ledger-account-id">ledger_account_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)


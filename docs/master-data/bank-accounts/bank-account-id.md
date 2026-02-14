---
title: "`bank_account_id` (bank account identity)"
description: bank_account_id is the stable identity of the bank account as a transaction source in your bank feed or bank integration.
---

## `bank_account_id` (bank account identity)

`bank_account_id` is the stable identity of the bank account as a transaction source in your bank feed or bank integration. Bookkeeping uses it to ensure each bank transaction is tied to the correct account and to support deterministic imports, deduplication, and statement-level review.

Stable bank account identity also makes reconciliation and reporting consistent across periods.

Example values: `bankacct-001`, `bankacct-002`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Bank accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank accounts</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./iban">iban</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)


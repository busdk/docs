---
title: `rf_reference` (RF reference)
description: rf_reference is the RF-form reference when present on the bank transaction.
---

## `rf_reference` (RF reference)

`rf_reference` is the RF-form reference when present on the bank transaction. Bookkeeping uses it as an additional matching key, especially when the plain reference field is missing or formatted inconsistently.

Keeping RF references explicit improves reconciliation accuracy for cross-border and standardized reference scenarios.

Example values: `RF18539007547034`, `RF4712345600000001`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reference">reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./debtor-name">debtor_name</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


---
title: Classify a non-invoice bank transaction
description: Record the target ledger account and VAT intent for fees, taxes, and other events.
---

## Classify a non-invoice bank transaction

Record the target ledger account and VAT intent for fees, taxes, and other events.

Owner: [bus bank](../../modules/bus-bank).

Classify statement items that are not invoice payments by recording the target ledger account and any relevant VAT intent. This is essential for fees, taxes, and settlement movements. When bus-bank implements [counterparty normalization](../../sdd/bus-bank#suggested-capabilities-out-of-current-scope), classification rules will be able to key off a canonical counterparty value while the original bank label remains stored for audit. For recurring domestic supplier charges, [posting templates with automatic VAT split](../../sdd/bus-journal#suggested-capabilities-out-of-current-scope) (bus-journal suggested capability) would split gross bank amounts into base + VAT by configured rate and accounts when implemented; template format and usage would then be documented in the bus-journal SDD and module reference.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./match">Match a bank transaction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


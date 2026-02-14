---
title: "`payment_identifiers` (matching and payment hints)"
description: payment_identifiers are the counterparty’s payment-related identifiers, such as a supplier’s usual IBAN.
---

## `payment_identifiers` (matching and payment hints)

`payment_identifiers` are the counterparty’s payment-related identifiers, such as a supplier’s usual IBAN. Bookkeeping uses them to improve bank transaction matching and to support payment preparation and review.

When payment identifiers are stable, reconciliation can rely less on invoice references and more on deterministic matching to known parties, especially for payments that lack usable reference numbers.

Example values: `FI2112345600000785`, `FI5544443333222211`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./default-vat-treatment">default_vat_treatment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../workflow-metadata/index">Bookkeeping status and review workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)


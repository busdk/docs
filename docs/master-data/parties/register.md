---
title: Register a party
description: Create or import a counterparty record so invoices and matching can link deterministically.
---

## Register a party

Create or import a counterparty record so invoices and matching can link deterministically.

Owner: [bus entities](../../modules/bus-entities).

Register parties so invoices and bank transactions can link to a stable counterparty identity. Strong identifiers reduce duplicates and improve matching when references are missing.

In the current CLI surface, `bus entities add` records the stable entity identifier and display name. If your workspace captures additional party fields (such as business identifiers, VAT numbers, country codes, payment identifiers, or default bookkeeping fields), those columns are maintained by editing `entities.csv` directly and then validating with `bus validate`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./deduplicate">Deduplicate parties</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


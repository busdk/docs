---
title: Set party bookkeeping defaults
description: Maintain default accounts, VAT handling, and payment identifiers used for pre-fill and matching.
---

## Set party bookkeeping defaults

Maintain default accounts, VAT handling, and payment identifiers used for pre-fill and matching.

Owner: [bus entities](../../modules/bus-entities).

Set defaults to reduce repeated classification work. Defaults should pre-fill likely accounts and VAT handling while remaining overrideable per invoice row or posting line.

In the current CLI surface, defaults are maintained by editing the corresponding columns in `entities.csv` directly and then validating with `bus validate`, because `bus entities add` currently only writes the stable identifier and display name.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./deduplicate">Deduplicate parties</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


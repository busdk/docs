---
title: Generate reconciliation proposals
description: Planned deterministic candidate generation for reconciliation, producing proposal rows with confidence and reason fields before any canonical writes.
---

## Generate reconciliation proposals

Generate deterministic reconciliation candidate rows before writing canonical reconciliation records. Proposal generation is a planning phase that reads bank and invoice or journal datasets and produces review artifacts with confidence and reason fields.

This action is planned for first-class command support in [bus reconcile](../../modules/bus-reconcile). Current high-volume candidate planning in this workspace is script-assisted.

Owner: [bus reconcile](../../modules/bus-reconcile).

This action reads from [Bank transactions](../bank-transactions/index), [Sales invoices](../sales-invoices/index), [Purchase invoices](../purchase-invoices/index), and journal references, and writes proposal artifacts intended for review and approval.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./list">List reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./apply-proposals">Apply approved reconciliation proposals</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)
- [Deterministic reconciliation proposals and batch apply](../../workflow/deterministic-reconciliation-proposals-and-batch-apply)

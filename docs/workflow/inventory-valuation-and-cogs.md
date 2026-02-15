---
title: Inventory valuation and COGS postings
description: Define inventory items, record append-only stock movements with voucher references, and compute deterministic as-of valuation for reporting and cost-of-goods-sold postings.
---

## Inventory valuation and COGS postings

This use case covers defining an inventory register, recording stock movements (purchases, sales or consumption, adjustments) as append-only rows with voucher references, and computing deterministic valuation outputs (for example FIFO or weighted-average) for an as-of date or period end. Those outputs are suitable for reporting and for later journal postings for cost of goods sold (COGS).

The canonical implementation is the [bus-inventory](../modules/bus-inventory) module. Module readiness for this journey is summarised in [Development status — BusDK modules](../implementation/development-status#inventory-valuation-and-cogs-postings) under **Inventory valuation and COGS postings**.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./finnish-payroll-monthly-pay-run">Finnish payroll handling (monthly pay run)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workbook-and-validated-tabular-editing">Workbook and validated tabular editing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-inventory](../modules/bus-inventory)
- [Development status — BusDK modules](../implementation/development-status#inventory-valuation-and-cogs-postings)

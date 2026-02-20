---
title: Inventory movements
description: Inventory movements are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Inventory movements

Inventory movements are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus inventory](../../modules/bus-inventory). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus validate](../../modules/bus-validate) checks movement integrity and reference validity.

### Actions

[Record an inventory movement](./record) appends stock movements so inventory levels and valuation remain auditable. [Adjust inventory](./adjust) records adjustment movements when physical count differs from book stock.

### Properties

Core movement fields are [`item_id`](./item-id), [`date`](./date), [`qty`](./qty), [`direction`](./direction), [`unit_cost`](./unit-cost), [`description`](./description), and [`voucher`](./voucher).

### Relations

An inventory movement belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

An inventory movement references one [inventory item](../inventory-items/index) via [`item_id`](./item-id). Over time, one item can have many movements that together form the audit trail for stock level and valuation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Inventory movements</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)

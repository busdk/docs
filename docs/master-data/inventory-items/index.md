---
title: Inventory items
description: Inventory items are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Inventory items

Inventory items are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus inventory](../../modules/bus-inventory). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus journal](../../modules/bus-journal) receives postings derived from inventory valuation decisions, and [bus accounts](../../modules/bus-accounts) provides inventory and COGS accounts referenced by item master data.

### Actions

[Add an inventory item](./add) registers items so stock movements reference stable identifiers. [Value inventory](./value) computes as-of valuation output for review and posting decisions.

### Properties

Core item fields are [`item_id`](./item-id), [`name`](./name), [`unit`](./unit), [`valuation_method`](./valuation-method), and [`sku`](./sku). Posting-account fields are [`inventory_account_id`](./inventory-account-id) and [`cogs_account_id`](./cogs-account-id).

### Relations

An inventory item belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

Inventory movements reference items via [`item_id`](../inventory-movements/item-id) so stock levels and valuation can be traced back to a stable item master record.

Inventory items reference [ledger accounts](../chart-of-accounts/index) via [`inventory_account_id`](./inventory-account-id) and [`cogs_account_id`](./cogs-account-id) so valuation and COGS postings can be produced consistently.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Inventory items</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Double-entry ledger](../../design-goals/double-entry-ledger)

## Inventory items

Inventory items are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus inventory](../../modules/bus-inventory). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): receives postings derived from inventory valuation decisions.
- [bus accounts](../../modules/bus-accounts): provides inventory and COGS accounts referenced by item master data.

### Actions

- [Add an inventory item](./add): Register an item so stock movements can be recorded against a stable identifier.
- [Value inventory](./value): Compute valuation output as of a date for review and posting decisions.

### Properties

- [`item_id`](./item-id): Item identity.
- [`name`](./name): Item name.
- [`unit`](./unit): Unit of measure.
- [`valuation_method`](./valuation-method): Valuation method.
- [`inventory_account_id`](./inventory-account-id): Inventory account.
- [`cogs_account_id`](./cogs-account-id): COGS account.
- [`sku`](./sku): Stock keeping unit.

---

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


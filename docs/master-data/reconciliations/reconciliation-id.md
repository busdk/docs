## `reconciliation_id` (stable reconciliation identifier)

`reconciliation_id` is the stable identifier of a reconciliation record. Bookkeeping uses stable reconciliation identifiers to keep settlement history append-only and reviewable even when matching decisions are refined later.

The identifier is stable within the repository and must not be reused for a different reconciliation record.

Example values: `rec-2026-02-10-0001`, `rec-2026-02-10-0002`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bank-transaction-id">bank_transaction_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)


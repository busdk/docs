## `target_kind` (reconciliation target kind)

`target_kind` tells which kind of record the reconciliation references. The value is used to interpret `target_id` deterministically and to support lists and validation without guessing whether an identifier belongs to an invoice or to a journal transaction.

Allowed values:

- `invoice`: The target is an invoice header record.
- `journal`: The target is a journal transaction record.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bank-transaction-id">bank_transaction_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./target-id">target_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)


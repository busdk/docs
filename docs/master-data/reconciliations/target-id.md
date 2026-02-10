## `target_id` (reconciliation target identifier)

`target_id` is the stable identifier of the record being settled.

When `target_kind` is `invoice`, `target_id` must equal the invoice’s stable identifier as stored in the invoice datasets. When `target_kind` is `journal`, `target_id` must equal the journal transaction’s stable identifier as stored in the journal datasets.

The value is treated as an opaque identifier. It is not parsed or reinterpreted during reconciliation.

Example values: `SI-2026-000123`, `PI-2026-000017`, `JRN-2026-014`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./target-kind">target_kind</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./amount">amount</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)


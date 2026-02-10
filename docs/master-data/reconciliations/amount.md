## `amount` (allocated amount)

`amount` is the amount assigned to a single reconciliation target. It is expressed as a positive decimal in the bank transaction currency, and allocation rows must sum to the bank transaction amount exactly.

For a one-to-one match, the effective allocation amount equals the full bank transaction amount.

This field uses the same numeric domain as [`amount` on bank transactions](../bank-transactions/amount) and is interpreted in the bank transaction currency.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./target-id">target_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)


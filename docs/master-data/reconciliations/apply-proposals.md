---
title: Apply approved reconciliation proposals
description: Planned deterministic batch apply phase that consumes approved proposal rows and records reconciliation matches or allocations with idempotent semantics.
---

## Apply approved reconciliation proposals

Apply approved proposal rows in batch to record canonical reconciliation entries deterministically. This phase consumes explicit proposal row identifiers and writes match or allocation records without guessing.

This action is planned for first-class command support in [bus reconcile](../../modules/bus-reconcile). The target behavior includes `--dry-run` and idempotent re-apply semantics so rerunning the same approved proposal file does not create duplicate reconciliation rows.

Owner: [bus reconcile](../../modules/bus-reconcile).

This action writes canonical records in [Reconciliations](./index) using approved proposal rows as explicit input.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./propose">Generate reconciliation proposals</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Reconciliations</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Reconcile bank transactions](../../modules/bus-reconcile)
- [Module SDD: bus-reconcile](../../sdd/bus-reconcile)
- [Deterministic reconciliation proposals and batch apply](../../workflow/deterministic-reconciliation-proposals-and-batch-apply)

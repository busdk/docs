---
title: Deterministic reconciliation proposals and batch apply
description: Planned two-phase reconciliation workflow where bus reconcile generates deterministic proposal rows and then applies approved rows in batch with dry-run and idempotent semantics.
---

## Deterministic reconciliation proposals and batch apply

The target reconciliation workflow is a two-phase command flow. First, the system generates deterministic proposal rows from bank and invoice or journal datasets. Second, operators review and approve proposal rows, then apply those approved rows in batch. This keeps candidate planning and write operations separate, reviewable, and script-friendly.

### Current workflow (today)

Current production reconciliation uses `bus reconcile match`, `bus reconcile allocate`, and `bus reconcile list` for direct writes. In this workspace, deterministic candidate planning and exact-match preparation are handled by custom scripts such as `exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`. When a valid `matches` dataset exists, the former bank-ID lookup defect no longer reproduces; deterministic exact matches can be applied in clean replay (e.g. 124 rows) by combining explicit `matches` bootstrap, invoice header totals in ERP import, and generated exact-command sets.

The remaining gap is first-class proposal and batch-apply commands plus idempotent re-apply semantics. Until `bus reconcile propose` and `bus reconcile apply` are implemented, teams should continue using the current script-assisted process with explicit review.

### Target workflow (planned first-class commands)

In the planned workflow, proposal generation and apply are explicit commands under `bus reconcile`.

```bash
bus reconcile propose --out reconcile-proposals-2024.tsv
bus reconcile apply --in reconcile-proposals-2024-approved.tsv --dry-run
bus reconcile apply --in reconcile-proposals-2024-approved.tsv
```

Proposal output includes deterministic candidate rows with confidence and reason fields so reviewers can audit why each row was suggested. Apply consumes only approved rows, writes canonical reconciliation records deterministically, and supports idempotent re-apply so rerunning the same approved file does not create duplicates.

These artifacts are also intended as deterministic inputs for migration-quality controls in [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks), where coverage and unresolved deltas can be evaluated with CI thresholds.

### Scope and ownership

[bus-reconcile](../modules/bus-reconcile) owns proposal generation and apply behavior. [bus-bank](../modules/bus-bank) provides deterministic bank transaction identity and normalized read fields used as proposal input. [bus-invoices](../modules/bus-invoices) provides deterministic open-item invoice identity and status or amount semantics used as proposal input.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import-bank-transactions-and-apply-payment">Import bank transactions and apply payments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./import-erp-history-into-canonical-datasets">Import ERP history into canonical invoices and bank datasets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-reconcile SDD](../sdd/bus-reconcile)
- [bus-bank SDD](../sdd/bus-bank)
- [bus-invoices SDD](../sdd/bus-invoices)
- [Import bank transactions and apply payment](./import-bank-transactions-and-apply-payment)
- [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)

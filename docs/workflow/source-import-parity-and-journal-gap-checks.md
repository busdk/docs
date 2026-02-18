---
title: Source import parity and journal gap checks
description: Planned first-class migration-quality checks that compare source import totals to workspace datasets and non-opening journal activity with deterministic CI behavior.
---

## Source import parity and journal gap checks

Migration confidence requires deterministic checks that compare imported source activity against canonical workspace data and journal coverage. The target workflow introduces first-class Bus commands for those controls so teams can run parity and gap checks without custom shell scripts.

### Current workflow (today)

In this repository, parity and gap diagnostics are currently script-based. Source-to-workspace parity checks use `exports/2024/022-erp-parity-2024.sh`, and ERP-to-journal gap checks use `exports/2024/023-erp-journal-gap-2024.sh`.

These scripts are deterministic and auditable, but they remain repository-specific glue outside the module command surfaces.

### Target workflow (planned first-class commands)

The planned command flow combines deterministic reporting with CI-friendly threshold gates:

```bash
bus reports journal-coverage --from 2024-01 --to 2024-12 --source-summary imports/source-summary-2024.tsv --exclude-opening
bus validate parity --source imports/source-summary-2024.tsv --by dataset,period
bus validate journal-gap --source imports/source-summary-2024.tsv --max-abs-delta 0.01 --max-count-delta 0
```

`bus reports` emits deterministic coverage rows (period totals and deltas), while `bus validate` evaluates parity and threshold gates for CI exit behavior. Reconciliation outputs from [bus-reconcile](../modules/bus-reconcile) are consumed as deterministic evidence for matched versus unresolved operational activity when relevant.

### Scope and ownership

[bus-validate](../modules/bus-validate) owns parity and threshold pass or fail behavior. [bus-reports](../modules/bus-reports) owns non-opening journal coverage reporting. [bus-reconcile](../modules/bus-reconcile) provides deterministic proposal and apply output fields that these checks can consume. A possible future extension is class-aware gap reporting (operational vs financing/transfer buckets) so migration progress can be tracked per activity class; see the bus-validate SDD suggested capabilities for that option.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import-erp-history-into-canonical-datasets">Import ERP history into canonical invoices and bank datasets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-assisted-classification-review">AI-assisted classification (review before recording a revision)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-validate module CLI reference](../modules/bus-validate)
- [bus-reports module CLI reference](../modules/bus-reports)
- [bus-reconcile module CLI reference](../modules/bus-reconcile)
- [bus-validate SDD](../sdd/bus-validate)
- [bus-reports SDD](../sdd/bus-reports)
- [bus-reconcile SDD](../sdd/bus-reconcile)

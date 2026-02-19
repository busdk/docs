---
title: Source import parity and journal gap checks
description: First-class migration-quality checks that compare source import totals to workspace datasets and non-opening journal activity with deterministic CI behavior.
---

## Source import parity and journal gap checks

Migration confidence requires deterministic checks that compare imported source data with workspace datasets and journal coverage. BusDK provides first-class commands for these checks so teams can avoid custom shell scripts.

### Current workflow

`bus reports journal-coverage`, `bus reports parity`, and `bus reports journal-gap` create deterministic report artifacts for review. `bus validate parity` and `bus validate journal-gap` add CI pass/fail behavior with absolute, relative, and bucket-aware thresholds.

### Command workflow

The command flow combines deterministic report artifacts with CI-friendly threshold gates.

```bash
bus reports journal-coverage --from 2024-01 --to 2024-12 --source-summary imports/source-summary-2024.tsv --exclude-opening
bus validate parity --source imports/source-summary-2024.tsv --by dataset,period
bus validate journal-gap --source imports/source-summary-2024.tsv --max-abs-delta 0.01 --max-count-delta 0
```

`bus reports` emits deterministic coverage rows (period totals and deltas), while `bus validate` evaluates parity and threshold gates for CI exit behavior. Reconciliation outputs from [bus-reconcile](../modules/bus-reconcile) are consumed as deterministic evidence for matched versus unresolved operational activity when relevant.

### Scope and ownership

[bus-validate](../modules/bus-validate) owns threshold pass-or-fail behavior. [bus-reports](../modules/bus-reports) owns deterministic review artifacts for `journal-coverage`, `parity`, and `journal-gap`, including bucket-based gap output in `journal-gap`. [bus-reconcile](../modules/bus-reconcile) provides deterministic proposal and apply outputs that these checks can consume.

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

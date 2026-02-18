---
title: Source import parity and journal gap checks
description: Planned first-class migration-quality checks that compare source import totals to workspace datasets and non-opening journal activity with deterministic CI behavior.
---

## Source import parity and journal gap checks

Migration confidence requires deterministic checks that compare imported source activity against canonical workspace data and journal coverage. The target workflow introduces first-class Bus commands for those controls so teams can run parity and gap checks without custom shell scripts.

### Current workflow

`bus reports journal-coverage` and `bus validate parity` / `bus validate journal-gap` exist and are partially implemented. Validate performs the check but does not emit a report artifact; script-based parity and gap diagnostics (e.g. `exports/2024/022-erp-parity-2024.sh`, `exports/2024/023-erp-journal-gap-2024.sh`) remain an alternative where a reviewable parity report is needed.

### Target workflow

The command flow combines deterministic reporting with CI-friendly threshold gates. A suggested extension is a report in [bus-reports](../modules/bus-reports) that emits source import parity as a review/CI artifact (counts/sums by dataset and period in tsv/csv), complementing `bus validate parity`; see the [bus-reports SDD](../sdd/bus-reports) and module reference.

```bash
bus reports journal-coverage --from 2024-01 --to 2024-12 --source-summary imports/source-summary-2024.tsv --exclude-opening
bus validate parity --source imports/source-summary-2024.tsv --by dataset,period
bus validate journal-gap --source imports/source-summary-2024.tsv --max-abs-delta 0.01 --max-count-delta 0
```

`bus reports` emits deterministic coverage rows (period totals and deltas), while `bus validate` evaluates parity and threshold gates for CI exit behavior. Reconciliation outputs from [bus-reconcile](../modules/bus-reconcile) are consumed as deterministic evidence for matched versus unresolved operational activity when relevant.

### Scope and ownership

[bus-validate](../modules/bus-validate) owns parity and threshold pass or fail behavior. [bus-reports](../modules/bus-reports) owns non-opening journal coverage reporting; a suggested extension is a report that emits source import parity (counts/sums by dataset and period, tsv/csv) as a review/CI artifact, complementing validate. [bus-reconcile](../modules/bus-reconcile) provides deterministic proposal and apply output fields that these checks can consume. A suggested extension is a [class-aware gap report by account buckets](../modules/bus-reports#journal-coverage-and-parity-reports) in bus-reports: breakdown by configurable account buckets (e.g. operational income/expense, financing liability/service, internal transfer) with period-based, machine-friendly output (tsv/json) for CI and prioritization; [bus-validate](../modules/bus-validate) suggested capabilities include per-bucket thresholds for CI pass/fail.

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

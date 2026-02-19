---
title: Import ERP history into canonical invoices and bank datasets
description: Import ERP history into canonical BusDK invoice and bank datasets using versioned mapping profiles with deterministic artifacts.
---

## Import ERP history into canonical invoices and bank datasets

Historical ERP migrations in BusDK are deterministic and auditable. The standard workflow uses profile-driven import commands for invoices and bank datasets, with deterministic plan and result artifacts.

The profile carries mapping intent in repository data. Commands reference a versioned mapping profile and source ERP export tables, then apply deterministic mapping rules into canonical workspace datasets.

### Command workflow

Use profile-driven import commands:

```bash
bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024
bus bank import --profile imports/profiles/erp-bank-2024.yaml --source exports/erp/bank-2024.tsv --year 2024
```

Each run emits deterministic plan and result artifacts that include source row identifiers, mapping decisions, and produced canonical identifiers. Commit artifacts together with profile changes so reviews can focus on mapping intent and outcomes.

For reconciliation planning in this same migration flow, teams can use first-class `bus reconcile propose/apply` commands (described in [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)). Candidate generation and exact-match preparation may still be script-driven in migration repositories when custom import-specific heuristics are needed (for example `exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`).

### Script-based alternative

Generated script migrations are still valid when you need custom one-off mapping logic. For example, a repository can keep `exports/2024/017-erp-invoices-2024.sh` and `exports/2024/018-erp-bank-2024.sh` as explicit append scripts.

When replay workflows include ERP history onboarding, replay logs can capture profile-import invocations and artifact references as plain Bus commands, preserving deterministic migration history in a reusable format.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./deterministic-reconciliation-proposals-and-batch-apply">Deterministic reconciliation proposals and batch apply</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./source-import-parity-and-journal-gap-checks">Source import parity and journal gap checks</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-bank module CLI reference](../modules/bus-bank)
- [bus-data module CLI reference](../modules/bus-data)
- [bus-replay module CLI reference](../modules/bus-replay)
- [bus-invoices SDD](../sdd/bus-invoices)
- [bus-bank SDD](../sdd/bus-bank)
- [bus-data SDD](../sdd/bus-data)
- [bus-replay SDD](../sdd/bus-replay)
- [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
- [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)

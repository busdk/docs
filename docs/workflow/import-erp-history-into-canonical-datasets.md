---
title: Import ERP history into canonical invoices and bank datasets
description: Planned first-class workflow for importing ERP history into canonical BusDK invoice and bank datasets using versioned mapping profiles and auditable artifacts.
---

## Import ERP history into canonical invoices and bank datasets

Historical ERP migrations are currently deterministic but operationally heavy. Teams generate large explicit append scripts from ERP TSV mappings and then run those scripts into the workspace. This keeps behavior reviewable, but the generated scripts are difficult to maintain and reuse across repositories.

The target workflow is profile-driven import. A short command references a versioned mapping profile and source ERP export tables, and the module applies deterministic mapping rules into canonical Bus datasets. The profile carries mapping intent in repository data, and command output includes auditable artifacts so reviewers can verify how source rows became canonical rows.

### Current workflow (today)

The current migration path uses generated scripts such as `exports/2024/017-erp-invoices-2024.sh` and `exports/2024/018-erp-bank-2024.sh`. Those scripts are produced from ERP TSV mapping logic and then executed as plain Bus commands. This path remains the production approach until first-class profile import commands are implemented.

For reconciliation planning in this same migration flow, candidate generation and exact-match preparation are also script-driven today, including `exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`. The planned first-class command workflow for that phase is described in [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply).

### Target workflow (planned first-class import)

In the planned workflow, the repository stores versioned mapping profiles for invoices and bank imports. Operators run short deterministic commands that reference a profile and a source snapshot.

```bash
bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024
bus bank import --profile imports/profiles/erp-bank-2024.yaml --source exports/erp/bank-2024.tsv --year 2024
```

Each run emits deterministic plan and result artifacts that include source row identifiers, mapping decisions, and produced canonical identifiers. The artifacts are committed together with profile changes so reviews can focus on mapping intent and outcomes instead of generated script size.

When replay workflows include ERP history onboarding, replay logs capture these profile-import invocations and their artifact references as plain Bus commands, preserving deterministic and auditable migration history in a reusable format.

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

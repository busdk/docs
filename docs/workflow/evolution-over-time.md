---
title: Evolution over time (extending the model)
description: As the business evolves, the workflow stays stable because the authoritative interface is the workspace datasets and their schemas.
---

## Evolution over time (extending the model)

As the business evolves, the workflow stays stable because the authoritative interface is the workspace datasets and their schemas. BusDK’s module boundaries allow you to extend what is recorded and computed without rewriting history.

1. When a new data need appears, Alice expresses it as a schema change and a corresponding record shape change, for example adding a currency field to the relevant table schemas and then adding the corresponding values to new records.

2. Alice runs validation to ensure the updated schemas and datasets remain consistent:

```bash
bus validate
```

3. If the change affects derived outputs, she regenerates them deterministically from the updated repository data:

```bash
bus reports trial-balance --as-of 2026-12-31
```

4. Alice records the evolution as a normal, reviewable change to repository data by creating a new revision with her version control tooling.

If Alice hires an assistant, the same sequence is executed through standard version control collaboration outside BusDK. If new taxes or reporting obligations appear, she adds the appropriate module and runs its commands against the same datasets, because “CSV plus schemas” remains the stable interface between modules and workflows.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./create-sales-invoice">Add a sales invoice (interactive workflow)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./import-bank-transactions-and-apply-payment">Import bank transactions and apply payments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-validate module CLI reference](../modules/bus-validate)
- [bus-reports module CLI reference](../modules/bus-reports)
- [Accounting workflow overview](./accounting-workflow-overview)

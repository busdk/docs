---
title: Budgeting and budget-vs-actual reporting
description: Budgeting is a controlled computation over stored, schema-validated budget rows and the authoritative journal actuals.
---

## Budgeting and budget-vs-actual reporting

Budgeting is a controlled computation over stored, schema-validated budget rows and the authoritative journal actuals. The workflow keeps budgets as repository data so budget-vs-actual output remains reproducible.

1. Alice initializes the budgeting area if it does not yet exist:

```bash
bus budget init
```

2. Alice records budgets for the accounts and periods she cares about:

```bash
bus budget add --help
bus budget add ...
```

For example, she enters rows for office supplies and travel so the budgeting dataset expresses her intent explicitly rather than embedding it in a report configuration.

3. Alice produces a budget-vs-actual variance report for the year or period:

```bash
bus budget report --help
bus budget report --year 2026
```

The report aggregates actual expenses from the ledger and compares them to the stored budgets, producing output such as:

```text
Expense Category     Budget Q1   Actual Q1   Variance
Office Supplies      €500.00     €300.00     €+200.00
Travel               €800.00     €950.00     €-150.00
```

If Alice adjusts her plan mid-year, she appends new budget rows (or uses `bus budget set` when the module supports upsert semantics), then re-runs the report to keep variance output aligned with the current budget dataset.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-assisted-classification-review">AI-assisted classification (review before external commit)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./configure-chart-of-accounts">Configure the chart of accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

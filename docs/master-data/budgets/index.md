---
title: Budgets
description: Budgets are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Budgets

Budgets are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus budget](../../modules/bus-budget). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus reports](../../modules/bus-reports) compares actuals to budgets in reporting outputs, and [bus journal](../../modules/bus-journal) provides actuals used for variance calculations.

### Actions

[Set a budget line](./set) records budget amounts per account and period so variance output is deterministic. [Report budget vs actual](./report) emits period or yearly variance results based on budget lines and journal actuals.

### Properties

Core budget fields are [`ledger_account_id`](./ledger-account-id), [`year`](./year), [`period`](./period), and [`amount`](./amount).

### Relations

A budget line belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

A budget line references one [ledger account](../chart-of-accounts/index) via [`ledger_account_id`](./ledger-account-id) and one [accounting period](../accounting-periods/index) via `year` and [`period`](./period), so reporting can compare actuals to budget in the same scope and structure.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Budgets</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workflow: Budgeting and budget vs actual](../../workflow/budgeting-and-budget-vs-actual)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)

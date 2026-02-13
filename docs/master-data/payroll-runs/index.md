---
title: Payroll runs
description: Payroll runs are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Payroll runs

Payroll runs are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus payroll](../../modules/bus-payroll). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): receives the balanced postings produced by payroll runs.
- [bus period](../../modules/bus-period): provides period control for month-based payroll workflows.

### Actions

- [Run payroll](./run): Compute payroll for a month and produce posting intent for wages and withholdings.
- [List payroll runs](./list): List runs so a reviewer can confirm what has been produced for a month.

### Properties

- [`run_id`](./run-id): Payroll run identity.
- [`month`](./month): Payroll month.
- [`pay_date`](./pay-date): Pay date.

### Relations

A payroll run belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

A payroll run is computed from the employee register, typically including all [employees](../employees/index) active in the run month. The run produces posting intent that references [ledger accounts](../chart-of-accounts/index) through the account fields stored on employees.

Payroll runs are month-based and rely on [accounting periods](../accounting-periods/index) to keep close and lock rules deterministic for payroll workflows.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Payroll runs</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Double-entry ledger](../../design-goals/double-entry-ledger)


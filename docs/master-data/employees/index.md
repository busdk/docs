## Employees

Employees are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus payroll](../../modules/bus-payroll). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): receives payroll posting outputs derived from payroll runs.
- [bus accounts](../../modules/bus-accounts): provides accounts referenced by payroll posting fields.

### Actions

- [Register an employee](./register): Create an employee record so payroll runs have a stable person reference.
- [Set employee pay structure](./set-pay-structure): Record gross pay and withholding parameters used for payroll calculation and postings.

### Properties

- [`employee_id`](./employee-id): Employee identity.
- [`entity_id`](./entity-id): Party reference for the employee.
- [`start_date`](./start-date): Employment start date.
- [`end_date`](./end-date): Employment end date.
- [`gross`](./gross): Gross pay amount.
- [`withholding_rate`](./withholding-rate): Withholding rate.
- [`wage_expense_account_id`](./wage-expense-account-id): Wage expense account.
- [`withholding_payable_account_id`](./withholding-payable-account-id): Withholding payable account.
- [`net_payable_account_id`](./net-payable-account-id): Net wages payable account.

### Relations

An employee belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

An employee references one [party](../parties/index) via [`entity_id`](./entity-id) so that identity, payment identifiers, and deduplication rules can be shared with other counterparty workflows.

Payroll runs consume employee records to compute wages and withholdings for a month. Employee pay structure fields reference [ledger accounts](../chart-of-accounts/index) so payroll outputs can be posted consistently.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Employees</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Double-entry ledger](../../design-goals/double-entry-ledger)


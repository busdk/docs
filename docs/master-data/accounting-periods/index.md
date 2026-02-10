## Accounting periods

Accounting periods are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus period](../../modules/bus-period). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): respects period close and lock boundaries for postings.
- [bus validate](../../modules/bus-validate): checks period integrity as part of workspace validation.
- [bus filing](../../modules/bus-filing): consumes closed-period data for filing bundles.

### Actions

- [Open an accounting period](./open): Mark a period open so bookkeeping work can proceed for that period.
- [Close an accounting period](./close): Generate closing entries and mark the period closed for review.
- [Lock an accounting period](./lock): Prevent further changes to closed period data.

### Properties

- [`period`](./period): Period identifier.
- [`status`](./status): Period status.
- [`post_date`](./post-date): Closing post date.

### Relations

Accounting periods belong to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

Period boundaries affect when postings can be finalized and locked, and they are referenced by workflows that are period-based by definition, such as budget variance and month-based payroll.

Budgets reference accounting periods via [`period`](../budgets/period) and `year`. Payroll runs reference months and rely on period control to keep month-close workflows deterministic.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workflow: Year-end close (closing entries)](../../workflow/year-end-close)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


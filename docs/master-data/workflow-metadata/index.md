## Bookkeeping status and review workflow

Bookkeeping needs minimal process metadata that turns operational records into a reviewable queue. These fields do not change the accounting meaning of an invoice or a bank transaction, but they make it clear what is ready to book, what has been booked, and what needs attention.

This workflow metadata is typically stored on sales invoices, purchase invoices, and bank transactions. Keeping it consistent across objects allows one unified “bookkeeping inbox” view even when the underlying objects differ.

### Ownership

Owner: [bus invoices](../../modules/bus-invoices). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus bank](../../modules/bus-bank): reuses the same status vocabulary for bank transaction inbox workflows.
- [bus reconcile](../../modules/bus-reconcile): uses status to separate matched and unresolved items.
- [bus validate](../../modules/bus-validate): checks that workflow fields are consistent where required.

### Actions

- [Triage items for bookkeeping](./triage): Set review state and evidence completeness so the bookkeeping inbox stays actionable.
- [Book an item](./book): Record that the bookkeeping decision is finalized with booking timestamp and actor.
- [Lock an item](./lock): Prevent further edits once a period is closed or an item is finalized.

### Properties

- [`accounting_status`](./accounting-status): Review state.
- [`booked_at`](./booked-at): Booking timestamp.
- [`booked_by`](./booked-by): Booking actor.
- [`accounting_note`](./accounting-note): Exception explanation.
- [`evidence_status`](./evidence-status): Evidence completeness signal.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../parties/index">Parties (customers and suppliers)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../sales-invoices/index">Sales invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Workflow takeaways](../../workflow/workflow-takeaways)


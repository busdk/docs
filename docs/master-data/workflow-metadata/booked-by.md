## `booked_by` (booking actor)

`booked_by` records who confirmed that a record was booked for bookkeeping purposes. It supports auditability and makes later review easier, because it preserves accountability for booking decisions and exceptions.

Even in a single-user system, booking actor information reduces ambiguity when reviewing historical periods and helps explain why a record was booked in a particular way.

Example values: `jane.doe`, `accountant`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./booked-at">booked_at</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bookkeeping status and review workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./accounting-note">accounting_note</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Workflow takeaways](../../workflow/workflow-takeaways)


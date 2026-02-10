## `booked_at` (booking timestamp)

`booked_at` records when a record was considered booked for bookkeeping purposes. It supports auditability and helps explain differences between operational timelines and reported figures, especially when items are booked after the fact.

When booking time is explicit, a reviewer can later reconstruct when the bookkeeping decision was finalized without relying on Git commit times or file modification times.

Example values: `2026-02-10T15:04:05Z`, `2026-03-01T09:30:00Z`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./accounting-status">accounting_status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bookkeeping status and review workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./booked-by">booked_by</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Workflow takeaways](../../workflow/workflow-takeaways)


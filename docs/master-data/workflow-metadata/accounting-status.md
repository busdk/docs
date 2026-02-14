---
title: "`accounting_status` (review state)"
description: accounting_status is a short status that expresses where a record is in the bookkeeping workflow, such as new, ready, booked, locked, matched, or ignored.
---

## `accounting_status` (review state)

`accounting_status` is a short status that expresses where a record is in the bookkeeping workflow, such as new, ready, booked, locked, matched, or ignored. It turns operational records into a reviewable queue without requiring readiness to be re-derived from many fields.

Statuses are workflow signals. The accounting evidence remains the invoice content, bank transaction facts, and linked documents, but the status determines what the reviewer expects to handle next.

Example values: `new`, `booked`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Bookkeeping status and review workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bookkeeping status and review workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./booked-at">booked_at</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)
- [Workflow takeaways](../../workflow/workflow-takeaways)


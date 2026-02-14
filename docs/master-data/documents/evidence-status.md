---
title: "`evidence_status` (evidence completeness signal)"
description: evidence_status expresses whether the evidence document is present and acceptable for booking, such as missing, ok, or needs_review.
---

## `evidence_status` (evidence completeness signal)

`evidence_status` expresses whether the evidence document is present and acceptable for booking, such as missing, ok, or needs_review. Bookkeeping uses this as a workflow signal to avoid booking items without proper attachments.

This is the same workflow field as [`evidence_status` in bookkeeping status and review workflow](../workflow-metadata/evidence-status).

Example values: `ok`, `needs_review`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./document-role">document_role</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./linked-entity-reference">linked_entity_reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


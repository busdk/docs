---
title: `content_type` (file type)
description: content_type records the document’s file type, such as a PDF or an image.
---

## `content_type` (file type)

`content_type` records the document’s file type, such as a PDF or an image. Bookkeeping uses file type for predictable retrieval and for exports and compliance workflows that depend on handling different evidence formats correctly.

When content type is explicit, tooling can process documents deterministically without guessing based on file extensions.

Example values: `application/pdf`, `image/jpeg`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./doc-date">doc_date</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./path">path</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


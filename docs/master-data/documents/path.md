---
title: "`path` (file locator)"
description: path is the locator used to retrieve the evidence file.
---

## `path` (file locator)

`path` is the locator used to retrieve the evidence file. Bookkeeping requires evidence to be retrievable deterministically during review and audit work, so a stored locator must remain stable enough that the file can be found without manual searching.

The exact storage scheme can vary, but the bookkeeping requirement is that the locator reliably opens the correct file when navigating from transactions or postings.

Example values: `attachments/2026/02/20260215-PI-2026-000045.pdf`, `attachments/2026/01/20260115-INV-1001.pdf` (path pattern `attachments/yyyy/mm/yyyymmdd-filename...`).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./content-type">content_type</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./document-role">document_role</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


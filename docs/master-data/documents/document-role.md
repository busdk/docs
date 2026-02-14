---
title: "`document_role` (purpose classification)"
description: document_role classifies what the document represents, such as purchase invoice PDF, sales invoice PDF, receipt, contract, or statement.
---

## `document_role` (purpose classification)

`document_role` classifies what the document represents, such as purchase invoice PDF, sales invoice PDF, receipt, contract, or statement. Bookkeeping uses roles to filter evidence, run completeness checks, and prevent mis-linking arbitrary files as accounting evidence.

When roles are explicit, “missing evidence” and audit checklists become straightforward and deterministic.

Example values: `purchase_invoice_pdf`, `receipt`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./path">path</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evidence-status">evidence_status</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


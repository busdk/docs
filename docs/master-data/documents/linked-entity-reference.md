---
title: "`linked_entity_reference` (navigable evidence trail)"
description: linked_entity_reference is the reference that links the evidence document to the invoice, bank transaction, or other bookable record it supports.
---

## `linked_entity_reference` (navigable evidence trail)

`linked_entity_reference` is the reference that links the evidence document to the invoice, bank transaction, or other bookable record it supports. Bookkeeping requires that reviewers can navigate from booked entries back to the exact evidence file that justified them.

The implementation can vary, but the bookkeeping requirement is that the linkage is reliable and supports audit navigation by period and counterparty.

Example values: `PI-2026-000045`, `SI-2026-000123`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evidence-status">evidence_status</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../bank-accounts/index">Bank accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


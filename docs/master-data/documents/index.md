---
title: Documents (evidence)
description: A document is the evidence file that supports a transaction, such as a PDF invoice, receipt, contract, or statement.
---

## Documents (evidence)

A document is the evidence file that supports a transaction, such as a PDF invoice, receipt, contract, or statement. Bookkeeping needs documents to be linkable and auditable by period, counterparty, and transaction so that every posting can be justified later.

### Ownership

Owner: [bus attachments](../../modules/bus-attachments). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus invoices](../../modules/bus-invoices): links evidence to invoices for audit trails.
- [bus bank](../../modules/bus-bank): links evidence to statement items when needed.
- [bus journal](../../modules/bus-journal): is reviewable through links from postings back to evidence.

### Actions

- [Register an evidence document](./register): Add the evidence file and its metadata so bookkeeping can retrieve it deterministically.
- [Link evidence to a record](./link): Attach evidence to an invoice or bank transaction so audit navigation is one step.
- [Review evidence completeness](./review): Mark evidence status so items are not booked without acceptable attachments.

### Properties

- [`document_id`](./document-id): Document identity.
- [`doc_date`](./doc-date): Document date.
- [`content_type`](./content-type): File type.
- [`path`](./path): File locator.
- [`document_role`](./document-role): Purpose classification.
- [`evidence_status`](./evidence-status): Evidence completeness signal.
- [`linked_entity_reference`](./linked-entity-reference): Navigable evidence trail.

### Relations

A document belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

A document can be linked to one or more bookkeeping records using [`linked_entity_reference`](./linked-entity-reference). In practice the primary targets are [sales invoices](../sales-invoices/index), [purchase invoices](../purchase-invoices/index), and [bank transactions](../bank-transactions/index), so that reviewers can navigate from postings and open items back to evidence.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../purchase-posting-specifications/index">Purchase posting specifications</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../bank-accounts/index">Bank accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice PDF storage](../../layout/invoice-pdf-storage)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


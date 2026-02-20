---
title: Documents (evidence)
description: A document is the evidence file that supports a transaction, such as a PDF invoice, receipt, contract, or statement.
---

## Documents (evidence)

A document is the evidence file that supports a transaction, such as a PDF invoice, receipt, contract, or statement. Bookkeeping needs documents to be linkable and auditable by period, counterparty, and transaction so that every posting can be justified later.

### Ownership

Owner: [bus attachments](../../modules/bus-attachments). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus invoices](../../modules/bus-invoices) links evidence to invoices for audit trails. [bus bank](../../modules/bus-bank) links evidence to statement items when needed, and [bus journal](../../modules/bus-journal) is reviewable through links from postings back to evidence.

### Actions

[Register an evidence document](./register) adds evidence files and metadata for deterministic retrieval. [Link evidence to a record](./link) attaches evidence to invoices or bank transactions for one-step audit navigation. [Review evidence completeness](./review) marks evidence status so items are not booked without acceptable attachments.

### Properties

Core document fields are [`document_id`](./document-id), [`doc_date`](./doc-date), [`content_type`](./content-type), [`path`](./path), and [`document_role`](./document-role). Workflow and linkage fields are [`evidence_status`](./evidence-status) and [`linked_entity_reference`](./linked-entity-reference).

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

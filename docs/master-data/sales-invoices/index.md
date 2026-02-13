---
title: Sales invoices
description: A sales invoice is a legal and accounting document that creates revenue and a receivable until it is paid.
---

## Sales invoices

A sales invoice is a legal and accounting document that creates revenue and a receivable until it is paid. In bookkeeping, sales invoices become postings and later become open items for payment matching and receivables review.

### Ownership

Owner: [bus invoices](../../modules/bus-invoices). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus attachments](../../modules/bus-attachments): stores evidence references used by invoices.
- [bus journal](../../modules/bus-journal): receives posting outputs derived from invoices.
- [bus vat](../../modules/bus-vat): reads invoice VAT for period reporting.
- [bus reconcile](../../modules/bus-reconcile): links payments to open invoices.

### Actions

- [Create a sales invoice](./create): Record the legal and accounting document that creates revenue and a receivable.
- [Correct a sales invoice](./correct): Record credit notes or corrections so the audit trail remains consistent.
- [Prepare sales invoice postings](./prepare-posting): Turn invoice intent into a balanced posting proposal for the journal.

### Properties

- [`invoice_id`](./invoice-id): Invoice identity.
- [`client_id`](./client-id): Counterparty link.
- [`date`](./date): Invoice date.
- [`duedate`](./duedate): Due date.
- [`reference_number`](./reference-number): Payment matching key.
- [`currency`](./currency): Invoice currency.
- [`service_start_date`](./service-start-date): Service period start.
- [`service_end_date`](./service-end-date): Service period end.

Sales invoices typically also use the shared workflow fields described in [Bookkeeping status and review workflow](../workflow-metadata/index), and they belong to the workspace’s [accounting entity](../accounting-entity/index).

### Relations

A sales invoice belongs to the workspace’s [accounting entity](../accounting-entity/index) and references one [party](../parties/index) (the customer) via [`client_id`](./client-id).

A sales invoice can have one or more [sales invoice rows](../sales-invoice-rows/index). Rows reference their parent invoice via [`invoice_id`](../sales-invoice-rows/invoice-id).

A sales invoice can be settled by one or more [reconciliations](../reconciliations/index) that link a [bank transaction](../bank-transactions/index) to the invoice’s open item.

A sales invoice can have zero or more [documents (evidence)](../documents/index) linked to it for audit navigation.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow-metadata/index">Bookkeeping status and review workflow</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../sales-invoice-rows/index">Sales invoice rows</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Create sales invoice](../../workflow/create-sales-invoice)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)


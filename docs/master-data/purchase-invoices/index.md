---
title: Purchase invoices
description: A purchase invoice is the incoming vendor invoice that creates an expense or an asset and a payable until it is paid.
---

## Purchase invoices

A purchase invoice is the incoming vendor invoice that creates an expense or an asset and a payable until it is paid. Purchase invoices drive VAT deduction and periodization decisions, and they are a core evidence object in bookkeeping review.

### Ownership

Owner: [bus invoices](../../modules/bus-invoices). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus attachments](../../modules/bus-attachments): stores evidence references used by purchases.
- [bus vat](../../modules/bus-vat): uses purchase VAT for period reporting.
- [bus reconcile](../../modules/bus-reconcile): matches payments to vendor invoices.

### Actions

- [Record a purchase invoice](./record): Register the incoming invoice as evidence and as the basis for payables and VAT.
- [Classify a purchase invoice](./classify): Create the posting intent split across accounts and VAT treatment decisions.
- [Prepare purchase invoice postings](./prepare-posting): Turn purchase intent into a balanced posting proposal for the journal.

### Properties

- [`purchase_invoice_id`](./purchase-invoice-id): Invoice identity.
- [`purchase_company_id`](./purchase-company-id): Supplier link.
- [`invoice_number`](./invoice-number): Supplier invoice number.
- [`date`](./date): Invoice date.
- [`duedate`](./duedate): Due date.
- [`reference_number`](./reference-number): Payment matching key.
- [`iban`](./iban): Supplier payment account.
- [`total_sum`](./total-sum): Invoice total (net).
- [`total_vat`](./total-vat): Invoice total VAT.
- [`total_sum_including_vat`](./total-sum-including-vat): Invoice total (gross).
- [`currency`](./currency): Invoice currency.
- [`service_start_date`](./service-start-date): Service period start.
- [`service_end_date`](./service-end-date): Service period end.

Purchase invoices also use shared workflow and evidence fields. See [`accounting_status`](../workflow-metadata/accounting-status), [`evidence_status`](../workflow-metadata/evidence-status), and [`accounting_note`](../workflow-metadata/accounting-note).

### Relations

A purchase invoice belongs to the workspace’s [accounting entity](../accounting-entity/index) and references one [party](../parties/index) (the supplier) via [`purchase_company_id`](./purchase-company-id).

A purchase invoice can have one or more [purchase posting specifications](../purchase-posting-specifications/index) that capture posting intent (accounts, VAT handling, and capitalizable lines) at the level where the booking decision is made.

A purchase invoice can be settled by one or more [reconciliations](../reconciliations/index) that link a [bank transaction](../bank-transactions/index) to the invoice’s open item.

A purchase invoice can have zero or more [documents (evidence)](../documents/index) linked to it for audit navigation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../sales-invoice-rows/index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../purchase-posting-specifications/index">Purchase posting specifications</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


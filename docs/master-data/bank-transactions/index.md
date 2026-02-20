---
title: Bank transactions
description: A bank transaction is the cash movement you reconcile against invoices and post for non-invoice events such as fees, taxes, loan payments, and payment…
---

## Bank transactions

A bank transaction is the cash movement you reconcile against invoices and post for non-invoice events such as fees, taxes, loan payments, and payment provider settlements. Bank transactions are a primary driver for automation because they confirm what actually happened in the bank account.

### Ownership

Owner: [bus bank](../../modules/bus-bank). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus reconcile](../../modules/bus-reconcile) records matches and allocations that reference bank transaction identity. [bus invoices](../../modules/bus-invoices) is matched against payments for open-item workflows, and [bus journal](../../modules/bus-journal) receives postings for non-invoice bank events.

### Actions

[Import bank transactions](./import) ingests statement feeds into normalized transactions suitable for reconciliation. [Match a bank transaction](./match) links cash movement to invoices or journal entries so open items close deterministically. [Classify a non-invoice bank transaction](./classify) records target ledger account and VAT intent for fees, taxes, and other events.

### Properties

Core properties are [`bank_transaction_id`](./bank-transaction-id), [`bank_account_id`](./bank-account-id), [`booking_date`](./booking-date), [`value_date`](./value-date), [`amount`](./amount), [`currency`](./currency), [`reference`](./reference), and [`rf_reference`](./rf-reference).

Counterparty fields include [`debtor_name`](./debtor-name), [`creditor_name`](./creditor-name), [`debtor_account`](./debtor-account), and [`creditor_account`](./creditor-account).

Matching and classification fields include [`matched_sale_invoice_id`](./matched-sale-invoice-id), [`matched_purchase_invoice_id`](./matched-purchase-invoice-id), [`client_id`](./client-id), [`purchase_company_id`](./purchase-company-id), [`ledger_account_id`](./ledger-account-id), [`vat_treatment`](./vat-treatment), and [`vat_deductible_percent`](./vat-deductible-percent).

Workflow metadata fields include [`accounting_status`](./accounting-status), [`booked_at`](./booked-at), [`booked_by`](./booked-by), and [`accounting_note`](./accounting-note).

Bank transactions belong to the workspace’s [accounting entity](../accounting-entity/index) and attach to a statement source via [`bank_account_id`](../bank-accounts/bank-account-id).

### Relations

A bank transaction belongs to one [bank account](../bank-accounts/index) via [`bank_account_id`](./bank-account-id). Its accounting scope is derived from the workspace root directory rather than from a per-row key.

A bank transaction can be linked to one or more [reconciliations](../reconciliations/index), which explain how the cash movement settles one or more targets such as a [sales invoice](../sales-invoices/index), a [purchase invoice](../purchase-invoices/index), or a journal transaction.

When the bank transaction represents a direct, non-invoice bookkeeping event, it can reference one [ledger account](../chart-of-accounts/index) via [`ledger_account_id`](./ledger-account-id) and one [VAT treatment](../vat-treatment/index) via [`vat_treatment`](./vat-treatment).

A bank transaction can have zero or more [documents (evidence)](../documents/index) linked to it for audit navigation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../bank-accounts/index">Bank accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../reconciliations/index">Reconciliations</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

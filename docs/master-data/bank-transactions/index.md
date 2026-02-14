---
title: Bank transactions
description: A bank transaction is the cash movement you reconcile against invoices and post for non-invoice events such as fees, taxes, loan payments, and payment…
---

## Bank transactions

A bank transaction is the cash movement you reconcile against invoices and post for non-invoice events such as fees, taxes, loan payments, and payment provider settlements. Bank transactions are a primary driver for automation because they confirm what actually happened in the bank account.

### Ownership

Owner: [bus bank](../../modules/bus-bank). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus reconcile](../../modules/bus-reconcile): records matches and allocations that reference bank transaction identity.
- [bus invoices](../../modules/bus-invoices): is matched against payments for open item workflows.
- [bus journal](../../modules/bus-journal): receives postings for non-invoice bank events.

### Actions

- [Import bank transactions](./import): Ingest a statement feed into normalized transactions suitable for reconciliation.
- [Match a bank transaction](./match): Link cash movement to an invoice or journal entry so open items close deterministically.
- [Classify a non-invoice bank transaction](./classify): Record the target ledger account and VAT intent for fees, taxes, and other events.

### Properties

- [`bank_transaction_id`](./bank-transaction-id): Bank transaction identity.
- [`bank_account_id`](./bank-account-id): Bank account link.
- [`booking_date`](./booking-date): Posting period date.
- [`value_date`](./value-date): Value date.
- [`amount`](./amount): Money movement amount.
- [`currency`](./currency): Money movement currency.
- [`reference`](./reference): Payment reference.
- [`rf_reference`](./rf-reference): RF reference.
- [`debtor_name`](./debtor-name): Counterparty name (debtor).
- [`creditor_name`](./creditor-name): Counterparty name (creditor).
- [`debtor_account`](./debtor-account): Counterparty account (debtor).
- [`creditor_account`](./creditor-account): Counterparty account (creditor).
- [`matched_sale_invoice_id`](./matched-sale-invoice-id): Sales invoice match.
- [`matched_purchase_invoice_id`](./matched-purchase-invoice-id): Purchase invoice match.
- [`client_id`](./client-id): Party link (customer-side).
- [`purchase_company_id`](./purchase-company-id): Party link (supplier-side).
- [`ledger_account_id`](./ledger-account-id): Classification target for non-invoice events.
- [`vat_treatment`](./vat-treatment): VAT handling code (when relevant).
- [`vat_deductible_percent`](./vat-deductible-percent): VAT deductibility (when relevant).
- [`accounting_status`](./accounting-status): Review state.
- [`booked_at`](./booked-at): Booking timestamp.
- [`booked_by`](./booked-by): Booking actor.
- [`accounting_note`](./accounting-note): Exception explanation.

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


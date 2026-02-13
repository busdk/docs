---
title: Reconciliations (bank-to-open-item links)
description: A reconciliation record links a bank transaction to the bookkeeping record it settles, such as an invoice or a journal transaction.
---

## Reconciliations (bank-to-open-item links)

A reconciliation record links a bank transaction to the bookkeeping record it settles, such as an invoice or a journal transaction. Reconciliations are the audit trail for “why is this cash movement considered handled”, and they make payment status and open-item review deterministic even when statements are imported repeatedly.

Reconciliation supports both one-to-one matches and multi-target allocations. A match is used when one bank transaction equals one target amount. An allocation is used when one bank transaction is split across multiple targets, such as partial payments, settlement batches, or fees booked separately from the invoice.

### Ownership

Owner: [bus reconcile](../../modules/bus-reconcile). This module is responsible for implementing write operations for reconciliation records and is the only module that should directly change the canonical datasets for them.

Secondary read-only use cases are provided by these modules when they consume reconciliation records for review, validation, posting, or reporting:

- [bus bank](../../modules/bus-bank): imports bank transactions that reconciliations reference.
- [bus invoices](../../modules/bus-invoices): uses reconciliations to close open invoices deterministically.
- [bus journal](../../modules/bus-journal): is referenced when allocations point to journal transactions.

### Actions

- [Match a bank transaction](./match): Record a one-to-one settlement link when amounts match exactly.
- [Allocate a bank transaction](./allocate): Record a split across multiple invoices and/or journal transactions.
- [List reconciliations](./list): Produce a reviewable list of reconciliation records.

### Properties

- [`reconciliation_id`](./reconciliation-id): Stable reconciliation record identifier.
- [`bank_transaction_id`](./bank-transaction-id): The bank transaction being settled.
- [`target_kind`](./target-kind): What kind of target is referenced (`invoice` or `journal`).
- [`target_id`](./target-id): Stable identifier of the referenced target record.
- [`amount`](./amount): Allocation amount in the bank transaction currency.

Reconciliations bind to bank transaction currency via [`currency` on bank transactions](../bank-transactions/currency) and belong to the workspace’s [accounting entity](../accounting-entity/index) because both the bank transactions and the reconciliation records live in the same workspace.

### Relations

A reconciliation belongs to one [bank transaction](../bank-transactions/index) via [`bank_transaction_id`](./bank-transaction-id).

A bank transaction can have one or more reconciliation records when a cash movement is allocated across multiple targets. Each reconciliation record points to exactly one target, identified by [`target_kind`](./target-kind) and [`target_id`](./target-id).

When `target_kind` is `invoice`, the target is either a [sales invoice](../sales-invoices/index) or a [purchase invoice](../purchase-invoices/index). When `target_kind` is `journal`, the target is a journal transaction.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../bank-transactions/index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payments](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)


---
title: Master data (business objects)
description: BusDK master data reference — chart of accounts, parties, invoices, bank transactions, and all business objects.
---

## Master data (business objects)

Master data is the stable reference layer that bookkeeping relies on when it turns operational events into ledger postings and period-based reports. The goal is that invoices, bank transactions, documents, and postings can all be scoped correctly, classified consistently, and reviewed later without guesswork. All master data that a module owns is stored in the workspace root (the effective working directory) only; BusDK does not store master data under subdirectories.

This section describes the business objects and the bookkeeping properties they need. The descriptions are concept-level and intentionally avoid implementation details so the same objects and properties can also support adjacent use cases such as CRM, procurement, and document management.

### Use case index

#### Bookkeeping foundations (shared across workflows)

- [Accounting entity](./accounting-entity/index): The bookkeeping scope defined by the workspace directory boundary, keeping journals, VAT, and reports separated per business entity.
- [Chart of accounts](./chart-of-accounts/index): The ledger accounts and reporting structure used for posting and review.
- [VAT treatment](./vat-treatment/index): The minimal VAT metadata that makes posting and VAT reporting deterministic.
- [Parties (customers and suppliers)](./parties/index): The counterparties attached to invoices, transactions, and sometimes postings.
- [Bookkeeping status and review workflow](./workflow-metadata/index): The small set of process fields that makes “inbox-style” bookkeeping possible across objects.
- [Accounting periods](./accounting-periods/index): Period open/close/lock control data used across modules.

#### Sales (invoicing and receivables)

- [Sales invoices](./sales-invoices/index): Outgoing invoices that create income and a receivable until paid.
- [Sales invoice rows](./sales-invoice-rows/index): Line-level intent that drives income account selection and VAT handling.

#### Purchasing (vendor invoices, payables, and posting intent)

- [Purchase invoices](./purchase-invoices/index): Incoming invoices that create an expense or asset and a payable until paid.
- [Purchase posting specifications](./purchase-posting-specifications/index): The posting intent for purchases, typically split across accounts.

#### Cash and banking (imports, matching, and non-invoice events)

- [Bank accounts](./bank-accounts/index): The financial accounts that transactions belong to and that map to ledger accounts.
- [Bank transactions](./bank-transactions/index): Cash movements used for reconciliation and for non-invoice bookkeeping events.
- [Reconciliations](./reconciliations/index): Append-only links and allocations that explain how cash movement settles invoices and journal transactions.

#### Evidence and audit support (documents)

- [Documents (evidence)](./documents/index): Evidence files and metadata that keep postings auditable by period and counterparty.

#### Fixed assets (depreciation and disposals)

- [Fixed assets](./fixed-assets/index): The asset register used for depreciation and disposals.

#### Financing (loans and amortization)

- [Loans](./loans/index): Loan contracts and event logs that drive amortization and postings.

#### Payroll (employees and payroll runs)

- [Employees](./employees/index): Employee reference data used for payroll runs and postings.
- [Payroll runs](./payroll-runs/index): Month-based payroll run records that produce postings.

#### Inventory (stock and valuation)

- [Inventory items](./inventory-items/index): Item master data used for stock movements and valuation.
- [Inventory movements](./inventory-movements/index): Append-only stock movement records used for audit and valuation.

#### Planning (budgets and variance)

- [Budgets](./budgets/index): Budget lines keyed by account and period for variance reporting.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../layout/index">Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./accounting-entity/index">Accounting entity</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Data directory layout](../layout/index)


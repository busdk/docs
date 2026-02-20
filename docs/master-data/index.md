---
title: Master data (business objects)
description: BusDK master data reference — chart of accounts, parties, invoices, bank transactions, and all business objects.
---

## Master data (business objects)

Master data is the stable reference layer that bookkeeping relies on when it turns operational events into ledger postings and period-based reports. The goal is that invoices, bank transactions, documents, and postings can all be scoped correctly, classified consistently, and reviewed later without guesswork. All master data that a module owns is stored in the workspace root (the effective working directory) only; BusDK does not store master data under subdirectories.

This section describes the business objects and the bookkeeping properties they need. The descriptions are concept-level and intentionally avoid implementation details so the same objects and properties can also support adjacent use cases such as CRM, procurement, and document management.

### Use case index

#### Bookkeeping foundations (shared across workflows)

[Accounting entity](./accounting-entity/index) defines bookkeeping scope through workspace boundaries, so journals, VAT, and reports stay separated per business entity. [Chart of accounts](./chart-of-accounts/index) defines posting and reporting structure, and [VAT treatment](./vat-treatment/index) carries the VAT metadata needed for deterministic posting and reporting. [Parties (customers and suppliers)](./parties/index), [bookkeeping status and review workflow](./workflow-metadata/index), and [accounting periods](./accounting-periods/index) provide counterparty, process-state, and open/close/lock controls shared across modules.

#### Sales (invoicing and receivables)

[Sales invoices](./sales-invoices/index) represent outgoing invoices that create income and receivables, while [sales invoice rows](./sales-invoice-rows/index) carry line-level intent that drives income-account and VAT handling.

#### Purchasing (vendor invoices, payables, and posting intent)

[Purchase invoices](./purchase-invoices/index) represent incoming invoices that create expenses or assets and payables until paid. [Purchase posting specifications](./purchase-posting-specifications/index) describe deterministic posting intent, often split across multiple accounts.

#### Cash and banking (imports, matching, and non-invoice events)

[Bank accounts](./bank-accounts/index) identify financial accounts and their ledger mapping. [Bank transactions](./bank-transactions/index) capture cash movements used for reconciliation and non-invoice bookkeeping, and [reconciliations](./reconciliations/index) store append-only links and allocations that explain settlement against invoices and journal transactions.

#### Evidence and audit support (documents)

[Documents (evidence)](./documents/index) capture evidence files and metadata so postings remain auditable by period and counterparty.

#### Fixed assets (depreciation and disposals)

[Fixed assets](./fixed-assets/index) define the asset register used for depreciation and disposal workflows.

#### Financing (loans and amortization)

[Loans](./loans/index) define loan contracts and event logs that drive amortization and related postings.

#### Payroll (employees and payroll runs)

[Employees](./employees/index) provide payroll reference data, and [payroll runs](./payroll-runs/index) represent period payroll records that produce postings.

#### Inventory (stock and valuation)

[Inventory items](./inventory-items/index) provide item master data used in valuation, and [inventory movements](./inventory-movements/index) provide append-only stock movements for valuation and auditability.

#### Planning (budgets and variance)

[Budgets](./budgets/index) define budget lines keyed by account and period for variance reporting.

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

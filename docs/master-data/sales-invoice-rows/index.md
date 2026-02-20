---
title: Sales invoice rows
description: A sales invoice row is the line-level specification of what was sold.
---

## Sales invoice rows

A sales invoice row is the line-level specification of what was sold. For bookkeeping, invoice rows are the best place to record posting intent because they determine the income account and VAT handling more precisely than invoice headers.

### Ownership

Owner: [bus invoices](../../modules/bus-invoices). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus accounts](../../modules/bus-accounts) provides the chart used for income-account selection, and [bus vat](../../modules/bus-vat) uses line-level VAT fields for reporting and validation.

### Actions

[Classify a sales invoice row](./classify) records income account and VAT treatment so sales bookkeeping remains deterministic. [Set sales row service period](./periodize) records service dates when period allocation depends on delivered period.

### Properties

Core row identity and amount fields are [`invoice_row_id`](./invoice-row-id), [`invoice_id`](./invoice-id), [`description`](./description), [`amount`](./amount), [`price`](./price), and [`discount_percent`](./discount-percent).

Tax and posting-intent fields are [`vat_percent`](./vat-percent), [`ledger_account_id`](./ledger-account-id), [`vat_treatment`](./vat-treatment), and optional reporting tag [`dimension`](./dimension).

Service-period fields are [`service_start_date`](./service-start-date) and [`service_end_date`](./service-end-date).

Sales invoice rows belong to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory, and rows typically reference accounts via [`ledger_account_id`](../chart-of-accounts/ledger-account-id).

### Relations

A sales invoice row belongs to one [sales invoice](../sales-invoices/index) via [`invoice_id`](./invoice-id). A sales invoice typically has one or more rows that together describe what was sold.

A sales invoice row references one [ledger account](../chart-of-accounts/index) via [`ledger_account_id`](./ledger-account-id) and one [VAT treatment](../vat-treatment/index) via [`vat_treatment`](./vat-treatment) and [`vat_percent`](./vat-percent).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../sales-invoices/index">Sales invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../purchase-invoices/index">Purchase invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)

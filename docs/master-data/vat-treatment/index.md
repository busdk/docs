---
title: VAT treatment (lightweight master)
description: VAT handling needs more than a percentage to be deterministic.
---

## VAT treatment (lightweight master)

VAT handling needs more than a percentage to be deterministic. Bookkeeping and VAT reporting require enough structured VAT metadata that “0%” and other edge cases are still explainable, reviewable, and exportable without relying on free-text descriptions.

This VAT treatment master is intentionally lightweight. It defines the minimal fields you need at the point where you decide posting, typically on sales invoice rows and purchase posting specifications, and sometimes on bank transactions when you book a receipt-like purchase directly from the bank statement.

### Ownership

Owner: [bus vat](../../modules/bus-vat). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus invoices](../../modules/bus-invoices) records VAT rate and treatment at line level for evidence and validation. [bus journal](../../modules/bus-journal) is reconciled against invoice VAT for period reporting, and [bus validate](../../modules/bus-validate) checks VAT mappings and invariants across datasets.

### Actions

[Define VAT treatment codes](./define) maintains allowed treatment codes so 0% and special cases stay deterministic. [Invoice markings for VAT treatments](./invoice-markings) maps treatment codes to required invoice markings and identifiers. [Validate VAT mappings](./validate) checks alignment between rates, treatment codes, and reporting expectations.

### Properties

Core VAT fields are [`vat_rate`](./vat-rate), [`vat_percent`](./vat-percent), [`vat_treatment`](./vat-treatment), and [`vat_deductible_percent`](./vat-deductible-percent).

### Relations

VAT treatment codes are referenced at the level where posting intent is recorded. Sales invoice rows reference VAT treatment via [`vat_treatment`](../sales-invoice-rows/vat-treatment) and rate via [`vat_percent`](../sales-invoice-rows/vat-percent).

Purchase posting specifications reference VAT treatment via [`vat_treatment`](../purchase-posting-specifications/vat-treatment), rate via [`vat_rate`](../purchase-posting-specifications/vat-rate), and deductibility via [`vat_deductible_percent`](../purchase-posting-specifications/vat-deductible-percent).

Bank transactions can reference VAT treatment directly when the cash movement is booked as a non-invoice event using [`vat_treatment`](../bank-transactions/vat-treatment) and [`vat_deductible_percent`](../bank-transactions/vat-deductible-percent).

Parties can carry a default VAT treatment via [`default_vat_treatment`](../parties/default-vat-treatment) to make classification and validation deterministic.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../chart-of-accounts/index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../parties/index">Parties (customers and suppliers)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

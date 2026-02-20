---
title: Purchase posting specifications
description: A purchase posting specification records the bookkeeping intent for a purchase invoice.
---

## Purchase posting specifications

A purchase posting specification records the bookkeeping intent for a purchase invoice. It typically splits the purchase across one or more expense or asset accounts and captures the VAT handling decisions at the level where posting is decided.

Even when you treat the vendor invoice as the primary evidence, the posting specification is what makes bookkeeping automation possible. It is the structured explanation of how the invoice becomes debits and credits.

### Ownership

Owner: [bus invoices](../../modules/bus-invoices). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus journal](../../modules/bus-journal) receives posting outputs derived from purchase specifications, and [bus vat](../../modules/bus-vat) validates VAT logic from purchase posting lines.

### Actions

[Split a purchase across accounts](./split) records multi-line intent so expenses and assets post to correct accounts. [Decide purchase VAT handling](./decide-vat) records VAT treatment and deductibility at posting-decision level. [Mark a line as capitalizable](./mark-capitalizable) captures asset intent so later fixed-asset flows stay consistent.

### Properties

Core posting fields are [`ledger_account_id`](./ledger-account-id), [`amount`](./amount), and optional review note [`description`](./description).

VAT fields are [`vat_treatment`](./vat-treatment), [`vat_rate`](./vat-rate), [`vat_amount`](./vat-amount), and [`vat_deductible_percent`](./vat-deductible-percent).

Optional classification fields are [`dimension`](./dimension), [`is_capitalizable`](./is-capitalizable), and [`asset_class_hint`](./asset-class-hint).

### Relations

A purchase posting specification belongs to a [purchase invoice](../purchase-invoices/index). It captures how the invoice amount is split across one or more [ledger accounts](../chart-of-accounts/index) and which [VAT treatment](../vat-treatment/index) applies to each line.

When `is_capitalizable` is set, the line indicates fixed-asset intent that later [fixed asset](../fixed-assets/index) workflows can consume to keep asset capitalization consistent with what was booked.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../purchase-invoices/index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../documents/index">Documents (evidence)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

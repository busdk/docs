---
title: Parties (customers and suppliers)
description: A party is the counterparty you transact with.
---

## Parties (customers and suppliers)

A party is the counterparty you transact with. For bookkeeping, customers and suppliers are the same concept: the party attached to an invoice, a bank transaction, and sometimes directly to a posting for review and audit navigation.

Party master data reduces duplicates, improves matching, and makes reports and evidence trails easier to read. Even when you keep separate “clients” and “purchase companies” in operational screens, bookkeeping benefits from treating them as one master concept with shared identifiers and defaults.

### Ownership

Owner: [bus entities](../../modules/bus-entities). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

In the current CLI surface, `bus entities add` records the stable entity identifier and display name. Other party fields that exist in the workspace schema (such as business identifiers, VAT numbers, country codes, payment identifiers, and default bookkeeping fields) are maintained by editing `entities.csv` directly and validating with `bus validate`, so field editability remains explicit and script-friendly.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus invoices](../../modules/bus-invoices): references parties on invoices for receivables and payables.
- [bus bank](../../modules/bus-bank): uses party data for matching and counterparty display.
- [bus reconcile](../../modules/bus-reconcile): matches cash movement to invoices and parties.

### Actions

- [Register a party](./register): Create or import a counterparty record so invoices and matching can link deterministically.
- [Deduplicate parties](./deduplicate): Merge duplicates so reports and audits refer to one legal entity consistently.
- [Set party bookkeeping defaults](./set-defaults): Maintain default accounts, VAT handling, and payment identifiers used for pre-fill and matching.

### Properties

- [`party_name`](./party-name): Counterparty label.
- [`business_id`](./business-id): Strong national identifier.
- [`vat_number`](./vat-number): VAT identity for cross-border rules.
- [`country_code`](./country-code): Jurisdiction hint.
- [`default_sales_account_id`](./default-sales-account-id): Classification default (sales).
- [`default_expense_account_id`](./default-expense-account-id): Classification default (purchases).
- [`default_vat_treatment`](./default-vat-treatment): VAT handling default.
- [`payment_identifiers`](./payment-identifiers): Matching and payment hints.

Party defaults and identifiers support deterministic [VAT treatment](../vat-treatment/index) selection and validation, especially when cross-border rules and exemptions apply.

### Relations

A party belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory, and the same party record can be referenced by multiple bookkeeping objects over time.

Sales invoices reference a customer party via [`client_id`](../sales-invoices/client-id). Purchase invoices reference a supplier party via [`purchase_company_id`](../purchase-invoices/purchase-company-id). Bank transactions can reference parties on either side using [`client_id`](../bank-transactions/client-id) and [`purchase_company_id`](../bank-transactions/purchase-company-id).

Employees reference a party record via [`entity_id`](../employees/entity-id) so payroll can keep identity and payment data consistent with the party master. Loans reference a party via [`counterparty_id`](../loans/counterparty-id).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../vat-treatment/index">VAT treatment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../workflow-metadata/index">Bookkeeping status and review workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [AI-assisted classification review](../../workflow/ai-assisted-classification-review)


---
title: Loans
description: Loans are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Loans

Loans are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus loans](../../modules/bus-loans). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

[bus journal](../../modules/bus-journal) receives postings derived from loan events and amortization. [bus entities](../../modules/bus-entities) provides referenced counterparties, and [bus accounts](../../modules/bus-accounts) provides accounts used by loan posting fields.

### Actions

[Register a loan](./register) records loan contracts so repayments and interest can be booked consistently. [Record a loan event](./record-event) appends disbursements, repayments, interest, fees, and adjustments as auditable event history. [Amortize a loan](./amortize) generates period amortization schedule and posting intent.

### Properties

Core contract fields are [`loan_id`](./loan-id), [`counterparty_id`](./counterparty-id), [`principal_amount`](./principal-amount), [`start_date`](./start-date), [`maturity_date`](./maturity-date), and [`interest_rate`](./interest-rate).

Posting-account fields are [`principal_account_id`](./principal-account-id), [`interest_account_id`](./interest-account-id), and [`cash_account_id`](./cash-account-id).

### Relations

A loan belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

A loan references one [party](../parties/index) (lender or borrower) via [`counterparty_id`](./counterparty-id).

A loan references [ledger accounts](../chart-of-accounts/index) via its account-id fields so that principal, interest, and cash movement can be posted consistently.

Amortization is produced for a given [accounting period](../accounting-periods/index), based on the loan’s event history.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Loans</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)

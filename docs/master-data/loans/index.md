## Loans

Loans are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus loans](../../modules/bus-loans). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): receives posting outputs derived from loan events and amortization.
- [bus entities](../../modules/bus-entities): provides counterparties referenced by loans.
- [bus accounts](../../modules/bus-accounts): provides the accounts referenced by loan posting fields.

### Actions

- [Register a loan](./register): Record a loan contract so repayments and interest can be booked consistently.
- [Record a loan event](./record-event): Append disbursements, repayments, interest, fees, and adjustments as an auditable event log.
- [Amortize a loan](./amortize): Generate amortization schedule and posting intent for a period.

### Properties

- [`loan_id`](./loan-id): Loan identity.
- [`counterparty_id`](./counterparty-id): Lender or borrower party reference.
- [`principal_amount`](./principal-amount): Principal amount.
- [`start_date`](./start-date): Start date.
- [`maturity_date`](./maturity-date): Maturity date.
- [`interest_rate`](./interest-rate): Nominal interest rate.
- [`principal_account_id`](./principal-account-id): Principal account.
- [`interest_account_id`](./interest-account-id): Interest expense account.
- [`cash_account_id`](./cash-account-id): Cash or bank account.

---

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


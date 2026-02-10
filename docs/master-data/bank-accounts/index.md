## Bank accounts

A bank account is the financial account where bank transactions occur. Bookkeeping uses bank accounts to group transactions by statement source, to reconcile cash movement, and to map statement activity into ledger postings consistently.

### Ownership

Owner: [bus bank](../../modules/bus-bank). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus accounts](../../modules/bus-accounts): provides the ledger accounts used for bank-to-ledger mapping.
- [bus reconcile](../../modules/bus-reconcile): uses bank account identity for matching and allocation.
- [bus journal](../../modules/bus-journal): posts cash movement to the mapped ledger account.

### Actions

- [Register a bank account](./register): Record bank account identifiers used by imports and reconciliation.
- [Map a bank account to a ledger account](./map): Define which chart of accounts entry represents this bank account for postings.

### Properties

- [`bank_account_id`](./bank-account-id): Bank account identity.
- [`iban`](./iban): Bank account IBAN.
- [`bic`](./bic): Bank account BIC.
- [`currency`](./currency): Account currency.
- [`ledger_account_id`](./ledger-account-id): Ledger mapping.

### Relations

A bank account belongs to one [accounting entity](../accounting-entity/index) via [`group_id`](../accounting-entity/group-id).

A bank account can have zero or more [bank transactions](../bank-transactions/index). Each bank transaction references its statement source via [`bank_account_id`](../bank-transactions/bank-account-id).

A bank account maps to one [ledger account](../chart-of-accounts/index) via [`ledger_account_id`](./ledger-account-id) so that cash movement can be posted consistently.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../documents/index">Documents (evidence)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../bank-transactions/index">Bank transactions</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)


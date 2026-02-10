## Chart of accounts

A chart of accounts is the set of ledger accounts you post debits and credits into, together with the reporting structure that makes financial statements readable. Bookkeeping automation depends on being able to choose the correct account consistently, and reviewers depend on stable numbers and names when they validate postings.

### Ownership

Owner: [bus accounts](../../modules/bus-accounts). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus invoices](../../modules/bus-invoices): references accounts for invoice row classification.
- [bus journal](../../modules/bus-journal): posts to accounts and reports balances.
- [bus bank](../../modules/bus-bank): maps bank accounts and statement items to ledger accounts.
- [bus reports](../../modules/bus-reports): reads account structure for reporting outputs.

### Actions

- [Add a ledger account](./add): Register a new account so postings and exports can reference it deterministically.
- [Categorize a ledger account](./categorize): Attach the account to a reporting category so statements remain readable.
- [Deactivate a ledger account](./deactivate): Prevent new postings to a deprecated account while keeping history intact.

### Properties

- [`ledger_account_id`](./ledger-account-id): Account identity used for references from other objects.
- [`number`](./number): Human-facing account number.
- [`name`](./name): Account label used in review.
- [`ledger_category_id`](./ledger-category-id): Reporting structure link.
- [`is_active`](./is-active): Operational control for new postings.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../accounting-entity/index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../vat-treatment/index">VAT treatment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Configure chart of accounts](../../workflow/configure-chart-of-accounts)
- [Account types in double-entry bookkeeping](../../data/account-types)


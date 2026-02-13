---
title: Chart of accounts
description: A chart of accounts is the set of ledger accounts you post debits and credits into, together with the reporting structure that makes financial statements…
---

## Chart of accounts

A chart of accounts is the set of ledger accounts you post debits and credits into, together with the reporting structure that makes financial statements readable. Bookkeeping automation depends on being able to choose the correct account consistently, and reviewers depend on stable numbers and names when they validate postings.

Account numbering is a workspace convention, not a BusDK requirement. BusDK supports arbitrary account numbers as long as the chart is internally consistent and accounts map cleanly to the reporting groupings required by your statements and filings. Examples in this documentation use familiar numbers such as `1910` (bank) and `3000` (revenue) as illustrative conventions rather than required ranges.

### Ownership

Owner: [bus accounts](../../modules/bus-accounts). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

In the current CLI surface, `bus accounts add` records the core account identity (`--code`), `name`, and `type`, and `bus accounts validate` checks schema and invariants. Reporting and control fields such as `ledger_category_id` and `is_active` are maintained by editing `accounts.csv` directly and then validating, so the documentation does not imply unsupported CLI flags exist.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus invoices](../../modules/bus-invoices): references accounts for invoice row classification.
- [bus journal](../../modules/bus-journal): posts to accounts and reports balances.
- [bus bank](../../modules/bus-bank): maps bank accounts and statement items to ledger accounts.
- [bus reports](../../modules/bus-reports): reads account structure for reporting outputs.

### Actions

- [Add a ledger account](./add): Register a new account so postings and exports can reference it deterministically.
- [Categorize a ledger account](./categorize): Attach the account to a reporting category so statements remain readable.
- [Deactivate a ledger account](./deactivate): Prevent new postings to an inactive account while keeping history intact.

### Properties

- [`ledger_account_id`](./ledger-account-id): Account identity used for references from other objects.
- [`number`](./number): Human-facing account number.
- [`name`](./name): Account label used in review.
- [`ledger_category_id`](./ledger-category-id): Reporting structure link.
- [`is_active`](./is-active): Operational control for new postings.

### Relations

The chart of accounts belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory, so it is not expressed as a per-row key in operational datasets. Most bookkeeping objects reference ledger accounts by storing a [`ledger_account_id`](./ledger-account-id) (or an account-id field that resolves to one).

Sales invoice rows reference revenue accounts via [`ledger_account_id`](../sales-invoice-rows/ledger-account-id). Purchase posting specifications reference expense or asset accounts via [`ledger_account_id`](../purchase-posting-specifications/ledger-account-id).

Bank accounts map to ledger accounts via [`ledger_account_id`](../bank-accounts/ledger-account-id), and bank transactions can reference a ledger account directly via [`ledger_account_id`](../bank-transactions/ledger-account-id) when the cash movement is booked as a non-invoice event.

Employees reference payroll-related accounts via [`wage_expense_account_id`](../employees/wage-expense-account-id), [`withholding_payable_account_id`](../employees/withholding-payable-account-id), and [`net_payable_account_id`](../employees/net-payable-account-id). Fixed assets reference asset, depreciation, and expense accounts via [`asset_account_id`](../fixed-assets/asset-account-id), [`depreciation_account_id`](../fixed-assets/depreciation-account-id), and [`expense_account_id`](../fixed-assets/expense-account-id). Inventory items reference inventory and COGS accounts via [`inventory_account_id`](../inventory-items/inventory-account-id) and [`cogs_account_id`](../inventory-items/cogs-account-id). Loans reference accounts via [`principal_account_id`](../loans/principal-account-id), [`interest_account_id`](../loans/interest-account-id), and [`cash_account_id`](../loans/cash-account-id).

Budgets reference ledger accounts via [`ledger_account_id`](../budgets/ledger-account-id) so budget vs actual reporting can use the same account structure as postings.

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


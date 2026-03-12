---
title: Chart of accounts
description: A chart of accounts is the set of ledger accounts you post debits and credits into, together with the reporting structure that makes financial statements…
---

## Chart of accounts

A chart of accounts is the set of ledger accounts you post debits and credits into, together with the reporting structure that makes financial statements readable. Bookkeeping automation depends on being able to choose the correct account consistently, and reviewers depend on stable numbers and names when they validate postings.

Account numbering is a workspace convention, not a BusDK requirement. BusDK supports arbitrary account numbers as long as the chart is internally consistent and accounts map cleanly to the reporting groupings required by your statements and filings. Examples in this documentation use familiar numbers such as `1910` (bank) and `3000` (income) as illustrative conventions rather than required ranges. For choosing the correct `type` value when creating accounts (e.g. with `bus accounts add`), see the [Finnish chart-of-accounts numbering convention (practical guide)](../../modules/bus-accounts#choosing-account-type-finnish-numbering-convention-practical-guide) on the bus-accounts module page — it maps common Finnish account code ranges to BusDK types and gives rules of thumb.

### Ownership

Owner: [bus accounts](../../modules/bus-accounts). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

In the current CLI surface, `bus accounts add` records the core account identity (`--code`), `name`, and `type`, and `bus accounts validate` checks schema and invariants. Reporting-group membership belongs to `accounts.csv:group_id`, and the reporting tree itself belongs to `account-groups.csv`.

Finnish statutory reporting should derive statement placement from the canonical account-group tree, not from separate layout-specific mapping datasets. In practice that means `accounts.csv` gives each posting account one `group_id`, and `account-groups.csv` defines the hierarchy, presentation order, and report-profile visibility used by TASE and tuloslaskelma outputs. [Finnish reporting hierarchy for TASE and tuloslaskelma](../../compliance/fi-reporting-taxonomy-and-account-classification) explains the background.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting. Consuming modules obtain the path to the chart (and schema) via the [bus accounts](../../modules/bus-accounts) module's API, not by hardcoding file names; see [Data path contract for read-only cross-module access](../../modules/index#data-path-contract-for-read-only-cross-module-access).

[bus invoices](../../modules/bus-invoices) references accounts for invoice-row classification. [bus journal](../../modules/bus-journal) posts to accounts and reports balances. [bus bank](../../modules/bus-bank) maps bank accounts and statement items to ledger accounts, and [bus reports](../../modules/bus-reports) reads account structure and account-group hierarchy for statutory outputs.

### Actions

[Add a ledger account](./add) registers new accounts so postings and exports can reference them deterministically. [Categorize a ledger account](./categorize) attaches accounts to reporting categories so statements stay readable. [Deactivate a ledger account](./deactivate) prevents new postings to inactive accounts while preserving history.

### Properties

Core account fields are [`ledger_account_id`](./ledger-account-id), [`number`](./number), and [`name`](./name). Reporting/control fields are [`ledger_category_id`](./ledger-category-id) and [`is_active`](./is-active).

### Relations

The chart of accounts belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory, so it is not expressed as a per-row key in operational datasets. Most bookkeeping objects reference ledger accounts by storing a [`ledger_account_id`](./ledger-account-id) (or an account-id field that resolves to one).

Sales invoice rows reference income accounts via [`ledger_account_id`](../sales-invoice-rows/ledger-account-id). Purchase posting specifications reference expense or asset accounts via [`ledger_account_id`](../purchase-posting-specifications/ledger-account-id).

Bank accounts map to ledger accounts via [`ledger_account_id`](../bank-accounts/ledger-account-id), and bank transactions can reference a ledger account directly via [`ledger_account_id`](../bank-transactions/ledger-account-id) when the cash movement is booked as a non-invoice event.

Employees reference payroll-related accounts via [`wage_expense_account_id`](../employees/wage-expense-account-id), [`withholding_payable_account_id`](../employees/withholding-payable-account-id), and [`net_payable_account_id`](../employees/net-payable-account-id). Fixed assets reference asset, depreciation, and expense accounts via [`asset_account_id`](../fixed-assets/asset-account-id), [`depreciation_account_id`](../fixed-assets/depreciation-account-id), and [`expense_account_id`](../fixed-assets/expense-account-id). Inventory items reference inventory and COGS accounts via [`inventory_account_id`](../inventory-items/inventory-account-id) and [`cogs_account_id`](../inventory-items/cogs-account-id). Loans reference accounts via [`principal_account_id`](../loans/principal-account-id), [`interest_account_id`](../loans/interest-account-id), and [`cash_account_id`](../loans/cash-account-id).

Budgets reference ledger accounts via [`ledger_account_id`](../budgets/ledger-account-id) so budget vs actual reporting can use the same account structure as postings.

For statutory reporting, every posting account should resolve through `group_id` into one canonical reporting hierarchy. Short and full report variants then use that same hierarchy with different group-visibility profiles instead of separate per-layout account remapping.

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
- [bus-reports module reference](../../modules/bus-reports)
- [Finnish reporting taxonomy and account classification](../../compliance/fi-reporting-taxonomy-and-account-classification)

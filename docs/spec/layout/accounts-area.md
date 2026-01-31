# Accounts area (chart of accounts and references)

The accounts area holds the chart of accounts and related reference data.
`accounts.csv` contains ledger accounts with fields such as account
code/number, name, category/type (Asset, Liability, Equity, Income, Expense),
optional description, and possibly hierarchical relationships through parent
accounts. A corresponding schema such as `accounts.schema.json` sits beside the
CSV file and enforces uniqueness and valid types. Additional reference datasets
such as `contacts.csv` or `entities.csv` may exist if customer and vendor
identity tracking is needed beyond invoice free-text fields.

---

<!-- busdk-docs-nav start -->
**Prev:** [BusDK Design Spec: Data directory layout](../07-data-directory-layout) · **Index:** [BusDK Design Document](../../index) · **Next:** [Budgeting area](./budget-area)
<!-- busdk-docs-nav end -->

# Accounts area (chart of accounts and references)

The accounts area holds the chart of accounts and related reference data. `accounts.csv` contains ledger accounts with fields such as account code/number, name, category/type (Asset, Liability, Equity, Income, Expense), optional description, and possibly hierarchical relationships through parent accounts. A corresponding schema such as `schemas/accounts.schema.json` enforces uniqueness and valid types. Additional reference datasets such as `contacts.csv` or `entities.csv` may exist if customer and vendor identity tracking is needed beyond invoice free-text fields.


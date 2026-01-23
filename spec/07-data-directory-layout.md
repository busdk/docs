# BuSDK Design Spec: Data directory layout

BuSDK organizes data in a transparent directory structure at the repository root. The structure is designed for human discoverability while remaining machine-validated through schemas.

The accounts area holds the chart of accounts and related reference data. `accounts.csv` contains ledger accounts with fields such as account code/number, name, category/type (Asset, Liability, Equity, Income, Expense), optional description, and possibly hierarchical relationships through parent accounts. A corresponding schema such as `schemas/accounts.schema.json` enforces uniqueness and valid types. Additional reference datasets such as `contacts.csv` or `entities.csv` may exist if customer and vendor identity tracking is needed beyond invoice free-text fields.

The journal area contains general ledger transactions. A `journal.csv` (or segmented files like `journal_2025.csv`, `journal_2026.csv`) records ledger entries. The preferred representation is “one line per entry” rather than “one line per transaction,” because multi-line transactions require flexible entry counts. A representative schema includes fields such as transaction ID, date, account reference, debit, credit, currency, amount representation strategy (separate debit/credit fields versus a signed amount), and description. Schema validation enforces field correctness; balanced transaction invariants are enforced by module logic.

The invoices area contains invoicing data. Sales and purchase invoices are separated for clarity. A typical structure includes `sales_invoices.csv` for invoice headers and `sales_invoice_lines.csv` for line items, and similarly `purchase_invoices.csv` and `purchase_invoice_lines.csv` for purchases. Header records include invoice number, date, customer or supplier identifier, due date, total amount, VAT amount, and status such as unpaid or paid. Line items include invoice number as a foreign key, description, quantity, unit price, line total, VAT rate, and ledger account mapping. Schemas enforce referential integrity and numeric constraints such as non-negative totals. A combined `invoices.csv` with a type column is possible, but separation is preferred to simplify VAT handling differences.

An optional `invoices/pdf/` area stores generated invoice PDFs named by invoice number such as `INV-1001.pdf`. Storing PDFs in Git is supported for completeness even though diffs for binaries are not meaningful; repository size concerns may cause users to store PDFs outside Git, but the default encourages “everything together” for audit completeness. Where long-term preservation is desired, PDF/A should be used for generated invoices. ([The Library of Congress](https://www.loc.gov/preservation/digital/formats/fdd/fdd000318.shtml?utm_source=chatgpt.com))

An optional VAT area can hold VAT reference data and filed summaries. VAT reports can generally be generated from invoices and journal entries, but reference datasets such as `vat_rates.csv` may be useful to track VAT percentages over time, and filed summaries such as `vat_return_2026-Q1.csv` may be generated and committed to preserve what was submitted.

A budgeting area holds planned budgets in datasets such as `budgets.csv`, where each row typically represents a budgeted amount by account and period using fields like fiscal year, account, period identifier (year-month or quarter), and budget amount. Alternative pivoted formats are possible but less “CSV-friendly” in terms of schema validation and diff behavior, so the row-based form is preferred.

A schemas area such as `schemas/` holds Table Schema JSON files for each dataset. Optionally, a `datapackage.json` manifest may be placed at the repository root to bind resources and schemas into a standardized Frictionless Data Package.

A minimal example layout is:

```text
my-business-books/
  README.md
  datapackage.json
  accounts/
    accounts.csv
    contacts.csv
  journal/
    journal_2026.csv
  invoices/
    sales_invoices.csv
    sales_invoice_lines.csv
    purchase_invoices.csv
    purchase_invoice_lines.csv
    pdf/
      INV-1001.pdf
  vat/
    vat_rates.csv
    vat_return_2026Q1.csv
  budget/
    budgets.csv
  schemas/
    accounts.schema.json
    journal.schema.json
    sales_invoices.schema.json
    sales_invoice_lines.schema.json
    purchase_invoices.schema.json
    purchase_invoice_lines.schema.json
    budgets.schema.json
    vat_rates.schema.json
```

The repository-level README is expected to document structure, workflows, and conventions so that a future user (including the same user years later) can understand how to interpret the dataset and how to operate the tools.


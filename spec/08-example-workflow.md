# BuSDK Design Spec: Example end-to-end workflow

Consider Alice, a freelance consultant using BuSDK for her business.

She begins by initializing a new repository. Running `busdk init` creates the directory structure, adds initial schema files, and performs `git init`. It may create a default chart of accounts template and commit the initial state with a message such as “Initialize BuSDK repository.”

She configures her chart of accounts by adding accounts via CLI. For example, she adds “Cash” (an Asset account), “Accounts Receivable” (Asset), “Consulting Revenue” (Income), “VAT Payable” (Liability), and common expense accounts. Each addition updates `accounts.csv`, validates schema rules such as uniqueness, then commits an audit-friendly message.

When she buys a new laptop for work, she records the transaction as a double-entry journal record that credits Cash and debits an equipment-related expense or asset account. She runs:

```bash
busdk journal record --date 2026-01-10 \
--desc "Bought new laptop" \
--debit "Office Equipment"=2500 \
--credit "Cash"=2500
```

The command generates two ledger rows in `journal/journal_2026.csv`, linking them with a shared transaction ID. The CLI ensures the debits equal the credits and rejects unknown account names. On success, it commits with a message such as “Record transaction: 2026-01-10 Bought new laptop €2,500.” This makes it difficult to accidentally record only half of a double-entry transaction, supporting reliable bookkeeping. ([docs.mypocketcfo.com](https://docs.mypocketcfo.com/article/131-accrual-based-accounting-method-and-its-double-entry-ledger-system?utm_source=chatgpt.com))

When Alice needs to bill a client, she issues a sales invoice. She runs `busdk invoice create --type sales` without providing all fields, and the tool enters interactive mode. It requests the invoice number (such as “INV-1001,” with optional auto-generation), invoice date (such as 2026-01-15), customer name (such as “Acme Corp,” optionally selectable from a customer list if maintained), then prompts for line items iteratively. Alice enters a line item for consulting services with a quantity of 10 hours at €100/hour, maps it to her consulting revenue account, and sets VAT rate to 24%. The CLI calculates subtotal €1000, VAT €240, total €1240, and defaults due date to 30 days from invoice date (2026-02-14). After confirmation, the module writes the invoice header to `invoices/sales_invoices.csv`, writes the line item to `invoices/sales_invoice_lines.csv`, generates `invoices/pdf/INV-1001.pdf` with branding and required details, then commits with a message such as “Add sales invoice INV-1001 for €1240 to Acme Corp.”

For integration convenience, the invoice module can also write the corresponding ledger impact automatically by appending journal lines that debit Accounts Receivable €1240, credit Consulting Revenue €1000, and credit VAT Payable €240, optionally tagging the transaction with invoice number for traceability. This integration is accomplished by writing to the shared journal dataset rather than calling ledger internals.

When the customer pays, Alice downloads her bank’s February CSV statement and runs `busdk bank import --file statements/Feb2026.csv`. The tool reads the statement and identifies new transactions. For the €1240 credit from Acme, Alice identifies it as payment for INV-1001 and selects an option to apply it to the invoice. The tool then writes journal entries to debit Cash and credit Accounts Receivable for €1240, updates the invoice status in `sales_invoices.csv` to “Paid,” and records the payment date. For other statement lines such as bank fees or interest, the tool prompts for categorization or matches automatically based on patterns.

If AI assistance is present, classification can be suggested automatically, such as identifying that €1240 matches an open invoice and mapping a €10 bank fee to a bank-fees expense account. The user reviews and approves suggestions before commit, keeping control while benefiting from automation. ([Uplinq](https://www.uplinq.com/post/how-ai-bookkeeping-is-revolutionizing-small-business-accounting?utm_source=chatgpt.com)) The import results in committed changes, for example with a message like “Import Feb 2026 bank transactions.”

At the end of Q1 2026, Alice files VAT. She runs `busdk vat report --period 2026Q1`. The VAT module scans invoices and/or journal entries from Jan–Mar 2026, separates output VAT on sales from input VAT on purchases, and prints a summary such as:

```text
VAT Summary Q1 2026:
Sales (taxable) total: €1000
Output VAT (@24%): €240
Purchases (tax-deductible) total: €250
Input VAT (@24%): €60
----------------------------
VAT payable: €180
```

The module may also generate a file for record-keeping such as `vat/vat_return_2026Q1.csv` and commit it. When Alice pays €180, she records the payment as a journal transaction (debit VAT Payable, credit Cash) or imports it from the next bank statement.

For budgeting, Alice defines budgets for categories such as office supplies and travel by entering rows into `budget/budgets.csv` via CLI. Later she runs `busdk budget report --year 2026`, which aggregates actual expenses from the ledger and compares them to the budget:

```text
Expense Category     Budget Q1   Actual Q1   Variance
Office Supplies      €500.00     €300.00     €+200.00
Travel               €800.00     €950.00     €-150.00
```

This demonstrates that budgeting is fundamentally a controlled computation over structured CSV, and can be implemented as a small module while remaining integrated and repeatable.

At year end, Alice closes the books. BuSDK may provide a command such as `busdk ledger close-year 2026` to generate closing entries that zero income and expense accounts into retained earnings and roll forward balances. If a built-in command does not exist, the open, schema-defined data allows Alice or her accountant to write a script to perform the close and add it as a custom command, reinforcing extensibility. Closing entries are committed so that the derivation of opening balances for 2027 remains traceable.

Across this workflow, BuSDK emphasizes transparency (CSV and Git history show exactly what happened), control (no silent adjustments; even AI produces reviewable commits), and automation (repeatable commands, integrated document generation, and optional AI-assisted classification).

As the business evolves, BuSDK’s data model can extend. International currency support can be introduced by adding a currency field to relevant schemas and records. If Alice hires an assistant, collaboration can happen via shared Git repositories with pull requests and branch protections. If new taxes or reporting obligations appear, new modules can be added without refactoring the core, because the dataset remains the stable interface.


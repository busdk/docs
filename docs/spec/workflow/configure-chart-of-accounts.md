# Configure the chart of accounts

She configures her chart of accounts by adding accounts via CLI. For example, she adds “Cash” (an Asset account), “Accounts Receivable” (Asset), “Consulting Revenue” (Income), “VAT Payable” (Liability), and common expense accounts. Each addition updates `accounts.csv`, validates schema rules such as uniqueness, then is committed via external Git tooling with an audit-friendly message.

---

<!-- busdk-docs-nav start -->
**Prev:** [Budgeting and budget-vs-actual reporting](./budgeting-and-budget-vs-actual) · **Next:** [Create a sales invoice (interactive workflow)](./create-sales-invoice)
<!-- busdk-docs-nav end -->

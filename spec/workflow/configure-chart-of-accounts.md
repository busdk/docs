# Configure the chart of accounts

She configures her chart of accounts by adding accounts via CLI. For example, she adds “Cash” (an Asset account), “Accounts Receivable” (Asset), “Consulting Revenue” (Income), “VAT Payable” (Liability), and common expense accounts. Each addition updates `accounts.csv`, validates schema rules such as uniqueness, then commits an audit-friendly message.


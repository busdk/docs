## Configure the chart of accounts

She configures her chart of accounts by adding accounts via CLI. For example, she adds “Cash” (an Asset account), “Accounts Receivable” (Asset), “Consulting Revenue” (Income), “VAT Payable” (Liability), and common expense accounts. Each addition updates `accounts.csv`, validates schema rules such as uniqueness, then is committed via external Git tooling with an audit-friendly message.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./budgeting-and-budget-vs-actual">Budgeting and budget-vs-actual reporting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./create-sales-invoice">Create a sales invoice (interactive workflow)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

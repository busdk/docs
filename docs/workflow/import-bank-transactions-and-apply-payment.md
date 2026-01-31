## Import bank transactions and apply payments

When the customer pays, Alice downloads her bank’s February CSV statement and runs `bus bank import --file statements/Feb2026.csv`. The tool reads the statement and identifies new transactions. For the €1240 credit from Acme, Alice identifies it as payment for INV-1001 and selects an option to apply it to the invoice. The tool then writes journal entries to debit Cash and credit Accounts Receivable for €1240, updates the invoice status in `sales_invoices.csv` to “Paid,” and records the payment date. For other statement lines such as bank fees or interest, the tool prompts for categorization or matches automatically based on patterns.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evolution-over-time">Evolution over time (extending the model)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./initialize-repo">Initialize a new repository</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

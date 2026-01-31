## VAT reporting and payment

At the end of Q1 2026, Alice files VAT. She runs `bus vat report --period 2026Q1`. The VAT module scans invoices and/or journal entries from Jan–Mar 2026, separates output VAT on sales from input VAT on purchases, and prints a summary such as:

```text
VAT Summary Q1 2026:
Sales (taxable) total: €1000
Output VAT (@24%): €240
Purchases (tax-deductible) total: €250
Input VAT (@24%): €60
----------------------------
VAT payable: €180
```

The module may also generate a file for record-keeping such as `vat/vat_return_2026Q1.csv`, which is then committed via external Git tooling. When Alice pays €180, she records the payment as a journal transaction (debit VAT Payable, credit Cash) or imports it from the next bank statement.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./scenario-introduction">Scenario introduction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

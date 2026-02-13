---
title: VAT reporting and payment
description: "VAT close is a repeatable sequence: compute the VAT summary from stored invoice and journal data, export the filing artifacts as repository data, then…"
---

## VAT reporting and payment

VAT close is a repeatable sequence: compute the VAT summary from stored invoice and journal data, export the filing artifacts as repository data, then record the payment as a normal ledger transaction. The goal is that both the computed VAT numbers and the evidence used to file them remain reviewable in the revision history.

1. Alice computes the VAT summary for the reporting period:

```bash
bus vat report --period 2026Q1
```

The VAT module scans invoices and/or journal entries from Jan–Mar 2026, separates output VAT on sales from input VAT on purchases, and prints a summary such as:

```text
VAT Summary Q1 2026:
Sales (taxable) total: €1000
Output VAT (@25.5%): €255
Purchases (tax-deductible) total: €200
Input VAT (@25.5%): €51
----------------------------
VAT payable: €204
```

2. Alice exports the VAT output files she will archive alongside the workspace data:

```bash
bus vat export --help
bus vat export --period 2026Q1
```

The module writes period-specific artifacts (for example under `2026/vat-reports/` and `2026/vat-returns/`) and updates any index tables used to make those artifacts discoverable as part of the repository data.

3. After filing, Alice records the VAT payment as a normal journal transaction:

```bash
bus journal add --date 2026-04-12 \
--desc "VAT payment for 2026Q1" \
--debit "VAT Payable"=180 \
--credit "Cash"=180
```

If she prefers to treat the bank statement row as the primary evidence, she can import the next bank statement with `bus bank import`, identify the VAT payment row with `bus bank list`, and then record the same journal posting with a description that carries the bank statement reference.

4. Alice records the VAT close as a new revision using her version control tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./scenario-introduction">Scenario introduction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workflow-takeaways">Workflow takeaways (transparency, control, automation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

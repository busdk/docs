---
title: VAT area (reference data and filed summaries)
description: VAT datasets can generally be generated from invoices and journal entries, but reference data such as vat-rates.csv is useful to track VAT percentages over…
---

## VAT area (reference data and filed summaries)

VAT datasets can generally be generated from invoices and journal entries, but reference data such as `vat-rates.csv` is useful to track VAT percentages over time. When VAT reports or filed returns are committed to preserve what was computed or submitted, keep the index tables in the repository root (for example `vat-reports.csv` and `vat-returns.csv`) and store the actual files directly in the repository root with a period prefix such as `202603-vat-report.csv` and `202603-vat-return.csv`.

For Finnish compliance, VAT summaries MUST retain links to the postings and vouchers that produced each reported amount. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./schemas-area">Schemas beside datasets (Table Schema JSON files)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

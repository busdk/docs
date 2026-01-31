## VAT area (reference data and filed summaries)

An optional VAT area can hold VAT reference data and filed summaries. VAT reports can generally be generated from invoices and journal entries, but reference datasets such as `vat_rates.csv` may be useful to track VAT percentages over time, and filed summaries such as `vat_return_2026-Q1.csv` may be generated and committed via external Git tooling to preserve what was submitted.

For Finnish compliance, VAT summaries MUST retain links to the postings and vouchers that produced each reported amount. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./schemas-area">Schemas beside datasets (Table Schema JSON files)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../cli/">BusDK Design Spec: CLI tooling and workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

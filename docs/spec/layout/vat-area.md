## VAT area (reference data and filed summaries)

An optional VAT area can hold VAT reference data and filed summaries. VAT reports can generally be generated from invoices and journal entries, but reference datasets such as `vat_rates.csv` may be useful to track VAT percentages over time, and filed summaries such as `vat_return_2026-Q1.csv` may be generated and committed via external Git tooling to preserve what was submitted.

For Finnish compliance, VAT summaries MUST retain links to the postings and vouchers that produced each reported amount. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
**Prev:** [Schemas beside datasets (Table Schema JSON files)](./schemas-area) · **Index:** [BusDK Design Document](../../index) · **Next:** [BusDK Design Spec: CLI tooling and workflow](../cli/)
<!-- busdk-docs-nav end -->

## `fiscal_year_start` (financial year start)

`fiscal_year_start` defines when the workspace’s financial year begins. It is configured in `datapackage.json` at the workspace root under `busdk.accounting_entity`. Bookkeeping uses financial year boundaries to structure reporting, support year-end workflows, and make it unambiguous which annual reporting context entries belong to.

When the year start is explicit, period-based views and validations can be generated deterministically, and year-end activities can be framed consistently across accounting entities.

Example values: `2026-01-01`, `2025-04-01`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./base-currency">base_currency</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fiscal-year-end">fiscal_year_end</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


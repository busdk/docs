## `fiscal_year_end` (financial year end)

`fiscal_year_end` defines when the workspace’s financial year ends. It is configured in `datapackage.json` at the workspace root under `busdk.accounting_entity`. Bookkeeping uses the year end as a hard boundary for annual reporting and closing workflows, and it helps define which periods can be locked and which reports belong to the same financial year.

When year boundaries are explicit, period-based reporting and validations do not need to infer “the current year” from timestamps or directory structure.

Example values: `2026-12-31`, `2026-03-31`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fiscal-year-start">fiscal_year_start</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-registered">vat_registered</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


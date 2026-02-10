## `vat_registered` (VAT registration)

`vat_registered` indicates whether the workspace’s accounting entity is VAT registered. It is configured in `bus.yml` at the workspace root. Bookkeeping uses this as the first switch that determines whether VAT reporting is expected and which VAT completeness checks are relevant for invoices, purchases, and postings.

When VAT registration is explicit, the system does not need to guess whether VAT-related workflows apply, which reduces the risk of missing VAT handling in review and reporting.

Example values: `true`, `false`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fiscal-year-end">fiscal_year_end</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-reporting-period">vat_reporting_period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


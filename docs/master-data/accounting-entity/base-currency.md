## `base_currency` (workspace base currency)

`base_currency` is the workspace’s base currency used for reporting and review. It is configured in `bus.yml` at the workspace root. Even when you currently operate “only in EUR”, an explicit base currency prevents silent assumptions and makes it clear how any non-base-currency invoices or bank transactions should be interpreted.

Bookkeeping uses the base currency as the stable reference for financial statements and for consistency checks across periods. When the base currency is explicit, exports and audit trails remain readable even as the business later encounters multi-currency activity.

Example values: `EUR`, `SEK`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fiscal-year-start">fiscal_year_start</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


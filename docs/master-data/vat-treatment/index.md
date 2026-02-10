## VAT treatment (lightweight master)

VAT handling needs more than a percentage to be deterministic. Bookkeeping and VAT reporting require enough structured VAT metadata that “0%” and other edge cases are still explainable, reviewable, and exportable without relying on free-text descriptions.

This VAT treatment master is intentionally lightweight. It defines the minimal fields you need at the point where you decide posting, typically on sales invoice rows and purchase posting specifications, and sometimes on bank transactions when you book a receipt-like purchase directly from the bank statement.

### Ownership

Owner: [bus vat](../../modules/bus-vat). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus invoices](../../modules/bus-invoices): records VAT rate and treatment at line level for evidence and validation.
- [bus journal](../../modules/bus-journal): is reconciled against invoice VAT for period reporting.
- [bus validate](../../modules/bus-validate): checks VAT mappings and invariants across datasets.

### Actions

- [Define VAT treatment codes](./define): Maintain the allowed treatment codes so 0% and special cases stay deterministic.
- [Validate VAT mappings](./validate): Check that VAT rates, treatment codes, and reporting expectations align with datasets.

### Properties

- [`vat_rate`](./vat-rate): Applied percentage.
- [`vat_procent`](./vat-procent): Applied percentage (alias).
- [`vat_treatment`](./vat-treatment): Reason and handling code.
- [`vat_deductible_percent`](./vat-deductible-percent): Purchase-side deductibility.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../chart-of-accounts/index">Chart of accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../parties/index">Parties (customers and suppliers)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


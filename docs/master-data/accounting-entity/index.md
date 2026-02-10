## Accounting entity

An accounting entity is the bookkeeping scope you keep separate journals, VAT, and reports for. Every bookable object belongs to exactly one accounting entity so that transactions from different companies or ledgers never mix during posting, reconciliation, or reporting.

### Ownership

Owner: [bus init](../../modules/bus-init). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus accounts](../../modules/bus-accounts): reads the entity scope to keep charts separated per bookkeeping scope.
- [bus invoices](../../modules/bus-invoices): reads entity settings to interpret invoice dates, currency, and VAT context.
- [bus vat](../../modules/bus-vat): reads VAT registration and reporting cadence for period reporting.
- [bus journal](../../modules/bus-journal): posts and reports per entity scope.

### Actions

- [Create an accounting entity](./create): Create a new bookkeeping scope so journals and VAT never mix across companies.
- [Configure accounting entity settings](./configure): Set base currency, fiscal year boundaries, and VAT reporting expectations used by automation.

### Properties

- [`group_id`](./group-id): Accounting entity key (scope).
- [`base_currency`](./base-currency): Entity-level default currency.
- [`fiscal_year_start`](./fiscal-year-start): Financial year start.
- [`fiscal_year_end`](./fiscal-year-end): Financial year end.
- [`vat_registered`](./vat-registered): VAT registration.
- [`vat_reporting_period`](./vat-reporting-period): VAT reporting cadence.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../chart-of-accounts/index">Chart of accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


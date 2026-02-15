---
title: "`vat_timing` (VAT period allocation basis)"
description: vat_timing selects which date determines VAT period allocation — performance, invoice, or cash.
---

## `vat_timing` (VAT period allocation basis)

`vat_timing` selects which date is used to allocate VAT to reporting periods. Allowed values are `performance`, `invoice`, and `cash`. It is configured in `datapackage.json` at the workspace root under `busdk.accounting_entity` via [bus config](../../modules/bus-config). [bus vat](../../modules/bus-vat) uses this setting when it allocates transactions and invoices to tax periods.

**Performance** (suoriteperuste): allocation by the date the goods were delivered or the service was performed. **Invoice** (laskutusperuste): allocation by the period in which the customer is charged (invoiced). **Cash** (maksuperuste): allocation by the date payment is received for sales or made for purchases. Under Finnish rules, cash basis applies only to domestic supplies; it is available only when annual turnover does not exceed the eligibility threshold (500 000 EUR), and VAT must be reported no later than 12 months after delivery or performance even if payment has not been received. When switching from cash to performance or invoice basis, previously unpaid sales must be reported in the next open VAT period. See [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-reporting-period">vat_reporting_period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-registration-start">vat_registration_start</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration)
- [bus-config CLI reference](../../modules/bus-config)
- [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

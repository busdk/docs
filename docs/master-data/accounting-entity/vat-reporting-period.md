---
title: "`vat_reporting_period` (VAT reporting cadence)"
description: vat_reporting_period records the VAT reporting cadence for the workspace, such as monthly, quarterly, or yearly.
---

## `vat_reporting_period` (VAT reporting cadence)

`vat_reporting_period` records the **current** (or default) VAT reporting cadence for the workspace. It is configured in `datapackage.json` at the workspace root under `busdk.accounting_entity` via [bus config](../../modules/bus-config). When the period length changes within a year or there are non-standard periods (e.g. 4-month transition, 18-month first period), the actual sequence of period boundaries is defined by the [bus vat](../../modules/bus-vat) module, which uses this value as an input.

Allowed values are `monthly`, `quarterly`, and `yearly`. Under Finnish rules, the default is monthly; quarterly is allowed when turnover is below the applicable threshold (100 000 EUR); yearly when turnover is below the lower threshold (30 000 EUR) or for certain primary producers and visual artists who do not run other VAT-taxable business. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos). The system supports and validates these three values; eligibility for a given period length is determined by the taxpayer and authority.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-registered">vat_registered</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-timing">vat_timing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration)
- [bus-config CLI reference](../../modules/bus-config)
- [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


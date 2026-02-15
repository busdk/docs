---
title: Workspace configuration (`datapackage.json` extension)
description: Each BusDK workspace directory represents exactly one accounting entity.
---

## Workspace configuration (`datapackage.json` extension)

Each BusDK workspace directory represents exactly one accounting entity. All datasets under that workspace belong to that entity by construction, so scope separation is enforced by filesystem boundaries rather than by repeating an “entity key” on every row.

Entity-wide settings are stored as BusDK metadata in the workspace’s Frictionless Data Package descriptor (`datapackage.json`) at the workspace root. To create an empty descriptor, use [bus data init](../modules/bus-data). To create or update the descriptor and accounting entity settings in one step, use the [bus config](../modules/bus-config) CLI. Modules read these settings when they validate, post, reconcile, report, or produce filings, and they must not require row-level datasets to repeat them.

The settings live under the top-level `busdk.accounting_entity` object in `datapackage.json`. This uses Frictionless descriptor extensibility — additional properties remain compatible with standard tooling, and tooling that does not understand BusDK can safely ignore the `busdk` object.

### Location

`datapackage.json` lives at the workspace root:

```json
{
  "profile": "tabular-data-package",
  "resources": [],
  "busdk": {
    "accounting_entity": {
      "base_currency": "EUR",
      "fiscal_year_start": "2026-01-01",
      "fiscal_year_end": "2026-12-31",
      "vat_registered": true,
      "vat_reporting_period": "quarterly",
      "vat_timing": "performance",
      "vat_registration_start": null,
      "vat_registration_end": null
    }
  }
}
```

### Keys

`base_currency` is the workspace’s base currency for reporting and review. It should be an ISO 4217 code such as `EUR` or `SEK`.

`fiscal_year_start` and `fiscal_year_end` define the fiscal year boundaries for the workspace. They are dates in `YYYY-MM-DD` form and must form a coherent year boundary for period generation, validation, and year-end workflows.

`vat_registered` indicates whether the workspace’s accounting entity is VAT registered. It is the primary switch that determines whether VAT reporting expectations apply.

`vat_reporting_period` defines the **current** (or default) VAT reporting cadence. Allowed values: `monthly`, `quarterly`, `yearly`. Under Finnish rules, monthly is the default; quarterly is allowed when turnover is below the applicable threshold (100 000 EUR); yearly is allowed when turnover is below the lower threshold (30 000 EUR). Primary producers and visual artists who do not run other VAT-taxable business typically use a yearly period. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos). The actual sequence of period boundaries (including changes within a year, transition periods, or non-standard first/last periods) is defined by the [bus-vat](../modules/bus-vat) module, not in this descriptor.

`vat_timing` selects which date determines VAT period allocation. Allowed values: `performance` (suoriteperuste — allocation by delivery or performance date), `invoice` (laskutusperuste — allocation by the period in which the customer is charged), `cash` (maksuperuste — allocation by payment date for sales and purchases). Cash basis applies only to domestic supplies; under Finnish rules it is available only when annual turnover does not exceed the eligibility threshold (500 000 EUR), and VAT must be reported no later than 12 months after delivery or performance even if unpaid. When switching from cash to performance or invoice basis, previously unpaid sales are reported in the next open VAT period. See [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv).

`vat_registration_start` (optional) is the date from which the entity is VAT registered, in `YYYY-MM-DD` form. `vat_registration_end` (optional) is the date on which VAT registration ends. The [bus-vat](../modules/bus-vat) module uses these as inputs when it builds the sequence of VAT periods (including partial first or last periods and any non-standard period lengths). Omit or set to null when not applicable. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./data-package-organization">Data Package organization</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./csv-conventions">CSV conventions</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-config CLI reference](../modules/bus-config)
- [Accounting entity](../master-data/accounting-entity/index)
- [Initialize a new repository](../workflow/initialize-repo)
- [Minimal workspace baseline (after initialization)](../layout/minimal-workspace-baseline)
- [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/)


---
title: Workspace configuration (`datapackage.json` extension)
description: Each BusDK workspace directory represents exactly one accounting entity.
---

## Workspace configuration (`datapackage.json` extension)

Each BusDK workspace directory represents exactly one accounting entity. All datasets under that workspace belong to that entity by construction, so scope separation is enforced by filesystem boundaries rather than by repeating an “entity key” on every row.

Entity-wide settings are stored as BusDK metadata in the workspace’s Frictionless Data Package descriptor (`datapackage.json`) at the workspace root. To create or update the descriptor and accounting entity settings, use the [bus config](../modules/bus-config) CLI. Modules read these settings when they validate, post, reconcile, report, or produce filings, and they must not require row-level datasets to repeat them.

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
      "vat_reporting_period": "quarterly"
    }
  }
}
```

### Keys

`base_currency` is the workspace’s base currency for reporting and review. It should be an ISO 4217 code such as `EUR` or `SEK`.

`fiscal_year_start` and `fiscal_year_end` define the fiscal year boundaries for the workspace. They are dates in `YYYY-MM-DD` form and must form a coherent year boundary for period generation, validation, and year-end workflows.

`vat_registered` indicates whether the workspace’s accounting entity is VAT registered. It is the primary switch that determines whether VAT reporting expectations apply.

`vat_reporting_period` defines the VAT reporting cadence used for VAT reporting workflows and completeness checks. Typical values are `monthly` and `quarterly`.

---

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


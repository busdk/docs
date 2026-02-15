---
title: "`vat_registration_start` and `vat_registration_end` (partial VAT periods)"
description: Optional dates for VAT registration start and end support partial first or last reporting periods.
---

## `vat_registration_start` and `vat_registration_end` (partial VAT periods)

`vat_registration_start` and `vat_registration_end` are optional dates in `YYYY-MM-DD` form, stored in `datapackage.json` under `busdk.accounting_entity` and set via [bus config](../../modules/bus-config). They record when the entity became VAT registered or ceased to be registered. The [bus vat](../../modules/bus-vat) module uses these as inputs when it builds the sequence of VAT periods; that sequence can include partial first or last periods, transition periods (e.g. 4 months), and non-standard lengths (e.g. 18-month first period). Bus-config only stores the dates; period boundaries are defined by bus-vat. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos). Omit both keys or set them to null when not applicable.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-timing">vat_timing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../chart-of-accounts/index">Chart of accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration)
- [bus-config CLI reference](../../modules/bus-config)
- [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

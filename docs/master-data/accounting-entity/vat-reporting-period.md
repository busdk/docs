---
title: `vat_reporting_period` (VAT reporting cadence)
description: vat_reporting_period records the VAT reporting cadence for the workspace, such as monthly, quarterly, or yearly.
---

## `vat_reporting_period` (VAT reporting cadence)

`vat_reporting_period` records the VAT reporting cadence for the workspace, such as monthly, quarterly, or yearly. It is configured in `datapackage.json` at the workspace root under `busdk.accounting_entity`. Bookkeeping automation uses this to decide which VAT completeness checks to run and to frame VAT-related review and filing steps in the right time buckets.

When reporting cadence is explicit, VAT workflows remain deterministic and do not rely on local conventions or “what we usually do”.

Example values: `monthly`, `quarterly`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-registered">vat_registered</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../chart-of-accounts/index">Chart of accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)


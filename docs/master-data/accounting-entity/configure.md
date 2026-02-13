---
title: Configure accounting entity settings
description: Set base currency, fiscal year boundaries, and VAT reporting expectations used by automation.
---

## Configure accounting entity settings

Set base currency, fiscal year boundaries, and VAT reporting expectations used by automation.

Owner: [bus init](../../modules/bus-init).

Configure accounting entity settings by running [bus init configure](../../modules/bus-init) with the flags for the properties you want to change. The command updates `datapackage.json` at the workspace root under `busdk.accounting_entity`. Omit a flag to leave that property unchanged. Other modules rely on these settings when they interpret dates, currency, and VAT reporting expectations, and they resolve them from BusDK metadata under `busdk.accounting_entity` rather than from row-level fields in operational datasets.

The canonical reference for supported keys and their meaning is [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./create">Create an accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Initialize repo](../../workflow/initialize-repo)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)


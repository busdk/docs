## Configure accounting entity settings

Set base currency, fiscal year boundaries, and VAT reporting expectations used by automation.

Owner: [bus init](../../modules/bus-init).

Configure accounting entity settings by editing the workspace configuration file `bus.yml` at the workspace root. Other modules rely on these settings when they interpret dates, currency, and VAT reporting expectations, and they resolve them from `bus.yml` rather than from row-level fields in operational datasets.

The canonical reference for supported keys and their meaning is [Workspace configuration (`bus.yml`)](../../data/workspace-configuration).

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


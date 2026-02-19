---
title: Plug-in modules via new datasets
description: BusDK supports adding modules by defining new datasets and schemas and implementing tooling that reads and writes them.
---

## Plug-in modules via new datasets

BusDK supports adding modules by defining new datasets and schemas and implementing tooling that reads and writes them. A payroll module is a canonical example: workspace-root datasets such as `employees.csv`, `payruns.csv`, `payments.csv`, and `posting_accounts.csv` (with beside-the-table schemas) can be validated and exported with `bus payroll validate` and `bus payroll export pr-001` to generate deterministic posting rows for journal workflows. This extension does not require modifications to existing modules as long as it follows existing schema and reference contracts.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./one-developer-ecosystem">One-developer contributions and ecosystem</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../compliance/fi-bookkeeping-and-tax-audit">Finnish Bookkeeping and Tax-Audit Compliance (BusDK)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-payroll module](../modules/bus-payroll)
- [bus-payroll SDD](../sdd/bus-payroll)
- [Data directory layout (principles)](../layout/layout-principles)

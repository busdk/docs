## Reporting and query commands

In addition to mutating commands, BusDK provides read-only query and reporting commands that compute balances, statuses, and summaries from the workspace datasets. Examples include `bus accounts list`; `bus journal balance --as-of 2026-03-31`; `bus invoices list --status unpaid`; `bus vat report Q1-2026`; and `bus budget report --period 2026`. Output is expected to be human-readable and may include tabular terminal formatting; where relevant, machine-readable output options should exist for integration with scripts and downstream analysis.

Reporting commands SHOULD support audit-trail exports and period-scoped output suitable for tax-audit packs. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./interactive-and-scripting-parity">Interactive use and scripting parity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./validation-and-safety-checks">Validation and safety checks</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

---
title: "`service_start_date` (line-level service period start)"
description: service_start_date records when the service period begins for this invoice row.
---

## `service_start_date` (line-level service period start)

`service_start_date` records when the service period begins for this invoice row. Bookkeeping uses row-level service periods when one invoice contains multiple service windows, because header-level dates are not precise enough for correct periodization.

Row-level service dates keep period allocation reviewable without reopening invoice documents.

Example values: `2026-02-01`, `2026-01-01`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./dimension">dimension</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./service-end-date">service_end_date</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)


---
title: "`service_end_date` (line-level service period end)"
description: service_end_date records when the service period ends for this invoice row.
---

## `service_end_date` (line-level service period end)

`service_end_date` records when the service period ends for this invoice row. Together with `service_start_date`, it makes the service window explicit so bookkeeping can allocate revenue across periods correctly when invoices mix service periods.

Example values: `2026-02-28`, `2026-01-31`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./service-start-date">service_start_date</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../purchase-invoices/index">Purchase invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)


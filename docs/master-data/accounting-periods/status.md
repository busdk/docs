---
title: "`status` (period status)"
description: status is part of the accounting periods master data.
---

## `status` (period status)

`status` is part of the accounting periods master data. Bookkeeping uses it to keep the register stable and to support deterministic posting, validation, and review workflows.

Example values: `future`, `open`, `closed`, `locked`. Periods are created in state **future**, then transitioned **open** → **closed** → **locked** via [bus period](../../modules/bus-period) open, close, and lock.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workflow: Year-end close (closing entries)](../../workflow/year-end-close)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


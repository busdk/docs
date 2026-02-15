---
title: Open an accounting period
description: Transition a period from future to open so bookkeeping work can proceed for that period.
---

## Open an accounting period

Open transitions a period from state **future** to **open** so bookkeeping work can proceed for that period. The period must already exist in the period control dataset (created with [Add an accounting period](./add)); if it does not exist, the command exits with a clear diagnostic.

Owner: [bus period](../../modules/bus-period).

Run `bus period open --period <YYYY-MM>` (or `YYYY` / `YYYYQn`). This action is required in bookkeeping so the register can be used as a deterministic input for posting, period-based review, and audit navigation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Add an accounting period](./add)
- [bus-period CLI reference](../../modules/bus-period)
- [Workflow: Year-end close (closing entries)](../../workflow/year-end-close)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)


---
title: Close an accounting period
description: Mark the period closed after postings and adjustments are complete, without creating synthetic close vouchers.
---

## Close an accounting period

Close transitions a period from state **open** to **closed** after the period bookkeeping is complete. The command validates that the selected period slice is balanced, appends the closed control row, updates `journal-closed-periods.csv`, and writes the carry-forward snapshot `periods/<period>/opening_balances.csv`. It does not append synthetic close vouchers to the journal.

Owner: [bus period](../../modules/bus-period).

This action is required in bookkeeping so the register can be used as a deterministic input for posting, period-based review, and audit navigation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workflow: Year-end close and lock](../../workflow/year-end-close)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)

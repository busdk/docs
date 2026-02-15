---
title: Add an accounting period
description: Create a period in state future so it exists in the dataset and can later be opened.
---

## Add an accounting period

Add creates a new period row in state **future**. The period does not accept postings until it is [opened](./open). You can add multiple periods in advance (e.g. all months for the year) and then open them in sequence as you need them.

Owner: [bus period](../../modules/bus-period).

Run `bus period add --period <YYYY-MM>` (or `YYYY` / `YYYYQn`). Optional `--start-date` and `--end-date` override the dates derived from the period identifier; optional `--retained-earnings-account` sets the account used for closing and opening balance. The period must not already exist; if it does, the command exits with a clear diagnostic.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting periods</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./open">Open an accounting period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-period CLI reference](../../modules/bus-period)
- [Module SDD: bus-period](../../sdd/bus-period)
- [Workflow: Year-end close (closing entries)](../../workflow/year-end-close)

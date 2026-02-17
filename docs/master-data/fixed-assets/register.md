---
title: Register a fixed asset
description: Record a new asset acquisition so depreciation and disposals can be booked deterministically.
---

## Register a fixed asset

Record a new asset acquisition so depreciation and disposals can be booked deterministically.

Owner: [bus assets](../../modules/bus-assets).

When adding an asset via the CLI, the depreciation method must be one of the values accepted by the schema (currently the canonical value `straight_line_monthly`; the alias `straight-line` may be accepted and normalized). Any other method token is invalid and is rejected before writing so that the dataset continues to validate. This action is required in bookkeeping so the register can be used as a deterministic input for posting, period-based review, and audit navigation. For the full command and options, see the [bus assets](../../modules/bus-assets) CLI reference.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Fixed assets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Fixed assets</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-assets CLI reference](../../modules/bus-assets)
- [bus-assets module SDD](../../sdd/bus-assets)
- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Double-entry ledger](../../design-goals/double-entry-ledger)
- [Journal area](../../layout/journal-area)


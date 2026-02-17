---
title: "`depreciation_method` (depreciation method)"
description: depreciation_method is part of the fixed assets master data.
---

## `depreciation_method` (depreciation method)

`depreciation_method` is part of the fixed assets master data. Bookkeeping uses it to keep the register stable and to support deterministic posting, validation, and review workflows.

The fixed-asset register schema allows only values defined in its enum. The current schema supports the canonical value `straight_line_monthly`. The [bus assets](../../modules/bus-assets) CLI may accept the alias `straight-line` and normalize it to `straight_line_monthly` when recording an asset; any other method token is invalid and must be rejected or normalized so that validation succeeds.

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


---
title: Dispose of a fixed asset
description: Record an asset disposal and produce the disposal posting intent for the journal.
---

## Dispose of a fixed asset

Record an asset disposal and produce the disposal posting intent for the journal.

Owner: [bus assets](../../modules/bus-assets).

Disposal requires a proceeds account and separate gain and loss accounts so that the CLI can post removal of the asset and accumulated depreciation, post proceeds, and post gain or loss correctly. Accumulated depreciation used at disposal is capped to the depreciable base (cost minus residual), and no additional depreciation row is emitted for the disposal month when the asset is already fully depreciated. This action is required in bookkeeping so the register can be used as a deterministic input for posting, period-based review, and audit navigation. For the full command and options, see the [bus assets](../../modules/bus-assets) CLI reference.

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


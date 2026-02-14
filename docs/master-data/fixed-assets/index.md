---
title: Fixed assets
description: Fixed assets are canonical records used for bookkeeping review, posting, and period-based reporting.
---

## Fixed assets

Fixed assets are canonical records used for bookkeeping review, posting, and period-based reporting. The goal is that the register remains stable and audit-friendly while automation depends on deterministic identifiers and references.

### Ownership

Owner: [bus assets](../../modules/bus-assets). This module is responsible for implementing write operations for this object and is the only module that should directly change the canonical datasets for it.

Secondary read-only use cases are provided by these modules when they consume this object for validation, matching, posting, or reporting:

- [bus journal](../../modules/bus-journal): receives depreciation and disposal postings produced from asset records.
- [bus accounts](../../modules/bus-accounts): provides the accounts referenced by asset posting fields.
- [bus validate](../../modules/bus-validate): checks schema and reference integrity for asset datasets.

### Actions

- [Register a fixed asset](./register): Record a new asset acquisition so depreciation and disposals can be booked deterministically.
- [Depreciate fixed assets](./depreciate): Generate depreciation postings for a period based on the asset register.
- [Dispose of a fixed asset](./dispose): Record an asset disposal and produce the disposal posting intent for the journal.

### Properties

- [`asset_id`](./asset-id): Asset identity.
- [`name`](./name): Asset name.
- [`acquired_date`](./acquired-date): Acquisition date.
- [`cost`](./cost): Acquisition cost.
- [`asset_account_id`](./asset-account-id): Balance sheet asset account.
- [`depreciation_account_id`](./depreciation-account-id): Accumulated depreciation account.
- [`expense_account_id`](./expense-account-id): Depreciation expense account.
- [`depreciation_method`](./depreciation-method): Depreciation method.
- [`life_months`](./life-months): Depreciation life in months.

### Relations

A fixed asset belongs to the workspace’s [accounting entity](../accounting-entity/index). Scope is derived from the workspace root directory rather than from a per-row key.

Fixed assets reference [ledger accounts](../chart-of-accounts/index) for posting intent, typically including an asset account, an accumulated depreciation account, and a depreciation expense account.

Depreciation and disposal workflows are period-based and produce posting intent for a given [accounting period](../accounting-periods/index).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Fixed assets</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Double-entry ledger](../../design-goals/double-entry-ledger)
- [Journal area](../../layout/journal-area)


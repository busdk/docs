## bus-assets

### Name

`bus assets` — manage fixed assets, depreciation, and disposals.

### Synopsis

`bus assets <command> [options]`

### Description

`bus assets` maintains the fixed-asset register and produces depreciation and disposal postings for the journal. Asset records are stored as schema-validated repository data so depreciation schedules and postings remain auditable.

### Commands

- `init` creates the baseline assets datasets and schemas.
- `add` records a new asset acquisition.
- `depreciate` generates depreciation postings for a period.
- `dispose` records an asset disposal and emits disposal postings.

### Options

`add` accepts `--asset-id`, `--name`, `--acquired`, `--cost`, `--asset-account`, `--depreciation-account`, `--expense-account`, `--method`, and `--life-months`, with optional `--in-service`, `--salvage`, `--desc`, and `--voucher`. `depreciate` accepts `--period` and optional `--asset-id` and `--post-date`. `dispose` accepts `--asset-id`, `--date`, and `--proceeds-account`, with optional `--proceeds`, `--desc`, and `--voucher`. For global flags and command-specific help, run `bus assets --help`.

### Files

Fixed-asset datasets and schemas in the assets area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### See also

Module SDD: [bus-assets](../sdd/bus-assets)  
Audit trail expectations: [Append-only and soft deletion](../data/append-only-and-soft-deletion)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reconcile">bus-reconcile</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-loans">bus-loans</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->


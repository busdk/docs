---
title: bus-assets
description: bus assets maintains the fixed-asset register and produces depreciation and disposal postings for the journal.
---

## `bus-assets` — manage fixed assets, depreciation, and disposals

### Synopsis

`bus assets init [-C <dir>] [global flags]`  
`bus assets add --asset-id <id> --name <name> --acquired <date> --cost <amount> --asset-account <account> --depreciation-account <account> --expense-account <account> --method <method> --life-months <n> [--in-service <date>] [--salvage <amount>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`  
`bus assets depreciate --period <period> [--asset-id <id>] [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus assets dispose --asset-id <id> --date <YYYY-MM-DD> --proceeds-account <account> --gain-account <account> --loss-account <account> [--proceeds <amount>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus assets` maintains the fixed-asset register and produces depreciation and disposal postings for the journal.
Asset records are schema-validated repository data so schedules and postings remain auditable.

### Commands

`init` creates the baseline assets datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails and does not modify files.

`add` records a new asset acquisition. `depreciate` generates depreciation postings for a period. `dispose` records an asset disposal and emits disposal postings.

### Options

For `add`, required fields are `--asset-id`, `--name`, `--acquired`, `--cost`, `--asset-account`, `--depreciation-account`, `--expense-account`, `--method`, and `--life-months`. Optional fields are `--in-service`, `--salvage`, `--desc`, and `--voucher`.

For `depreciate`, `--period` is required. You can limit scope with `--asset-id` and override posting date with `--post-date`.

For `dispose`, required fields are `--asset-id`, `--date`, `--proceeds-account`, `--gain-account`, and `--loss-account`. Optional fields are `--proceeds`, `--desc`, and `--voucher`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus assets --help`.

#### Add command

The current schema supports one depreciation method: `straight_line_monthly`.
You can also pass alias `straight-line`; the CLI normalizes it before write.

Other `--method` values are invalid and fail without modifying data.
`--in-service` defaults to acquisition date.
`--salvage` defaults to `0` when omitted.

#### Dispose command

You must supply `--proceeds-account`, `--gain-account`, and `--loss-account` so disposal can post proceeds and gain/loss correctly.
Omit `--proceeds` for non-cash write-off (treated as zero).

Accumulated depreciation at disposal is capped to depreciable base (cost minus residual).
If an asset is fully depreciated before disposal month, no extra depreciation row is emitted for that month.

### Files

Fixed-asset datasets and schemas in the assets area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `assets/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus assets init
bus assets add \
  --asset-id LAPTOP-001 \
  --name "Work laptop" \
  --acquired 2026-01-15 \
  --cost 1800 \
  --asset-account 1130 \
  --depreciation-account 1190 \
  --expense-account 6800 \
  --method straight_line \
  --life-months 36
bus assets depreciate --period 2026-03 --post-date 2026-03-31
bus assets dispose \
  --asset-id LAPTOP-001 \
  --date 2027-02-15 \
  --proceeds 300 \
  --proceeds-account 1910 \
  --gain-account 3760 \
  --loss-account 7760
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus assets add --asset-id PHONE-002 --name "Office phone" --acquired 2026-02-01 --cost 900 --asset-account 1130 --depreciation-account 1190 --expense-account 6800 --method straight_line --life-months 24
assets add --asset-id PHONE-002 --name "Office phone" --acquired 2026-02-01 --cost 900 --asset-account 1130 --depreciation-account 1190 --expense-account 6800 --method straight_line --life-months 24

# same as: bus assets depreciate --period 2026-04 --asset-id PHONE-002 --post-date 2026-04-30
assets depreciate --period 2026-04 --asset-id PHONE-002 --post-date 2026-04-30

# same as: bus assets dispose --asset-id PHONE-002 --date 2027-01-15 --proceeds-account 1910 --gain-account 3760 --loss-account 7760 --proceeds 150
assets dispose --asset-id PHONE-002 --date 2027-01-15 --proceeds-account 1910 --gain-account 3760 --loss-account 7760 --proceeds 150
```


### Development state

**Value promise:** Maintain fixed-asset register and depreciation so schedule and post produce journal postings, and asset data supports the significant-assets list for the evidence pack.

**Use cases:** [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 90% — Full asset lifecycle and postings verified by tests; user can complete register, depreciation, and disposal and produce postings for the evidence pack.

**Use case readiness:** Finnish company reorganisation (yrityssaneeraus): 90% — full lifecycle and postings verified; FR-AST-003, FR-AST-004 and dispose required-args verified by unit and e2e.

**Current:** Init/add/validate/schedule/post/depreciate/dispose and global-flag behavior are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-assets](../sdd/bus-assets).

**Planned next:** None in PLAN.md.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Postings feed [journal](./bus-journal); asset accounts in [reports](./bus-reports).

See [Development status](../implementation/development-status#finnish-company-reorganisation-yrityssaneeraus--audit-and-evidence-pack).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reconcile">bus-reconcile</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-loans">bus-loans</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Fixed assets](../master-data/fixed-assets/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Module SDD: bus-assets](../sdd/bus-assets)
- [Audit trail expectations: Append-only and soft deletion](../data/append-only-and-soft-deletion)

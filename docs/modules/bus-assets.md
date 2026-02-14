---
title: bus-assets
description: bus assets maintains the fixed-asset register and produces depreciation and disposal postings for the journal.
---

## bus-assets

### Name

`bus assets` — manage fixed assets, depreciation, and disposals.

### Synopsis

`bus assets init [-C <dir>] [global flags]`  
`bus assets add --asset-id <id> --name <name> --acquired <date> --cost <amount> --asset-account <account> --depreciation-account <account> --expense-account <account> --method <method> --life-months <n> [--in-service <date>] [--salvage <amount>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`  
`bus assets depreciate --period <period> [--asset-id <id>] [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus assets dispose --asset-id <id> --date <YYYY-MM-DD> --proceeds-account <account> [--proceeds <amount>] [--desc <text>] [--voucher <id>] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus assets` maintains the fixed-asset register and produces depreciation and disposal postings for the journal. Asset records are stored as schema-validated repository data so depreciation schedules and postings remain auditable.

### Commands

- `init` creates the baseline assets datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` records a new asset acquisition.
- `depreciate` generates depreciation postings for a period.
- `dispose` records an asset disposal and emits disposal postings.

### Options

`add` accepts `--asset-id`, `--name`, `--acquired`, `--cost`, `--asset-account`, `--depreciation-account`, `--expense-account`, `--method`, and `--life-months`, with optional `--in-service`, `--salvage`, `--desc`, and `--voucher`. `depreciate` accepts `--period` and optional `--asset-id` and `--post-date`. `dispose` accepts `--asset-id`, `--date`, and `--proceeds-account`, with optional `--proceeds`, `--desc`, and `--voucher`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus assets --help`.

### Files

Fixed-asset datasets and schemas in the assets area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `assets/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value:** Manage fixed-asset register and depreciation so schedule and post generate journal postings for the [accounting workflow](../workflow/accounting-workflow-overview) and asset accounts appear in [bus-reports](./bus-reports).

**Completeness:** 50% (Primary journey) — validate, schedule, and post are implemented and covered by unit tests; init and add are not yet verified by e2e.

**Current:** Unit tests in `cmd/bus-assets/run_test.go`, `internal/assets/schedule_property_test.go`, `internal/assets/post_property_test.go`, and related prove run, schedule, and post logic and flags. No e2e script; init and add workflows are not test-backed.

**Planned next:** Root layout only; init, add, depreciate, dispose as primary CLI; --dry-run; voucher refs in postings.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Depreciation and disposal postings feed [bus-journal](./bus-journal); asset accounts in [bus-reports](./bus-reports).

See [Development status](../implementation/development-status).

---

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


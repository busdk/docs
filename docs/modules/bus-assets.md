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

Command names follow [CLI command naming](../cli/command-naming). `bus assets` maintains the fixed-asset register and produces depreciation and disposal postings for the journal. Asset records are stored as schema-validated repository data so depreciation schedules and postings remain auditable.

### Commands

- `init` creates the baseline assets datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` records a new asset acquisition.
- `depreciate` generates depreciation postings for a period.
- `dispose` records an asset disposal and emits disposal postings.

### Options

`add` accepts `--asset-id`, `--name`, `--acquired`, `--cost`, `--asset-account`, `--depreciation-account`, `--expense-account`, `--method`, and `--life-months`, with optional `--in-service`, `--salvage`, `--desc`, and `--voucher`. `depreciate` accepts `--period` and optional `--asset-id` and `--post-date`. `dispose` accepts required `--asset-id`, `--date`, `--proceeds-account`, `--gain-account`, and `--loss-account`, and optional `--proceeds`, `--desc`, and `--voucher`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus assets --help`.

#### Add command

The only depreciation method supported by the current schema is `straight_line_monthly`. You may pass `straight_line_monthly` or the alias `straight-line`; the CLI normalizes aliases to the schema value before writing. Any other `--method` value is invalid and causes the command to exit with an error without changing the dataset, so that `bus assets validate` continues to pass. All of `--asset-id`, `--name`, `--acquired`, `--cost`, `--asset-account`, `--depreciation-account`, `--expense-account`, `--method`, and `--life-months` are required; `--in-service` defaults to the acquisition date and `--salvage` defaults to zero if omitted.

#### Dispose command

You must supply `--proceeds-account`, `--gain-account`, and `--loss-account` so that disposal can post proceeds and gain or loss to the correct ledger accounts. Omit `--proceeds` for a non-cash write-off (proceeds treated as zero). Accumulated depreciation used at disposal is capped to the depreciable base (cost minus residual). If the asset is already fully depreciated before the disposal month, no depreciation row is emitted for that month; the command only posts removal of the asset and accumulated depreciation, then proceeds and gain or loss.

### Files

Fixed-asset datasets and schemas in the assets area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `assets/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value promise:** Maintain fixed-asset register and depreciation so schedule and post produce journal postings, and asset data supports the significant-assets list for the evidence pack.

**Use cases:** [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 90% — Full asset lifecycle and postings verified by tests; user can complete register, depreciation, and disposal and produce postings for the evidence pack.

**Use case readiness:** Finnish company reorganisation (yrityssaneeraus): 90% — full lifecycle and postings verified; FR-AST-003, FR-AST-004 and dispose required-args verified by unit and e2e.

**Current:** Init (FR-INIT-003, FR-INIT-004), workspace-root layout, add, validate, schedule, post, depreciate, dispose, and global flags verified by `cmd/bus-assets/run_test.go`, `run_property_test.go`, `tests/e2e_bus_assets.sh`, `internal/assets/post_property_test.go` (incl. TestWritePostingsNoDepreciationRowForDisposalMonthWhenFullyDepreciated), `internal/cli/flags_test.go`, `internal/cli/flags_property_test.go`, and e2e. Dispose required `--gain-account`/`--loss-account` verified by `run_test.go` (TestDisposeRequiresGainAndLossAccount) and e2e. Path accessors by `internal/assets/paths_test.go` (TestRegisterPathAndSchemaPath).

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


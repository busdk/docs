---
title: bus-period — open, close, and lock accounting periods
description: bus period manages period open, close, and lock state as schema-validated repository data.
---

## bus-period

### Name

`bus period` — open, close, and lock accounting periods.

### Synopsis

`bus period init [-C <dir>] [global flags]`  
`bus period open --period <period> [-C <dir>] [global flags]`  
`bus period close --period <period> [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus period lock --period <period> [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus period` manages period open, close, and lock state as schema-validated repository data. Close generates closing entries; lock prevents further changes to closed period data. Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`.

### Commands

- `init` creates the period control dataset and schema. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `open` marks a period as open.
- `close` generates closing entries and marks the period closed.
- `lock` locks a closed period so it cannot be modified.

### Options

`open`, `close`, and `lock` require `--period <period>`. `close` accepts optional `--post-date <YYYY-MM-DD>` (defaults to last date of period). Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus period --help`.

### Files

`periods.csv` and its beside-the-table schema `periods.schema.json` live at the workspace root. Paths are root-level only — the data is not under a subdirectory such as `periods/periods.csv`.

### Exit status

`0` on success. Non-zero on invalid usage or close/lock violations.

### Development state

**Value:** Manage period control (open, close, lock) and period-scoped balance so the [accounting workflow](../workflow/accounting-workflow-overview) can close and lock periods and downstream modules can rely on closed state for reporting and filing.

**Completeness:** 70% (Broadly usable) — init, list, validate, close, and lock are verified by e2e; close artifacts and state transitions are test-backed.

**Current:** E2e script `tests/e2e_bus_period.sh` proves init creates periods.csv and schema; list output is deterministic (tsv); validate succeeds on complete workspace; close requires --period (missing or positional rejected); close with --dry-run does not change files; close writes period state and close_entries; lock behavior. Unit tests cover period logic, storage, and app run (`internal/period/period_test.go`, `internal/app/run_test.go`).

**Planned next:** Append-only period dataset; journal balance validation before close; init help when both files exist; locked-period integrity.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-journal](./bus-journal), [bus-reports](./bus-reports), [bus-vat](./bus-vat), and [bus-filing](./bus-filing) rely on period state.

See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Accounting periods](../master-data/accounting-periods/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Module SDD: bus-period](../sdd/bus-period)
- [Workflow: Year-end close (closing entries)](../workflow/year-end-close)


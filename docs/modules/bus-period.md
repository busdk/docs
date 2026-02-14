---
title: bus-period — open, close, and lock accounting periods
description: bus period manages period open, close, and lock state as schema-validated repository data.
---

## `bus-period` — open, close, and lock accounting periods

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

**Value promise:** Manage period control (open, close, lock) and period-scoped balance so the [accounting workflow](../workflow/accounting-workflow-overview) can close and lock periods and downstream modules can rely on closed state for reporting and filing.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — User can init, open, list, validate, close, and lock periods with append-only state and balanced-journal check; verified by e2e and unit tests. Merge-conflict and non-Git workspace hints would complete the journey.

**Use case readiness:** Accounting workflow: 70% — init, open, list, validate, close, lock verified; merge-conflict and non-Git hints would complete. Finnish bookkeeping and tax-audit compliance: 70% — close and lock with append-only and locked state verified. Finnish company reorganisation: 70% — close and lock for snapshots verified. Finnish payroll handling: 70% — period open/close/lock for payroll month verified.

**Current:** `tests/e2e_bus_period.sh` proves init (root, idempotent), list, validate (success and fail when unbalanced or schema missing), close (--period required, dry-run, append-only state and close_entries/opening_balances, refuses unbalanced), lock (--period, fails on open period, closed→locked), and global flags. `internal/app/run_test.go` proves open (success, requires --period, rejects positional), init/close/lock/validate/list, dry-run, chdir, output, quiet. `internal/period/period_test.go` proves List, Init, Open (marks open, not-found), init idempotent and inconsistent; `internal/validate/validate_test.go` and `internal/cli/flags_test.go` support validate and flags.

**Planned next:** Surface merge conflicts in workspace datasets when Git-tracked (no Git commands); optional non-Git workspace detection and stderr hint (PLAN.md). Advances workflow diagnostics.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-journal](./bus-journal), [bus-reports](./bus-reports), [bus-vat](./bus-vat), and [bus-filing](./bus-filing) rely on period state.

See [Development status](../implementation/development-status).

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


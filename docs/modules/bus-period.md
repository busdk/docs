---
title: bus-period — open, close, lock, and opening from prior workspace
description: bus period manages period open, close, and lock state and generates opening balances from a prior workspace as schema-validated repository data.
---

## `bus-period` — open, close, lock, and opening from prior workspace

### Synopsis

`bus period init [-C <dir>] [global flags]`  
`bus period open --period <period> [-C <dir>] [global flags]`  
`bus period close --period <period> [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus period lock --period <period> [-C <dir>] [global flags]`  
`bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [optional flags] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus period` manages period open, close, and lock state as schema-validated repository data. Close generates closing entries; lock prevents further changes to closed period data. The `opening` subcommand generates the opening entry for a new fiscal year in the current workspace from the closing balances of a prior workspace (e.g. a separate repository for the previous year), producing a single balanced journal transaction so the year rollover stays CLI-driven and auditable. Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`.

### Commands

- `init` creates the period control dataset and schema. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `open` marks a period as open.
- `close` generates closing entries and marks the period closed.
- `lock` locks a closed period so it cannot be modified.
- `opening` generates the opening entry for the current workspace from a prior workspace’s closing balances (one balanced journal transaction with deterministic provenance). It requires `--from`, `--as-of`, `--post-date`, and `--period`; see Options and the [module SDD](../sdd/bus-period) for optional flags and validation rules. It does not change [bus-config](./bus-config) settings such as VAT reporting period.

### Options

`open`, `close`, and `lock` require `--period <period>`. `close` accepts optional `--post-date <YYYY-MM-DD>` (defaults to last date of period).

`opening` requires `--from <path>`, `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`. Optional flags: `--equity-account <code>` (balancing equity account; default `3200`; override to match your chart if you use a different equity account for year rollover); `--include-zero` (include zero-balance accounts; default false, so only non-zero balances are included); `--description <text>` (override the default transaction description, which otherwise includes normalized source path and as-of date); `--replace` (remove any existing opening entry for the target period that was created by this command, then create the new entry; does not remove other postings); `--allow-as-of-mismatch` (allow running when the prior workspace’s fiscal year end does not match `--as-of`; default false). The path in `--from` is resolved relative to the process working directory (before `-C`). The command fails if the target period is not open or is closed/locked, if an opening entry for the period already exists and `--replace` is not set, if any account code from the prior workspace is missing from the current chart, or if the prior workspace’s fiscal year end differs from `--as-of` and `--allow-as-of-mismatch` is not set.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus period --help`.

**Year rollover.** In the new workspace, run `bus accounts init` and populate the chart of accounts, then `bus period init`, `bus period open --period <YYYY-MM>` for the first period, and `bus journal init`. Then run `bus period opening --from <path-to-prior-workspace> --as-of <prior-year-end> --post-date <new-year-start> --period <YYYY-MM> [--equity-account <code>]`. Full validation rules and optional flags are specified in the [bus-period module SDD](../sdd/bus-period).

### Files

`periods.csv` and its beside-the-table schema `periods.schema.json` live at the workspace root. Paths are root-level only — the data is not under a subdirectory such as `periods/periods.csv`.

### Exit status

`0` on success. Non-zero on invalid usage or close, lock, or opening violations (e.g. target period not open, opening entry already exists without `--replace`, missing account in current chart, or as-of vs fiscal year end mismatch without `--allow-as-of-mismatch`).

### Development state

**Value promise:** Manage period control (open, close, lock) and period-scoped balance so the accounting workflow can close and lock periods, carry forward opening balances from a prior workspace into a new fiscal year, and downstream modules can rely on closed state for reporting and filing.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — Init, open, list, validate, close, and lock verified by e2e and unit tests; user can complete period open/close/lock with append-only state and balanced-journal check. The `opening` subcommand is specified in the [module SDD](../sdd/bus-period) and documented here but is not yet implemented or verified; completeness does not include year-rollover opening from prior workspace. Merge-conflict and non-Git workspace hints would further complete the journey.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 70% — init, open, list, validate, close, lock verified; `opening` (year rollover from prior workspace) is planned but not yet verified. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 70% — close and lock with append-only and locked state verified. [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack): 70% — close and lock for snapshots verified. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 70% — period open/close/lock for payroll month verified.

**Current:** E2e `tests/e2e_bus_period.sh` proves init (root, idempotent), list, validate (success, unbalanced/schema-missing fail), close (--period required, dry-run, append-only, close_entries/opening_balances, journal-closed-periods.csv, refuses unbalanced or already closed), lock (--period, fails on open period, closed→locked), and global flags (help, version, color, output, quiet, chdir, invalid color/format, quiet+verbose, --, -vv, stderr). Unit tests: `internal/app/run_test.go` (open success/--period/positional reject, init/close/lock/validate/list, dry-run, chdir, output, quiet, invalid usage); `internal/period/period_test.go` (List, Init, Open marks open/not-found, init idempotent/inconsistent); `internal/validate/validate_test.go`, `internal/cli/flags_test.go` (validate and flags). **Opening:** not yet implemented. When implemented and verified, tests must cover at least: requires target period to be open; refuses when period is closed or locked; fails if an opening entry for the period already exists unless `--replace` is set; `--replace` removes only entries created by this command (deterministically identified), not arbitrary user postings; fails when any account code from the prior workspace is missing from the current chart; default transaction description includes normalized source path and as-of date (provenance); `--allow-as-of-mismatch` gates run when prior workspace fiscal year end does not match `--as-of`; output is deterministic for identical inputs.

**Planned next:** Implement and verify `opening` (see behaviors above); detect and surface merge conflicts in workspace datasets when Git-tracked (no Git commands); optional non-Git workspace detection and stderr hint (PLAN.md). Advances [Accounting workflow](../workflow/accounting-workflow-overview) diagnostics.

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


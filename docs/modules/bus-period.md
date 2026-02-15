---
title: bus-period — add, open, close, lock, and opening from prior workspace
description: bus period adds periods in future state and manages period state (open, close, lock) and opening balances from a prior workspace as schema-validated repository data.
---

## Overview

`bus period` manages the period control dataset: periods are created in state **future** with `add`, then transitioned **open** → **closed** → **locked** with `open`, `close`, and `lock`. Only periods in state **open** accept new journal postings; closed and locked periods reject writes. Re-opening a closed or locked period is not part of the normal workflow and may be refused. The `opening` subcommand generates the opening entry for a new fiscal year in the current workspace from the closing balances of a prior workspace (e.g. a separate repository for the previous year), producing a single balanced journal transaction so year rollover stays CLI-driven and auditable. Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`. Command names follow [CLI command naming](../cli/command-naming).

### Synopsis

`bus period init [-C <dir>] [global flags]`  
`bus period add --period <period> [--start-date <YYYY-MM-DD>] [--end-date <YYYY-MM-DD>] [--retained-earnings-account <code>] [-C <dir>] [global flags]`  
`bus period open --period <period> [-C <dir>] [global flags]`  
`bus period close --period <period> [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus period lock --period <period> [-C <dir>] [global flags]`  
`bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [optional flags] [-C <dir>] [global flags]`

### Commands

- `init` creates the period control dataset and schema when absent (empty or header-only; no period rows). If both files already exist and are consistent, `init` prints a warning to stderr and exits 0. If only one exists or data is inconsistent, `init` fails and does not modify any file.
- `add` creates one period row in state **future**. The period must not already exist; adding the same period twice fails with a clear diagnostic. Optional `--start-date` and `--end-date` override the dates derived from the period identifier (e.g. 2024-01 → 2024-01-01 and 2024-01-31; 2024Q1 → 2024-01-01 and 2024-03-31). Optional `--retained-earnings-account` sets the account used for closing and opening balance.
- `open` transitions a period from **future** to **open**. The period must already exist (e.g. created with `add`). If the period is not in the dataset, the command exits non-zero with a clear diagnostic (e.g. "period … not found"). If the period is already open, the command is idempotent (exit 0, no change). If the period is closed or locked, the command exits non-zero; re-opening is not required by the workflow and may be refused.
- `close` generates closing entries and transitions the period from **open** to **closed**. The period must exist and be open. Optional `--post-date` defaults to the last date of the period.
- `lock` transitions a period from **closed** to **locked**. The period must exist and be closed. Lock does not generate postings; it only updates state so the period cannot be modified.
- `opening` generates the opening entry for the current workspace from a prior workspace’s closing balances (one balanced journal transaction with deterministic provenance). It requires `--from`, `--as-of`, `--post-date`, and `--period`; see Options and the [module SDD](../sdd/bus-period) for optional flags and validation rules. It does not change [bus-config](./bus-config) settings such as VAT reporting period.

### Options

`add` requires `--period <period>` and accepts optional `--start-date <YYYY-MM-DD>`, `--end-date <YYYY-MM-DD>`, and `--retained-earnings-account <code>`. When start or end date is omitted, the implementation derives them from the period identifier (e.g. 2024-01 → 2024-01-01 and 2024-01-31; 2024Q1 → 2024-01-01 and 2024-03-31). `open`, `close`, and `lock` require `--period <period>`. `close` accepts optional `--post-date <YYYY-MM-DD>`; when omitted, the closing entry date defaults to the last date of the selected period.

`opening` requires `--from <path>`, `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`. Optional flags: `--equity-account <code>` (balancing equity account; default `3200`; override to match your chart if you use a different equity account for year rollover); `--include-zero` (include zero-balance accounts; default false, so only non-zero balances are included); `--description <text>` (override the default transaction description, which otherwise includes normalized source path and as-of date); `--replace` (remove any existing opening entry for the target period that was created by this command, then create the new entry; does not remove other postings); `--allow-as-of-mismatch` (allow running when the prior workspace’s fiscal year end does not match `--as-of`; default false). The path in `--from` is the prior workspace root; the command resolves paths to that workspace’s accounts, journal, and period datasets via the owning modules (see [Module SDD](../sdd/bus-period)). The path is resolved relative to the process working directory (before `-C`). The command fails if the target period is not open or is closed/locked, if an opening entry for the period already exists and `--replace` is not set, if any account code from the prior workspace is missing from the current chart, or if the prior workspace’s fiscal year end differs from `--as-of` and `--allow-as-of-mismatch` is not set.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus period --help`.

**Opening your first period.** After `bus period init`, run `bus period add --period <YYYY-MM>` (or `YYYY` / `YYYYQn`) to create the period in state future. You can add multiple periods in advance (e.g. 2024-01 through 2024-12). Then run `bus period open --period <YYYY-MM>` to make that period active for posting. The period must exist before opening; if you see "period … not found", add the period first with `bus period add`.

**Year rollover.** In the new workspace: `bus accounts init` and populate the chart of accounts; `bus period init`; `bus period add --period <YYYY-MM>` (and optionally more future periods); `bus period open --period <YYYY-MM>` for the first period; `bus journal init`; then `bus period opening --from <path-to-prior-workspace> --as-of <prior-year-end> --post-date <new-year-start> --period <YYYY-MM> [--equity-account <code>]`. Full validation rules and optional flags are in the [bus-period module SDD](../sdd/bus-period).

**Year-end result transfer.** Transferring profit or loss to equity at year end is currently done by posting a balanced entry with [bus journal](./bus-journal) (see [Year-end close](../workflow/year-end-close)). Automatic result-to-equity transfer is planned in this module.

**Usage examples.**

```bash
bus period add --period 2026-02
bus period open --period 2026-02
bus period close --period 2026-02
```

```bash
bus period close --period 2026Q1 --post-date 2026-03-31
bus period lock --period 2026Q1
```

```bash
bus period opening --from ../sendanor-books-2023 --as-of 2023-12-31 --post-date 2024-01-01 --period 2024-01 --equity-account 3200
```

### Files

`periods.csv` and its beside-the-table schema `periods.schema.json` live at the workspace root. Period operations append records so period boundaries remain reviewable. Paths are root-level only — the data is not under a subdirectory such as `periods/periods.csv`. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on invalid usage or violations: `add` when the period already exists; `open` when the period is not found, not in state future, or is closed/locked (re-open may be refused); `close` when the period does not exist or is not open; `lock` when the period does not exist or is not closed; `opening` when the target period is not open or is closed/locked, when an opening entry already exists without `--replace`, when any account code from the prior workspace is missing from the current chart, or when the prior workspace's fiscal year end differs from `--as-of` without `--allow-as-of-mismatch`.

### Development state

**Value promise:** Add periods in future state and manage period control (open, close, lock) and period-scoped balance so the accounting workflow can close and lock periods, carry forward opening balances from a prior workspace into a new fiscal year, and downstream modules can rely on closed state for reporting and filing.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 90% — Init, add, open, list, validate, close, lock, and opening including `--replace` and `--allow-as-of-mismatch` verified by e2e and unit tests; user can complete period add/open/close/lock and year-rollover opening; merge-conflict and non-Git hint verified.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 90% — init, add, open, list, validate, close, lock, opening (including --replace and --allow-as-of-mismatch) verified; user can complete period add/open/close/lock and year-rollover opening. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 90% — close, lock, opening with append-only and locked state verified; --replace and --allow-as-of-mismatch verified by e2e. [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack): 90% — close, lock, opening for snapshots verified; --replace and --allow-as-of-mismatch verified by e2e. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 90% — period open/close/lock and opening for payroll month verified; --replace and --allow-as-of-mismatch verified by e2e.

**Current:** E2e `tests/e2e_bus_period.sh` proves init (root, idempotent), add (create period in future state), list, validate (success, unbalanced/schema-missing/merge-conflict fail), open (transition future→open; period must exist), close (--period required, dry-run, append-only, close_entries/opening_balances, journal-closed-periods.csv, refuses unbalanced or already closed), lock (--period, fails on open period, closed→locked), opening (prior→current workspace, required flags, already-exists without --replace, dry-run, **--replace** removes only opening rows and keeps manual postings, **--allow-as-of-mismatch** fails without flag and succeeds with flag), merge-conflict and non-Git hint, and global flags. Unit tests in `internal/app/run_test.go`, `internal/period/period_test.go`, `internal/period/opening_test.go`, `internal/period/periodid_test.go`, `internal/period/closed_periods_file_test.go`, `internal/validate/validate_test.go`, and `internal/cli/flags_test.go` cover open/close/lock/init/opening, dry-run, chdir, output, quiet, and invalid usage.

**Planned next:** Optional automatic result-to-equity transfer at year end (advances [Accounting workflow](../workflow/accounting-workflow-overview) and [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)). See [Development status](../implementation/development-status).

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


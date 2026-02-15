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
`bus period set --period <period> --retained-earnings-account <code> [-C <dir>] [global flags]`  
`bus period list [--history] [-C <dir>] [global flags]`  
`bus period validate [-C <dir>] [global flags]`  
`bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [optional flags] [-C <dir>] [global flags]`

### Commands

- `init` creates the period control dataset and schema when absent (empty or header-only; no period rows). If both files already exist and are consistent, `init` prints a warning to stderr and exits 0. If only one exists or data is inconsistent, `init` fails and does not modify any file.
- `add` creates one period row in state **future**. The period must not already exist; adding the same period twice fails with a clear diagnostic. Every new period has a non-empty retained-earnings account: use `--retained-earnings-account <code>` or omit it to use the default `3200`. The account must exist in the workspace chart of accounts (and, when determinable, must be an equity account); otherwise `add` fails and writes nothing. Optional `--start-date` and `--end-date` override the dates derived from the period identifier (e.g. 2024-01 → 2024-01-01 and 2024-01-31; 2024Q1 → 2024-01-01 and 2024-03-31).
- `open` transitions a period from **future** to **open**. The period must already exist (e.g. created with `add`). The current period record must have a non-empty retained-earnings account; if it does not (e.g. after upgrading from an older workspace), run `bus period set --period <period> --retained-earnings-account <code>` first. If the period is not in the dataset, the command exits non-zero with a clear diagnostic (e.g. "period … not found"). If the period is already open, the command is idempotent (exit 0, no change). If the period is closed or locked, the command exits non-zero; re-opening is not required by the workflow and may be refused.
- `close` generates closing entries and transitions the period from **open** to **closed**. The period must exist and be open. Optional `--post-date` defaults to the last date of the period.
- `lock` transitions a period from **closed** to **locked**. The period must exist and be closed. Lock does not generate postings; it only updates state so the period cannot be modified.
- `set` repairs the retained-earnings account for an existing period without overwriting rows (append-only). Use it when the period record has a blank retained-earnings account (e.g. workspaces created by older versions). Requires `--period` and `--retained-earnings-account <code>`. Allowed only for periods in state **future** or **open**; the command refuses if the period is closed or locked. The account must exist in the workspace chart (and, when determinable, must be an equity account).
- `list` shows the current state of each period (one row per period, the effective record). Optional `--history` may show full history when supported.
- `validate` checks the period control dataset; it fails if any effective period record is invalid (e.g. missing retained-earnings account) or if the dataset has a duplicate primary key (two rows with the same `period_id` and `recorded_at`). Duplicate keys must be repaired using normal commands, not hand edits.
- `opening` generates the opening entry for the current workspace from a prior workspace’s closing balances (one balanced journal transaction with deterministic provenance). It requires `--from`, `--as-of`, `--post-date`, and `--period`; see Options and the [module SDD](../sdd/bus-period) for optional flags and validation rules. It does not change [bus-config](./bus-config) settings such as VAT reporting period.

### Options

`add` requires `--period <period>` and accepts optional `--start-date <YYYY-MM-DD>`, `--end-date <YYYY-MM-DD>`, and `--retained-earnings-account <code>`. When `--retained-earnings-account` is omitted, the default is `3200`; the account must exist in the chart (and, when determinable, be an equity account) or `add` fails. When start or end date is omitted, the implementation derives them from the period identifier (e.g. 2024-01 → 2024-01-01 and 2024-01-31; 2024Q1 → 2024-01-01 and 2024-03-31). `open`, `close`, `lock`, and `set` require `--period <period>`. `set` also requires `--retained-earnings-account <code>` and applies only to periods in state future or open. `close` accepts optional `--post-date <YYYY-MM-DD>`; when omitted, the closing entry date defaults to the last date of the selected period.

`opening` requires `--from <path>`, `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`. Optional flags: `--equity-account <code>` (balancing equity account; default `3200`; override to match your chart if you use a different equity account for year rollover); `--include-zero` (include zero-balance accounts; default false, so only non-zero balances are included); `--description <text>` (override the default transaction description, which otherwise includes normalized source path and as-of date); `--replace` (remove any existing opening entry for the target period that was created by this command, then create the new entry; does not remove other postings); `--allow-as-of-mismatch` (allow running when the prior workspace’s fiscal year end does not match `--as-of`; default false). The path in `--from` is the prior workspace root; the command resolves paths to that workspace’s accounts, journal, and period datasets via the owning modules (see [Module SDD](../sdd/bus-period)). The path is resolved relative to the process working directory (before `-C`). The command fails if the target period is not open or is closed/locked, if an opening entry for the period already exists and `--replace` is not set, if any account code from the prior workspace is missing from the current chart, or if the prior workspace’s fiscal year end differs from `--as-of` and `--allow-as-of-mismatch` is not set.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus period --help`.

**Opening your first period.** After `bus period init`, run `bus period add --period <YYYY-MM>` (or `YYYY` / `YYYYQn`) to create the period in state future. You can add multiple periods in advance (e.g. 2024-01 through 2024-12). Then run `bus period open --period <YYYY-MM>` to make that period active for posting. The period must exist before opening; if you see "period … not found", add the period first with `bus period add`. After a successful `add` and `open`, `bus period validate` and `bus period list` succeed — even when you run add and open back-to-back in the same second.

**Repairing legacy workspaces.** If `open`, `list`, or `validate` fail because a period has a blank retained-earnings account (e.g. after upgrading from an older bus-period), run `bus period set --period <period> --retained-earnings-account <code>` for that period while it is still in state future or open. Do not edit `periods.csv` by hand; the `set` command appends a corrected record so the dataset stays append-only and valid.

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

`periods.csv` and its beside-the-table schema `periods.schema.json` live at the workspace root. The schema defines a composite primary key (`period_id` and `recorded_at`) so each history row is unique; the current state of a period is the latest record for that period by `recorded_at` (effective record). Period operations append records only (no overwrites). `list` and `validate` use this effective record. If two rows ever share the same `period_id` and `recorded_at` (e.g. from hand edits), `validate` fails until the dataset is repaired using normal commands. Every period record written by the CLI has a non-empty retained-earnings account so close/opening and downstream modules can rely on it; if you have an older workspace with a blank retained-earnings account on a period, use `bus period set` to repair it. Paths are root-level only — the data is not under a subdirectory such as `periods/periods.csv`. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on invalid usage or violations: `add` when the period already exists or when the (default or provided) retained-earnings account is missing from the chart or not an equity account; `open` when the period is not found, not in state future, is closed/locked (re-open may be refused), or when the period’s effective record has no retained-earnings account (use `set` first); `close` when the period does not exist or is not open; `lock` when the period does not exist or is not closed; `set` when the period does not exist, is closed or locked, or the account code is invalid or not in the chart; `validate` when any effective period record is invalid (e.g. missing retained-earnings account) or when the dataset has a duplicate primary key (same `period_id` and `recorded_at` in two rows); `opening` when the target period is not open or is closed/locked, when an opening entry already exists without `--replace`, when any account code from the prior workspace is missing from the current chart, or when the prior workspace's fiscal year end differs from `--as-of` without `--allow-as-of-mismatch`.

### Development state

**Value promise:** Add periods in future state and manage period control (open, close, lock) and year-rollover opening so the accounting workflow can close and lock periods, carry forward opening balances from a prior workspace, and downstream modules can rely on closed state.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 90% — Init, add, open, close, lock, opening (with `--replace`, `--allow-as-of-mismatch`), list, validate and global flags verified by e2e and unit tests; user can complete period lifecycle and year-rollover opening.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 90% — add/open/close/lock and year-rollover opening verified; user can complete period lifecycle. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 90% — close, lock, opening with append-only and locked state verified. [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack): 90% — close, lock, opening for snapshots verified. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 90% — period open/close/lock and opening for payroll month verified.

**Current:** E2e `tests/e2e_bus_period.sh` proves init (root, idempotent), add (future, duplicate fail, dry-run), open (future→open; reject closed/locked; idempotent when open), close (dry-run, append-only, close_entries/opening_balances, journal-closed-periods.csv, refuse unbalanced or already closed), lock (closed→locked), opening (prior→current, required flags, already-exists without `--replace`, dry-run, `--replace`, `--allow-as-of-mismatch`), merge-conflict and non-Git hint, and unbalanced validation. Unit tests in `internal/app/run_test.go`, `internal/period/period_test.go`, `internal/period/periodid_test.go`, `internal/period/add_test.go`, `internal/period/opening_test.go`, `internal/period/closed_periods_file_test.go`, `internal/validate/validate_test.go`, and `internal/cli/flags_test.go` cover run, list, init, add, open, close, opening, path accessors, chdir, output, quiet, and invalid usage.

**Planned next:** Optional automatic result-to-equity transfer at year end (advances [Accounting workflow](../workflow/accounting-workflow-overview) and [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)); see PLAN.md.

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


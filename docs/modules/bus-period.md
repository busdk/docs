---
title: bus-period — add, open, close, lock, and opening from prior workspace
description: bus period adds periods in future state and manages period state (open, close, lock) and opening balances from a prior workspace as schema-validated repository data.
---

## Overview

`bus period` manages the period control dataset.

Periods are created in state **future** with `add`, then transitioned **open** → **closed** → **locked** with `open`, `close`, and `lock`.

Only periods in state **open** accept new journal postings. Closed and locked periods reject writes.

The `opening` subcommand generates the opening entry for a new fiscal year in the current workspace from a prior workspace’s closing balances, producing one balanced journal transaction.

Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`. Command names follow [CLI command naming](../cli/command-naming).

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

`init` creates the period control dataset and schema when absent. If both files already exist and are consistent, `init` warns and exits 0. If only one exists or data is inconsistent, `init` fails without modifying files.

`add` creates a single period row in state **future**. The period must not exist yet. Each new period must have a retained-earnings account: pass `--retained-earnings-account <code>` or rely on default `3200`. The account must exist in chart of accounts and, when determinable, be equity. Optional `--start-date` and `--end-date` override dates derived from the period id.

`open` moves a period from **future** to **open**. The period must exist and must have a retained-earnings account. If a legacy workspace has blank retained earnings, run `bus period set` first. `open` is idempotent if already open and fails for closed or locked periods.

`close` creates closing entries and transitions **open** to **closed**. `lock` transitions **closed** to **locked** without creating postings. `set` appends a retained-earnings account repair record for an existing period and is allowed only in **future** or **open**.

`list` shows effective current state per period and supports `--history` where available. `validate` checks dataset integrity and rejects invalid effective records and duplicate primary keys. `opening` generates one balanced opening transaction from a prior workspace’s closing balances and requires `--from`, `--as-of`, `--post-date`, and `--period`.

### Options

`add` requires `--period <period>` and accepts optional `--start-date <YYYY-MM-DD>`, `--end-date <YYYY-MM-DD>`, and `--retained-earnings-account <code>`.

When `--retained-earnings-account` is omitted, the default is `3200`. The account must exist in the chart (and, when determinable, be an equity account) or `add` fails.

When start or end date is omitted, dates are derived from the period ID (for example 2024-01 → 2024-01-01/2024-01-31, 2024Q1 → 2024-01-01/2024-03-31).

`open`, `close`, `lock`, and `set` require `--period <period>`. `set` also requires `--retained-earnings-account <code>` and applies only to periods in state future or open.

`close` accepts optional `--post-date <YYYY-MM-DD>`. When omitted, closing date defaults to the period end date.

`opening` requires `--from <path>`, `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`.

Optional flags:
`--equity-account <code>` (balancing account, default `3200`), `--include-zero`, `--description <text>`, `--replace`, and `--allow-as-of-mismatch`.

`--from` points to prior workspace root. Paths are resolved relative to process working directory (before `-C`).

The command fails when target period is not open, opening already exists without `--replace`, prior account codes are missing in current chart, or prior fiscal-year-end differs from `--as-of` without `--allow-as-of-mismatch`.

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
bus period opening \
  --from ../sendanor-books-2023 \
  --as-of 2023-12-31 \
  --post-date 2024-01-01 \
  --period 2024-01 \
  --equity-account 3200
```

### Files

`periods.csv` and `periods.schema.json` live at workspace root.

The schema defines a composite primary key (`period_id`, `recorded_at`) so each history row is unique. Current state is the latest row per period by `recorded_at` (effective record).

Period operations are append-only. `list` and `validate` use effective records.

If two rows share the same primary key (for example from hand edits), `validate` fails until repaired through normal commands.

Every period record written by the CLI has a non-empty retained-earnings account. For older workspaces with blank values, use `bus period set` to repair.

### Examples

```bash
bus period init
bus period add \
  --period 2026-01 \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --retained-earnings-account 2370
```

### Exit status

`0` on success.

Non-zero on invalid usage or command violations, including:
`add` when the period exists or retained-earnings account is missing/invalid; `open` when period is missing, in wrong state, or missing retained earnings; `close` when period is missing or not open; `lock` when period is missing or not closed; `set` when period is missing, closed/locked, or account is invalid; `validate` when effective records are invalid or composite keys duplicate; and `opening` when target period is not open, opening already exists without `--replace`, accounts are missing in current chart, or as-of mismatches without override.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus period --help
period --help

# same as: bus period -V
period -V

# lifecycle
period add --period 2026-01 --retained-earnings-account 3200
period open --period 2026-01
period close --period 2026-01 --post-date 2026-01-31
```


### Development state

**Value promise:** Add periods in future state and manage period control (open, close, lock) and year-rollover opening so the accounting workflow can close and lock periods, carry forward opening balances from a prior workspace, and downstream modules can rely on closed state.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 90% — Period lifecycle and year-rollover opening verified by e2e and unit tests; user can complete add→open→close→lock and opening from prior workspace.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 90% — add/open/close/lock and year-rollover opening verified; user can complete period lifecycle. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 90% — close, lock, opening with append-only and locked state verified. [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack): 90% — close, lock, opening for snapshots verified. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 90% — period open/close/lock and opening for payroll month verified.

**Current:** E2e `tests/e2e_bus_period.sh` verifies init (root, idempotent), add (future, default 3200, duplicate/account/equity/dry-run), add+open same-second (distinct `recorded_at`, validate/list pass), open (blank retained→set repair, reject closed/locked, idempotent), close (dry-run, append close_entries/opening_balances, journal-closed-periods.csv, refuse unbalanced/already closed), lock (closed→locked), set (repair future/open, refuse closed/locked/not found/invalid account), opening (prior→current, required flags, already-exists, dry-run, `--replace`, `--allow-as-of-mismatch`), validate (duplicate key, unbalanced, merge conflict), list/default and list `--history`, and global flags (-C, -o, -q, -v, --color, --format, --). Unit tests in `internal/app/run_test.go`, `internal/period/period_test.go`, `internal/period/periodid_test.go`, `internal/period/add_test.go`, `internal/period/set_test.go`, `internal/period/state_test.go`, `internal/period/opening_test.go`, `internal/period/closed_periods_file_test.go`, `internal/period/recorded_at_test.go`, `internal/validate/validate_test.go`, `internal/cli/flags_test.go`, and `path_test.go` cover run, list, init, add, open, close, set, opening, path accessors, chdir, output, quiet, and invalid usage.

**Planned next:** Optional automatic result-to-equity transfer at year end (advances [Accounting workflow](../workflow/accounting-workflow-overview) and [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)); SDD and CLI reference; PLAN.md currently empty.

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
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)

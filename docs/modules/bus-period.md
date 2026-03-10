---
title: bus-period — add, open, close, reopen, lock, and opening from prior workspace
description: bus period adds periods in future state, manages period state transitions (open, close, reopen, lock), and generates opening balances from a prior workspace as schema-validated repository data.
---

## Overview

`bus period` manages the period control dataset.

Periods are created in state **future** with `add`, then transitioned **open** → **closed** → **locked** with `open`, `close`, and `lock`. Closed periods can be reopened with `reopen`, which records audit metadata before a period is re-closed with `close`.

Only periods in state **open** accept new journal postings. Closed and locked periods reject writes.

The `opening` subcommand generates the opening entry for a new fiscal year in the current workspace from a prior workspace’s closing balances, producing one balanced journal transaction.

When workspace storage metadata selects `PCSV-1`, period-owned tables use the shared storage-aware table layer: `periods.csv`, `periods/<period_id>/close_entries.csv`, and `periods/<period_id>/opening_balances.csv` can be stored as fixed-block `PCSV-1` resources. Explicit plain CSV remains supported, and existing CSV workspaces keep the same command behavior. `bus period validate` validates logical period and journal fields only; the storage padding column `_pad` is treated as internal `PCSV-1` metadata, not a business column users must manage.

Period identifiers are `YYYY`, `YYYY-MM`, or `YYYYQn`. Command names follow [CLI command naming](../cli/command-naming).

### Synopsis

`bus period init [-C <dir>] [global flags]`  
`bus period add --period <period> [--start-date <YYYY-MM-DD>] [--end-date <YYYY-MM-DD>] [--retained-earnings-account <code>] [-C <dir>] [global flags]`  
`bus period open --period <period> [-C <dir>] [global flags]`  
`bus period close --period <period> [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus period lock --period <period> [-C <dir>] [global flags]`  
`bus period reopen --period <period> --reason <text> --approved-by <id> [--voucher-id <id>]... [--max-open-days <n>] [-C <dir>] [global flags]`  
`bus period set --period <period> --retained-earnings-account <code> [-C <dir>] [global flags]`  
`bus period list [--history] [-C <dir>] [global flags]`  
`bus period validate [-C <dir>] [global flags]`  
`bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [optional flags] [-C <dir>] [global flags]`

### Commands

`init` creates the period control dataset and schema when absent. If both files already exist and are consistent, `init` warns and exits 0. If only one exists or data is inconsistent, `init` fails without modifying files.

`add` creates a single period row in state **future**. The period must not exist yet. Each new period must have a retained-earnings account: pass `--retained-earnings-account <code>` or rely on default `3200`. The account must exist in chart of accounts and, when determinable, be equity. Optional `--start-date` and `--end-date` override dates derived from the period id.

`open` moves a period from **future** to **open**. The period must exist and must have a retained-earnings account. If a legacy workspace has blank retained earnings, run `bus period set` first. `open` is idempotent if already open and fails for closed or locked periods.

`close` creates closing entries and transitions **open** to **closed**, or re-closes a period that was reopened. `lock` transitions **closed** to **locked** without creating postings. `reopen` transitions **closed** to **reopened** with required audit metadata and an optional maximum reopen window from the prior `closed_at`. `set` appends a retained-earnings account repair record for an existing period and is allowed only in **future** or **open**.

`list` shows effective current state per period and supports `--history` where available. `validate` checks dataset integrity and rejects invalid effective records and duplicate primary keys. `opening` generates one balanced opening transaction from a prior workspace’s closing balances and requires `--from`, `--as-of`, `--post-date`, and `--period`.

### Options

`add` requires `--period <period>` and accepts optional `--start-date <YYYY-MM-DD>`, `--end-date <YYYY-MM-DD>`, and `--retained-earnings-account <code>`.

When `--retained-earnings-account` is omitted, the default is `3200`. The account must exist in the chart (and, when determinable, be an equity account) or `add` fails.

When start or end date is omitted, dates are derived from the period ID (for example 2024-01 → 2024-01-01/2024-01-31, 2024Q1 → 2024-01-01/2024-03-31).

`open`, `close`, `lock`, `reopen`, and `set` require `--period <period>`. `set` also requires `--retained-earnings-account <code>` and applies only to periods in state future or open. `reopen` also requires `--reason <text>` and `--approved-by <id>`, with optional `--voucher-id <id>` (repeatable) and `--max-open-days <n>` for policy enforcement.

`close` accepts optional `--post-date <YYYY-MM-DD>`. When omitted, closing date defaults to the period end date.

`opening` requires `--from <path>`, `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`.

Optional flags:
`--equity-account <code>` (balancing account, default `3200`), `--include-zero`, `--description <text>`, `--replace`, and `--allow-as-of-mismatch`.

`--from` points to prior workspace root. Paths are resolved relative to process working directory (before `-C`).

The command fails when target period is not open, opening already exists without `--replace`, prior account codes are missing in current chart, or prior fiscal-year-end differs from `--as-of` without `--allow-as-of-mismatch`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus period --help`.

**Opening your first period.** After `bus period init`, run `bus period add --period <YYYY-MM>` (or `YYYY` / `YYYYQn`) to create the period in state future. You can add multiple periods in advance (e.g. 2024-01 through 2024-12). Then run `bus period open --period <YYYY-MM>` to make that period active for posting. The period must exist before opening; if you see "period … not found", add the period first with `bus period add`. After a successful `add` and `open`, `bus period validate` and `bus period list` succeed — even when you run add and open back-to-back in the same second.

**Repairing legacy workspaces.** If `open`, `list`, or `validate` fail because a period has a blank retained-earnings account (e.g. after upgrading from an older bus-period), run `bus period set --period <period> --retained-earnings-account <code>` for that period while it is still in state future or open. Do not edit `periods.csv` by hand; the `set` command appends a corrected record so the dataset stays append-only and valid.

**Year rollover.** In the new workspace: `bus accounts init` and populate the chart of accounts; `bus period init`; `bus period add --period <YYYY-MM>` (and optionally more future periods); `bus period open --period <YYYY-MM>` for the first period; `bus journal init`; then `bus period opening --from <path-to-prior-workspace> --as-of <prior-year-end> --post-date <new-year-start> --period <YYYY-MM> [--equity-account <code>]`. Full validation rules and optional flags are in the [bus-period module reference](../modules/bus-period).

**Year-end result transfer.** `close` transfers the period result to the period's retained-earnings account automatically and appends the balanced closing journal entry as part of the close workflow.

**Usage examples.**

```bash
bus period add --period 2026-02
bus period open --period 2026-02
bus period close --period 2026-02
bus period reopen --period 2026-02 --reason "Correction" --approved-by reviewer@example.com
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

If workspace/resource storage resolves to `PCSV-1`, the period control table and period-owned close/opening artifacts are written as fixed-block resources with schema-declared padding. `journal-closed-periods.csv` remains ordinary CSV because it is a shared compatibility file for journal locking. Journal schemas generated by `bus-journal` may include `_pad`; `bus period validate` accepts that storage field and does not require users to treat it as part of the logical journal contract. The same storage-aware behavior applies when the workspace journal itself was initialized by `bus-journal init`: `open`, `close`, `lock`, and `validate` work directly against PCSV-backed `journals.csv` and `journal-YYYY*.csv` resources without raw header-mismatch handling by the user.

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
`add` when the period exists or retained-earnings account is missing/invalid; `open` when period is missing, in wrong state, or missing retained earnings; `close` when period is missing or not open; `lock` when period is missing or not closed; `reopen` when period is missing, not closed, locked, or missing audit metadata; `set` when period is missing, closed/locked, or account is invalid; `validate` when effective records are invalid or composite keys duplicate; and `opening` when target period is not open, opening already exists without `--replace`, accounts are missing in current chart, or as-of mismatches without override.


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
period reopen --period 2026-01 --reason "Correction window" --approved-by reviewer@example.com
```

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
- [Module reference: bus-period](../modules/bus-period)
- [Workflow: Year-end close (closing entries)](../workflow/year-end-close)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)

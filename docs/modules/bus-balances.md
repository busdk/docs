---
title: bus-balances — balance snapshot dataset and opening/cutover journal materialization
description: bus balances owns an append-only snapshot dataset; use add or import to build snapshots, then apply to materialize one balanced journal transaction for opening or cutover.
---

## Overview

`bus balances` owns a **balance snapshot dataset** (trial balance snapshot) at workspace root.

You can build snapshots from manual entry or CSV, then **materialize** a snapshot into one balanced journal transaction for opening/cutover.

Workflow:
Build a snapshot with **`add`** (single row) or **`import`** (bulk CSV), then run **`apply`** to write one journal transaction from that snapshot.

The snapshot is append-only and reviewable in Git. Only **`apply`** writes journal data.

The **core primitive** is **`bus balances add`** (one balance row per run).

`import` is a convenience for appending many rows into the same snapshot dataset. It does **not** write journal data.

To create a journal entry, run **`bus balances apply`** after snapshot preparation.

Workspace prerequisites:
Workspace prerequisites are a chart of accounts from [bus accounts](./bus-accounts), an open period from [bus period](./bus-period) for `apply`, and an initialized journal from [bus journal](./bus-journal) for `apply`.

### Synopsis

`bus balances init [-C <dir>] [global flags]`  
`bus balances add --as-of <YYYY-MM-DD> --account <code> (--amount <signed> | --debit <n> --credit <n>) [--source <text>] [--notes <text>] [-C <dir>] [global flags]`  
`bus balances import --input <path> --as-of <YYYY-MM-DD> [--format signed|dc] [--source <text>] [--allow-unknown-accounts] [-C <dir>] [global flags]`  
`bus balances apply --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [--equity-account <code> | --balancing-account <code>] [--replace] [--description <text>] [--include-zero] [-C <dir>] [global flags]`  
`bus balances validate [--as-of <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus balances list [--as-of <YYYY-MM-DD>] [--history] [-C <dir>] [global flags]`  
`bus balances template [-C <dir>] [global flags]`

### Commands

**`init`** creates the snapshot dataset and schema (`balances.csv`, `balances.schema.json`) when absent. If both already exist and are consistent, it warns and exits 0. It does not create or modify accounts, period, or journal data.

**`add`** appends exactly one row to the snapshot. You must pass `--as-of` and `--account`, plus either `--amount <signed>` or both `--debit` and `--credit` (net = debit − credit). Supplying both forms, or neither, is invalid. The account must exist in the chart. Corrections are done by appending newer rows, where latest `recorded_at` wins per as-of/account.

**`import`** appends one row per CSV data line into the same snapshot dataset, equivalent to many `add` runs. It never writes journal data. Required flags are `--input` and `--as-of`, with optional `--format signed|dc`, `--source`, and `--allow-unknown-accounts`. If accounts are missing from the chart, import fails and appends nothing.

**`apply`** reads the effective snapshot for an as-of date and writes exactly one balanced journal transaction.

Required: `--as-of`, `--post-date`, `--period`.

Preconditions: target period open, journal initialized, snapshot has at least one effective row, every account in snapshot exists in chart.

Use `--replace` to remove a previous apply for same as-of and period and write a new one.
**`validate`** checks the snapshot dataset against its schema. With `--as-of`, it also validates the effective set for that snapshot, including account existence and amount parsing.

**`list`** prints effective balances (one row per as-of and account, latest `recorded_at` wins). Use `--as-of` to restrict output to one snapshot date, and use `--history` when you need all rows instead of only effective rows.

**`template`** prints a CSV template (header plus example row) to stdout for `import` and does not read or write workspace files.

### Options

**add** requires `--as-of <YYYY-MM-DD>` and `--account <code>`, and either `--amount <signed>` or both `--debit <n>` and `--credit <n>`. Optional: `--source <text>`, `--notes <text>`. Invalid: both amount and debit/credit, or neither.

**import** requires `--input <path>` and `--as-of <YYYY-MM-DD>`. Optional: `--format signed` (default) or `dc`; `--source <text>` (stored in appended rows); `--allow-unknown-accounts` (report missing accounts, exit non-zero, no rows appended).

**apply** requires `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, and `--period <YYYY-MM>`. Optional: `--equity-account <code>` (e.g. retained earnings; default `3200` when neither flag is set), `--balancing-account <code>` (e.g. suspense; if both are set, this one is used), `--replace` (remove prior apply for same as-of and period, then write new transaction), `--description <text>` (override default description; marker and snapshot key are still embedded for replace), `--include-zero` (include zero-balance accounts in the transaction; default is to exclude them).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus balances --help`.

### Snapshot dataset and effective record

The module owns **`balances.csv`** and **`balances.schema.json`** at the workspace root. Each row has an as-of date, account code, amount (signed), optional source and notes, and `recorded_at`. The dataset is **append-only**; you correct a balance by appending a new row. For a given as-of date and account, the **effective** balance is the row with the latest `recorded_at`. `list` and `apply` use only effective rows. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Input CSV format (for import)

The CSV must have a header. For `--format signed` (default): columns `account_code` and `amount` (signed number). For `--format dc`: columns `account_code`, `debit`, and `credit` (net = debit − credit). Numbers use a single decimal separator (`.`); thousands separators are not supported. Whitespace is trimmed. Every `account_code` must exist in the chart or the import fails (or, with `--allow-unknown-accounts`, reports missing codes and appends nothing).

### Typical workflow (opening or cutover)

Prepare the workspace first: initialize and populate chart of accounts, create and open target period, initialize journal, and run `bus balances init`.

Build the snapshot either by repeated `bus balances add --as-of <date> --account <code> --amount <signed>` (or `--debit`/`--credit`) calls, or by `bus balances import --input <path> --as-of <date> [--format signed|dc]`. When needed, use `--allow-unknown-accounts` as a diagnostic pass, then fix chart or CSV and import again.

Check snapshot quality with `bus balances validate --as-of <date>` and `bus balances list --as-of <date>`. Then materialize with `bus balances apply --as-of <date> --post-date <YYYY-MM-DD> --period <YYYY-MM> [--equity-account 3200]`. If rerunning for the same as-of and period, use `--replace`. Finally, run `bus journal validate`.

**Examples.**

```bash
bus balances init
bus balances add --as-of 2025-12-31 --account 1000 --amount 5000
bus balances add --as-of 2025-12-31 --account 3200 --amount -5000
bus balances validate --as-of 2025-12-31
bus balances apply --as-of 2025-12-31 --post-date 2026-01-01 --period 2026-01
bus journal validate
```

```bash
bus balances import --input trial-balance.csv --as-of 2025-12-31 --source "excel"
bus balances apply \
  --as-of 2025-12-31 \
  --post-date 2026-01-01 \
  --period 2026-01 \
  --equity-account 3200
```

### Files

`balances.csv` and `balances.schema.json` live at workspace root.

The module writes journal data only through [bus-journal](./bus-journal) APIs when running `apply`; it does not create separate journal files.

Chart-of-accounts and period-state checks are read through [bus-accounts](./bus-accounts) and [bus-period](./bus-period).

### Examples

```bash
bus balances init
bus balances add \
  --as-of 2026-01-01 \
  --account 1910 \
  --amount 25000 \
  --source "opening import"
```

### Exit status

`0` on success. Non-zero on invalid usage (e.g. missing required flag, both amount and debit/credit on add, unknown `--format`), precondition failure (e.g. period not open for apply, empty snapshot, journal not initialized), or validation failure (unknown account, invalid number, balancing account missing). For import with `--allow-unknown-accounts` and one or more missing account codes, the command reports them and exits non-zero without appending any row. On failure, no snapshot rows are appended (add/import) and no journal data is written (apply).


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus balances --help
balances --help

# same as: bus balances -V
balances -V

# snapshot build + apply
balances add --as-of 2025-12-31 --account 1000 --amount 5000
balances add --as-of 2025-12-31 --account 3200 --amount -5000
balances apply --as-of 2025-12-31 --post-date 2026-01-01 --period 2026-01
```


### Development state

**Value promise:** Own an append-only balance snapshot dataset; build snapshots with add or import; materialize a snapshot into one balanced journal transaction for opening or cutover so users can adopt BusDK without a prior workspace.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (opening/cutover step).

**Completeness:** 60% — Opening/cutover journey verified by e2e and unit tests; user can complete init→apply flow; balanced transaction and replace verified.

**Use case readiness:** Accounting workflow (opening/cutover): 60% — User can complete init, add, import (incl. `--allow-unknown-accounts` report and no rows), validate, list, and apply (incl. replace); e2e and unit tests verify effective-record, replace-marker, balanced transaction.

**Current:** Init (idempotent; one-file-only or header mismatch exit 1), add (amount or debit/credit; unknown account refused), import (valid CSV appends; unknown no rows; `--allow-unknown-accounts` reports and no rows), validate, list (effective, tsv/csv, `--output`, `--quiet`, `--`), template, and apply (first run; second without replace refuses, with replace succeeds; marker; balanced) verified by `tests/e2e.sh`. Effective-record selection by `snapshot/record_test.go`; replace-by-marker by `internal/workspace/journal_test.go`; apply balanced and deterministic order by `internal/cli/run_test.go` (TestRun_ApplyTransaction_balanced_deterministicOrder_balancingLine); import unknown-account and `--allow-unknown-accounts` by e2e and `internal/cli/run_test.go`; period-open precondition by `internal/workspace/period_test.go`. Global flags by `internal/cli/flags_test.go` and e2e; schema by `snapshot/schema_test.go`; path accessors by `path/path_test.go`.

**Planned next:** None in PLAN; optional: [bus-period](./bus-period) library for path/state; e2e run bus journal validate after apply when bus on PATH (e2e runs it conditionally). Advances Accounting workflow opening/cutover.

**Blockers:** None known.

**Depends on:** [bus-accounts](./bus-accounts) (chart of accounts), [bus-period](./bus-period) (period state), [bus-journal](./bus-journal) (append and validate for apply).

**Used by:** Downstream modules that consume the journal (e.g. [bus-reports](./bus-reports), [bus-vat](./bus-vat), [bus-filing](./bus-filing)) use the journal entries produced by `apply` like any other posting.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-balances](../sdd/bus-balances)
- [bus-journal](./bus-journal) (ledger and postings)
- [bus-period](./bus-period) (period open/close and opening from prior workspace)
- [bus-accounts](./bus-accounts) (chart of accounts)

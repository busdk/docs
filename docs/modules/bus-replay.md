---
title: bus-replay — deterministic export and replay logs for workspace migrations
description: bus replay exports a workspace to a deterministic, append-only replay log (JSONL or shell script) and applies it into a clean workspace for migration and parity verification.
---

## `bus-replay` — deterministic export and replay logs for workspace migrations

### Synopsis

`bus replay export [--format jsonl|sh] [--out <path>|-] [--append] [--mode snapshot|history] [--include vat,reports] [--scope accounting|all] [-C <dir>] [global flags]`  
`bus replay apply --in <path>|- [--chdir <dir>] [--dry-run] [--stop-on-error] [global flags]`  
`bus replay render --in <path>|- --format sh [--out <path>|-] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus replay` turns an existing workspace into a repeatable, auditable replay log — a deterministic, append-only sequence of BusDK CLI operations that can reconstruct the workspace in a fresh directory. That solves a common migration problem: when historical accounting data is imported or reconstructed, the final datasets may be correct, but producing and maintaining thousands of explicit `bus ...` commands by hand is slow and error-prone.

The module is filesystem-only. Export reads the [workspace](../layout/minimal-workspace-baseline) datasets and, when enabled, derived outputs; it does not modify them. The primary output is a structured log (JSONL) that can be rendered into a POSIX shell script. The log is intended to live in Git as an auditable artifact alongside the workspace data. Apply runs the log into a target workspace with deterministic diagnostics and safe idempotency: operations are guarded so that re-running the same log does not create duplicates. Render turns a replay log into a deterministic shell script for humans and CI.

Bus replay does not infer missing historical intent — it exports what exists in the workspace and does not guess missing invoices, evidence, or mappings. The module does not perform network, filing submission, or Git operations. To export another revision, run `git checkout <ref>` in the repository and then run export. The intended users are operators and automation performing workspace migration, parity verification, or reproducible setup.

### Commands

- **`export`** — Read the current workspace snapshot and emit a deterministic replay log. By default exports the minimal set of operations needed to recreate the current effective state (configuration, chart of accounts, periods, journal postings, attachment references, and optionally VAT or report actions when explicitly enabled). Use `--mode history` for best-effort export of raw row history where the domain supports it.
- **`apply`** — Execute a replay log against a target workspace. Reads operations from the path given by `--in` (or stdin with `--in -`). For each operation, evaluates the idempotency guard; if the guard is satisfied the operation is skipped, otherwise the command is run. Produces a deterministic report (TSV or JSON) of applied, skipped, and failed operations. Use `--dry-run` to print what would run without executing.
- **`render`** — Transform a replay log (JSONL) into another format. Currently supports `--format sh` to produce a POSIX shell script with deterministic quoting.

### Options

**Export.** `--format jsonl` (default) or `sh` selects the output format; `--out <path>` or `--out -` writes to a file or stdout. `--append` adds missing operations to an existing log without rewriting existing lines. `--mode snapshot` (default) exports effective state; `--mode history` is best-effort row history. `--scope accounting` exports only accounting-critical surfaces; `--scope all` also includes optional modules when their datasets exist and are schema-valid. `--include vat,reports` is opt-in and includes VAT and report actions when those datasets exist.

**Apply.** `--in <path>` or `--in -` specifies the replay log file or stdin. `--chdir <dir>` sets the effective working directory for the target workspace. `--dry-run` prints what would run and why without executing. `--stop-on-error` stops on first failure (default behavior).

**Render.** `--in <path>` or `--in -` is the replay log input; `--format sh` is required; `--out <path>` or `--out -` is the script output.

Global flags (e.g. `-C`, `-o`, `-q`, `-v`) are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus replay <subcommand> --help`.

### Output formats

The canonical replay representation is JSONL: one JSON object per line, with stable keys `id`, `kind`, `cmd`, optional `args`, optional `guard`, and optional `notes`. Operation order is topological so that dependencies are satisfied — config before domain inits, accounts before journal postings, periods before postings, attachments before references. Shell rendering produces a script that starts with `#!/usr/bin/env bash` and `set -euo pipefail`; each operation becomes one `bus ...` line with deterministic single-quoted escaping. Output does not embed timestamps by default so that byte-stability is preserved.

### Export and apply behavior

Export never writes to workspace datasets. It produces operations in a fixed order: workspace configuration, module baseline inits (accounts, period, journal, attachments, and optionally vat when included), master data (accounts, periods, attachment registrations), then journal postings, then optional derived actions when enabled. Each operation carries an idempotency guard (e.g. file absent, row absent) so that apply can skip it when the guard is already satisfied. Apply reads the log, evaluates each guard, and either skips (with a deterministic “skipped” record) or runs the command. Running the same log twice into the same workspace yields only “skipped” on the second run.

### Files

Export reads workspace configuration, resource list, and domain datasets (accounts, periods, journal, attachments, and optionally VAT or report outputs when included). It writes only the replay log to the path given by `--out` or stdout. Apply reads the replay log and may run `bus` subcommands against the target workspace; it does not modify the log file. Render reads the log and writes the rendered script. The module does not perform Git operations.

### Exit status

`0` on success. `1` on runtime or precondition failure (missing required datasets, unreadable files). `2` on invalid usage (unknown flag, missing argument, invalid enum value). Global flags follow the same exit code conventions as [Standard global flags](../cli/global-flags).

### Development state

**Value promise:** Export a workspace to a deterministic, append-only replay log and apply it into a clean workspace so migrations and parity work can be reviewed in Git and re-run reproducibly.

**Use cases:** Workspace migration, parity verification, reproducible setup for automation and operators.

**Completeness:** See the [module SDD](../sdd/bus-replay) and [Development status](../implementation/development-status) for current implementation and test coverage.

**Depends on:** [bus config](./bus-config), [bus data](./bus-data), [bus accounts](./bus-accounts), [bus period](./bus-period), [bus journal](./bus-journal), [bus attachments](./bus-attachments); optionally [bus vat](./bus-vat) and report-producing modules when included.

**Used by:** Operators and automation; no other BusDK module invokes replay.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-replay](../sdd/bus-replay)
- [Workspace layout](../layout/minimal-workspace-baseline)
- [Standard global flags](../cli/global-flags)
- [Development status](../implementation/development-status)

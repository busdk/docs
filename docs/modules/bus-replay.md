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

For ERP history migrations, the intended first-class workflow is profile-driven import commands with auditable import artifacts. That workflow is specified in the SDD but not yet implemented as a replay-first command pattern in current module releases.

### Commands

`export` reads the current workspace snapshot and emits a deterministic replay log. Export covers the accounting snapshot (config init, module inits, accounts, periods, journal, and optionally VAT/report actions when enabled), and is verified by golden and roundtrip tests. `--mode history` is best-effort row-history export where domain support exists. Export does **not** include row-level facts for canonical invoice and bank datasets, so full migration replay may still require hand-written or generated append scripts for those datasets.

`apply` executes a replay log against a target workspace. It reads operations from `--in` (or stdin with `--in -`), evaluates idempotency guards, skips satisfied operations, and runs the rest. It produces a deterministic TSV/JSON report of applied/skipped/failed operations. Use `--dry-run` for preview.

`render` transforms a replay log into another format. Currently supported target is `--format sh`, which produces a deterministically quoted POSIX shell script.

### Options

For `export`, `--format jsonl` (default) or `sh` selects output format, and `--out <path>` or `--out -` writes to file or stdout. `--append` adds missing operations to an existing log without rewriting existing lines. `--mode snapshot` (default) exports effective state, while `--mode history` is best-effort row history. `--scope accounting` exports accounting-critical surfaces, and `--scope all` also includes optional modules when datasets exist and are schema-valid. `--include vat,reports` opt-in adds VAT/report actions when those datasets exist.

For `apply`, `--in <path>` or `--in -` selects replay log input, `--chdir <dir>` sets target workspace root, `--dry-run` previews execution, and `--stop-on-error` stops on first failure.

For `render`, `--in <path>` or `--in -` is required input, `--format sh` is required output format, and `--out <path>` or `--out -` controls output destination.

Global flags (e.g. `-C`, `-o`, `-q`, `-v`) are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus replay <subcommand> --help`.

### ERP profile-import replay workflow (planned)

The target workflow captures short profile-driven import commands in replay logs, such as `bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024` and `bus bank import --profile imports/profiles/erp-bank-2024.yaml --source exports/erp/bank-2024.tsv --year 2024`, instead of replaying thousands of generated per-row append commands. Replay keeps those operations deterministic by carrying stable operation IDs, guards, and references to import plan/result artifacts.

This first-class workflow is not yet shipped. Current ERP history migration still uses generated explicit scripts, including `exports/2024/017-erp-invoices-2024.sh` and `exports/2024/018-erp-bank-2024.sh`, produced from ERP TSV mappings.

### Output formats

The canonical replay representation is JSONL: one JSON object per line, with stable keys `id`, `kind`, `cmd`, optional `args`, optional `guard`, and optional `notes`. Operation order is topological so that dependencies are satisfied — config before domain inits, accounts before journal postings, periods before postings, attachments before references. Shell rendering produces a script that starts with `#!/usr/bin/env bash` and `set -euo pipefail`; each operation becomes one `bus ...` line with deterministic single-quoted escaping. Output does not embed timestamps by default so that byte-stability is preserved.

### Export coverage and limitations

Export with `--scope accounting` produces config, accounts, periods, journal postings, and attachment references. It does not emit operations that recreate row-level invoice or bank facts (sales-invoices, purchase-invoices, bank-transactions). A single artifact for full replay — including those row-level facts — is the target; until that is implemented, full replay may require additional scripts for invoice and bank data alongside the exported replay log. See [Implementation status](../sdd/bus-replay#implementation-status) in the module SDD.

### Export and apply behavior

Export never writes to workspace datasets. The export order (see [module SDD](../sdd/bus-replay#export-plan-default-accounting-snapshot)) is: workspace configuration, module baseline inits, master data (accounts, periods, attachment registrations), journal postings, then optional derived actions when enabled. Export produces this full accounting snapshot (inits, accounts add, period add/state, journal add) and is verified by golden and roundtrip tests. Each operation carries an idempotency guard (e.g. file absent, row absent) so that apply can skip it when the guard is already satisfied. Apply reads the log, evaluates each guard, and either skips (with a deterministic “skipped” record) or runs the command. Running the same log twice into the same workspace yields only “skipped” on the second run.

### Files

Export reads workspace configuration, resource list, and domain datasets (accounts, periods, journal, attachments, and optionally VAT or report outputs when included). It writes only the replay log to the path given by `--out` or stdout. Apply reads the replay log and may run `bus` subcommands against the target workspace; it does not modify the log file. Render reads the log and writes the rendered script. The module does not perform Git operations.

### Examples

```bash
bus replay export \
  --format jsonl \
  --out ./tmp/replay-2026-01.jsonl \
  --mode history \
  --scope accounting
bus replay apply --in ./tmp/replay-2026-01.jsonl --dry-run
```

### Exit status

Exit code `0` means success. Exit code `1` means runtime or precondition failure (for example missing required datasets or unreadable files). Exit code `2` means invalid usage (for example unknown flag, missing argument, or invalid enum value). Global flags follow the same exit-code conventions as [Standard global flags](../cli/global-flags).


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus replay export --format jsonl --out ./tmp/replay.jsonl
replay export --format jsonl --out ./tmp/replay.jsonl

# same as: bus replay apply --in ./tmp/replay.jsonl --dry-run
replay apply --in ./tmp/replay.jsonl --dry-run
```


### Development state

**Value promise:** Export a workspace to a deterministic, append-only replay log and apply it into a clean workspace so migrations and parity work can be reviewed in Git and re-run reproducibly.

**Use cases:** [Orphan modules](../implementation/development-status#orphan-modules) — operator/automation (workspace migration, parity verification, reproducible setup); no documented end-user workflow page.

**Completeness:** 70% — export→apply→render and idempotency are test-verified; user can complete workspace migration and re-run a log. First-class profile-driven ERP import replay is not implemented.

**Use case readiness:** Workspace migration / parity verification: 70% — export, apply (dry-run and, when `bus` on PATH, real apply), render, and second-run idempotency verified by golden, roundtrip, and e2e; ERP history migration still uses generated scripts.

**Current:** Deterministic export (empty and populated golden, `--append`, `--mode history`, `--scope all`, `--require-valid`, no workspace mutation) is verified by `internal/replay/golden_test.go`, `internal/replay/export_test.go`, and `tests/e2e_bus_replay.sh`. Apply guard evaluation, dry-run, TSV/JSON report, `--chdir`, stdin, and (when `bus` on PATH) real apply and idempotency are verified by `internal/replay/apply_test.go`, `internal/replay/executor_inprocess_test.go`, and `tests/e2e_bus_replay.sh`. Render to POSIX sh is verified by `internal/replay/render_test.go` and e2e. CLI and global flags are verified by `cmd/bus-replay/main_test.go` and `internal/cli/flags_test.go`. Profile-driven ERP import replay is not implemented.

**Planned next:** First-class replay support for profile-driven ERP import operations (`bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024`, `bus bank import --profile imports/profiles/erp-bank-2024.yaml --source exports/erp/bank-2024.tsv --year 2024`) with deterministic guards and auditable import-artifact references (SDD FR-RPL-008); advances workspace migration when [Import ERP history](../workflow/import-erp-history-into-canonical-datasets) is the workflow.

**Blockers:** None known.

**Depends on:** [bus config](./bus-config), [bus data](./bus-data), [bus accounts](./bus-accounts), [bus period](./bus-period), [bus journal](./bus-journal), [bus attachments](./bus-attachments); optionally [bus vat](./bus-vat) and report-producing modules when included.

**Used by:** Operators and automation; no other BusDK module invokes replay.

See [Development status](../implementation/development-status).

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
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)

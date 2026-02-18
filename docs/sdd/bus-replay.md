---
title: bus-replay — deterministic export and replay logs for workspace migrations
description: bus-replay reads an existing BusDK workspace and emits a deterministic, append-only command log (JSONL and renderable shell scripts) so large migrations and parity work can be reviewed in Git and re-run into a clean workspace.
---

## bus-replay — deterministic export and replay logs for workspace migrations

### Introduction and Overview

Bus Replay turns an existing workspace state into a repeatable, auditable replay log: a deterministic, append-only sequence of BusDK CLI operations that can reconstruct the workspace in a fresh directory. This solves a common migration problem. When historical accounting data is imported or reconstructed, the final datasets may be correct, but producing and maintaining thousands of explicit `bus ...` commands by hand is slow and error-prone. This SDD includes a profile-driven ERP import replay contract so replay logs can capture short import invocations with versioned profiles instead of generated mega-scripts.

Bus Replay is a filesystem-only module. It reads [workspace](../layout/minimal-workspace-baseline) datasets and, when enabled, derived outputs; it does not modify them during export. Its primary output is a structured log format (JSONL) that can be rendered into a POSIX shell script (and later other targets). The log is intended to live in Git as an auditable artifact alongside the workspace data.

**Scope.** Export reads a workspace and generates a deterministic replay log covering configuration, master data, period setup, journal postings, attachment references, and optionally VAT or report actions. Apply executes a replay log into a target workspace with deterministic diagnostics and safe idempotency rules. Render transforms a replay log into a deterministic shell script for humans and CI.

**Out of scope.** Bus Replay does not “intelligently reconstruct” missing historical intent; it exports what exists in the workspace and does not guess missing invoices, evidence, or mappings. The module does not perform network, filing submission, or Git operations. Users who need another revision run `git checkout <ref>` externally and then run export.

The intended users are operators and automation performing workspace migration, parity verification, or reproducible setup. The document’s purpose is to serve as the single source of truth for implementation and review; the audience includes human reviewers and implementation agents. Current implementation status (what is shipped versus the full export plan) is documented in [Implementation status](#implementation-status) below.

### Requirements

**FR-RPL-001 Deterministic replay log export.**  
`bus replay export` MUST read the current workspace snapshot and emit a deterministic replay log.  
Acceptance criteria: identical workspace content yields byte-identical log output for the same flags and module versions.

**FR-RPL-002 Append-only log model.**  
The exported log MUST be append-only by design: it is a sequence of operations and never encodes “edit this previous line”.  
Acceptance criteria: the format supports stable operation identifiers and deterministic ordering; `export --append` can add missing operations without rewriting existing lines.

**FR-RPL-003 Coverage of core accounting surface.**  
Export MUST cover at minimum: workspace configuration ([bus config](./bus-config) / accounting entity settings), chart of accounts ([bus accounts](./bus-accounts)), period control setup and state ([bus period](./bus-period)), journal postings ([bus journal](./bus-journal)), attachment references — metadata and file paths — ([bus attachments](./bus-attachments)), and VAT/report actions when available and explicitly enabled.  
Acceptance criteria: a clean workspace can be reconstructed to an equivalent effective state for these domains.

**FR-RPL-004 Safe apply (idempotent semantics).**  
`bus replay apply` MUST be able to run the log into an empty or partially populated workspace without creating duplicates when rerun.  
Acceptance criteria: apply uses operation guards that prevent duplicates, or uses deterministic “already applied” detection for each operation and skips safely.

**FR-RPL-005 Output formats.**  
Export MUST support canonical `jsonl` (default) and deterministic `sh` rendering (POSIX shell).  
Acceptance criteria: rendering is stable and uses deterministic quoting rules; `--out -` supports stdout for both formats.

**FR-RPL-006 Ordering and topological correctness.**  
The log MUST be ordered so that dependencies are satisfied: config before domain inits, accounts before journal postings, periods before postings constrained by periods, attachments before references that point to attachment ids when such references exist.  
Acceptance criteria: apply succeeds in a clean workspace without manual reordering.

**FR-RPL-007 No workspace mutation during export.**  
Export MUST not modify workspace datasets or derived artifacts.  
Acceptance criteria: no files change in the workspace directory when running `bus replay export`.

**FR-RPL-008 Profile-import operation coverage.**  
Replay export and render MUST support profile-driven ERP import operations for canonical invoice and bank datasets when those operations are present in migration workflows.  
Acceptance criteria: replay logs can represent `bus invoices import --profile ...` and `bus bank import --profile ...` style operations with stable IDs and guards, render them as deterministic shell commands, and preserve references to auditable import artifacts produced by those commands.

**NFR-RPL-001 Filesystem-only and non-interactive.**  
The module MUST not perform network operations and MUST not prompt interactively. All commands are scriptable.  
Acceptance criteria: no network calls; deterministic exit codes and diagnostics.

**NFR-RPL-002 Library-first integration.**  
Bus Replay MUST expose a Go library that other tools can use to produce replay logs without shelling out.  
Acceptance criteria: the CLI is a thin wrapper over the library.

**NFR-RPL-003 Cross-module path resolution via owning modules.**  
When reading domain datasets, Bus Replay MUST obtain dataset paths through owning module libraries or the [workspace data](./bus-data) package, never by hardcoding filenames.  
Acceptance criteria: no hardcoded `accounts.csv`, `periods.csv`, etc.

### Key Decisions

**KD-RPL-001 JSONL is the canonical replay representation.**  
Shell scripts are renderings of the log, not the source of truth. This keeps export deterministic and makes it easy to add more render targets later.

**KD-RPL-002 Export focuses on “effective reconstruction” by default.**  
By default, export produces the minimal set of operations needed to recreate the current effective state. A separate `--mode history` can export raw row history where the domain supports it.

**KD-RPL-003 Apply is guard-driven.**  
Idempotency is achieved via explicit guards and stable operation identifiers, not by relying on users to only run scripts once.

**KD-RPL-004 No Git dependency.**  
Bus Replay reads the working directory state. If users need another revision, they run `git checkout <ref>` externally and then export.

**KD-RPL-005 ERP migration is captured as profile invocations.**  
Replay prefers short, deterministic profile-import commands and their artifacts over generated per-row append scripts. This keeps migration logs reviewable and reusable across repositories while preserving deterministic behavior.

### System Architecture

Bus Replay has three layers.

**Workspace reader.** Loads workspace configuration (`datapackage.json` / [bus config](./bus-config) subtree), resource list from the data package and/or domain module path accessors, and domain datasets (accounts, periods, journal, attachments, [bus vat](./bus-vat) outputs when included).

**Operation planner.** Transforms workspace state into a sequence of replay operations: module init operations, add/set operations for master data, postings for journal, attachment registrations, and optional derived actions (VAT report/export, report generation), guarded.

**Serializer / renderer.** Writes JSONL operations in canonical formatting and ordering, and optionally renders JSONL to a POSIX shell script with deterministic quoting.

Export never writes to workspace datasets. Apply never shells out to Git and never prompts.

### Component Design and Interfaces

**Interface IF-RPL-001 (module CLI).**  
The module is invoked as `bus replay` with subcommands:

- `bus replay export [--format jsonl|sh] [--out <path>|-] [--append] [--mode snapshot|history] [--include vat,reports,erp-imports] [--scope accounting|all]`
- `bus replay apply --in <path>|- [--chdir <dir>] [--dry-run] [--stop-on-error]`
- `bus replay render --in <path>|- --format sh [--out <path>|-]`

`--scope accounting` exports only accounting-critical surfaces; `all` also includes optional modules when their datasets exist and are schema-valid. `--include vat,reports,erp-imports` is opt-in and guarded; defaults to off. `--mode snapshot` is default and exports effective state; `history` is best-effort and may fall back to raw row appends for exact reproduction.

Exit codes: 0 success; 1 runtime/precondition failure (missing required datasets, unreadable files); 2 invalid usage (unknown flag, missing arg, invalid enum). Global flags (e.g. `-C`, `-o`, `-q`, `-v`) follow [standard global flags](../cli/global-flags) where applicable.

**Interface IF-RPL-002 (Go library).**  
The library exposes `Export(ctx, opts) (io.Reader / []Op, error)`, `Render(ops, format) ([]byte, error)`, and `Apply(ctx, ops, opts) (Report, error)`. The library accepts a workspace root and uses owning-module path resolvers where available.

### Data Design

**Replay log format (JSONL).**  
Each line is one JSON object (one operation). Canonical keys in order: `id` (string, required) — stable operation id, deterministic; `kind` (string, required) — `init` | `set` | `add` | `action`; `cmd` (string, required) — BusDK command path, e.g. `config init`, `accounts add`, `journal add`; `args` (object, optional) — structured arguments (flags and values); `guard` (object, optional) — idempotency guard evaluated during apply; `notes` (string, optional) — human-readable annotation, not used for determinism unless explicitly enabled.

Guard examples: `{"type":"file_absent","path":"datapackage.json"}` for init-like operations; `{"type":"row_absent","resource":"accounts","key":{"code":"3000"}}`; `{"type":"vat_report_absent","period":"2026Q1"}` (module-specific, only when include is enabled); `{"type":"import_artifact_absent","path":"imports/runs/2024-erp-invoices.result.json"}` for profile import operations. Operation ids are derived from stable domain keys (e.g. `accounts:add:3000`, `period:add:2026Q1`, `journal:add:<transaction_id>`, `invoices:import:<profile_id>:<source_digest>`). When no stable key exists, ids are derived from a canonical hash of the operation payload and remain deterministic.

**Shell rendering rules (POSIX sh).**  
Script starts with `#!/usr/bin/env bash` and `set -euo pipefail`. Each operation renders to one `bus ...` line. All strings are single-quoted with deterministic escaping. Output does not embed timestamps by default so that byte-stability is preserved.

### Export Plan (default “accounting snapshot”)

Export produces operations in this order: (1) Workspace configuration — `bus config init` (guard: datapackage missing or missing busdk subtree), `bus config set ...` only if needed to match exported values, guarded by “already equal”. (2) Module baseline init for modules that are present or required by scope — `bus accounts init`, `bus period init`, `bus journal init`, `bus attachments init`, `bus invoices init`, `bus bank init`, `bus vat init` only when include vat or VAT datasets exist and scope requires. (3) Master data — accounts via `bus accounts add --code ... --name ... --type ...` (one per account; guard: account absent). (4) Profile-driven ERP imports (opt-in) — `bus invoices import --profile <path> --source <path> ...` and `bus bank import --profile <path> --source <path> ...` with deterministic guards and references to import artifacts (plan/result files). (5) Period control — period creation `bus period add ...` (guard: period absent), state transitions `bus period open|close|lock ...` (guard: current state &lt; desired state). (6) Attachments — `bus attachments add <file> --desc ...` (guard: attachment absent; path stable and workspace-relative). (7) Journal postings — `bus journal add --date ... --desc ... --debit ... --credit ...` (guard: transaction absent); if the workspace contains stable transaction identifiers, export uses them for guards and ids; otherwise export uses a deterministic hash of the posting payload as the guard id. (8) Optional derived actions (opt-in) — VAT `bus vat report --period ...` and `bus vat export --period ...` (guarded); reports: module-specific actions when those modules define idempotent “generate once” outputs.

### Apply Behavior

`bus replay apply` reads operations (JSONL). For each operation it evaluates the guard: if the guard is satisfied (“already done”), it skips with a deterministic “skipped” record; otherwise it executes the command in-process (preferred via library integration) or via the dispatcher as a subprocess (allowed as an implementation detail, but must be deterministic). It produces a deterministic report (TSV or JSON) summarizing applied, skipped, and failed operations. `--dry-run` prints what would run and why without executing.

### Assumptions and Dependencies

Bus Replay assumes the workspace layout and [data path contract](./modules#data-path-contract-for-read-only-cross-module-access) are respected: owning modules expose path accessors for their datasets, and workspace configuration is present in the expected location. It depends on [bus config](./bus-config), [bus data](./bus-data), [bus accounts](./bus-accounts), [bus period](./bus-period), [bus journal](./bus-journal), [bus attachments](./bus-attachments), and optionally [bus vat](./bus-vat) and report-producing modules for path resolution and, during apply, for command execution. If an owning module’s path API or CLI contract changes, replay export and apply may need to be updated. The module assumes no concurrent modification of the workspace during export; apply assumes the target workspace is not modified by other processes in a way that invalidates guards.

### Glossary and Terminology

**Replay log.** The deterministic, append-only sequence of operations (JSONL) emitted by export and consumed by apply and render.

**Operation.** A single entry in the replay log: an id, kind, command path, optional args, optional guard, and optional notes.

**Guard.** A condition evaluated during apply to decide whether an operation has already been applied; when satisfied, the operation is skipped (idempotency).

**Operation id.** A stable, deterministic identifier for an operation (e.g. `accounts:add:3000`); used for deduplication and reporting.

**Effective state.** The current accounting state of the workspace (e.g. chart of accounts, periods, postings) as observable from the datasets, without inferring history that is not explicitly represented.

**Snapshot mode.** Export mode that produces the minimal set of operations needed to recreate the current effective state (default). **History mode** is best-effort export of raw row history where the domain supports it.

### Error Handling and Resilience

Export fails fast if required datasets are missing for the selected scope. Export can optionally run workspace validation first (`--require-valid`) and fail with a concise diagnostic. Apply stops on first error by default and prints the operation id and command.

### Security Considerations

Replay logs may embed business-sensitive metadata (descriptions, evidence paths). Store logs in the same access-controlled repo as the workspace. Apply executes commands; it must not execute arbitrary shell snippets from the log. The log is structured, and only `bus` commands are executed.

### Testing Strategy

Golden tests: a known fixture workspace yields exported JSONL that matches a committed golden file byte-for-byte. Roundtrip tests: fixture workspace → export → apply into empty dir → validate equivalence (effective state). Idempotency tests: apply the same log twice; the second run produces only “skipped”. Renderer tests: JSONL → sh rendering matches golden script output.

### Implementation status

The `bus replay` CLI is implemented: subcommands `export`, `apply`, and `render` exist for deterministic log export, apply, and rendering. Current releases implement the established include surface (`vat,reports`) and core export/apply/render behavior; the `erp-imports` include path defined in IF-RPL-001 remains planned and is not yet shipped.

Export with `--scope accounting --format sh` covers workspace configuration, accounts, periods, journal postings, and attachment references and produces large but deterministic scripts. Export does **not** yet include row-level facts for canonical invoice and bank datasets: operations that would recreate `sales-invoices`, `purchase-invoices`, `bank-transactions`, and related row data are omitted. As a result, full migration replay still requires hand-written or generated append scripts for those datasets (for example `exports/2023/*.sh` and `exports/2024/*.sh`) in addition to the exported replay script. A single artifact for full replay — config, accounts, periods, journal, attachments, **and** row-level invoice/bank/reconcile facts — is the target; current implementation does not yet emit the latter.

The first-class profile-import replay workflow required by FR-RPL-008 is not yet implemented. Current ERP history migration still uses generated explicit append scripts (for example `exports/2024/017-erp-invoices-2024.sh` and `exports/2024/018-erp-bank-2024.sh`) built from ERP TSV mappings. Those scripts are deterministic and auditable, but they remain large, one-off artifacts that are difficult to reuse across repositories. Until replay can emit and render profile-based import operations with deterministic import-artifact references, operators should continue using the current generated scripts for ERP history ingestion.

### Open Questions

**OQ-RPL-001 Exact “effective equivalence” definition.**  
For snapshot mode, equivalence is “same effective accounting state”. Which datasets are required for equivalence checks beyond accounts, period, journal, attachments, and vat?

**OQ-RPL-002 Transaction identity contract.**  
Should [bus journal](./bus-journal) expose a stable transaction id in its dataset that bus-replay can always use for guards, or should bus-replay rely on hashing the posting payload?

**OQ-RPL-003 Import artifact reference contract.**  
For profile-driven ERP imports, should replay guards reference only deterministic import result artifact paths, or also include a source snapshot digest in guard evaluation to prevent accidental replay against changed source exports?

### Sources

- [SDD index](./index)
- [Module SDDs](./modules)
- [bus config](./bus-config), [bus data](./bus-data), [bus accounts](./bus-accounts), [bus period](./bus-period), [bus journal](./bus-journal), [bus attachments](./bus-attachments), [bus vat](./bus-vat)
- [Workspace layout](../layout/minimal-workspace-baseline)
- [Standard global flags](../cli/global-flags)
- [bus-invoices SDD](./bus-invoices)
- [bus-bank SDD](./bus-bank)
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-replay module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-REPLAY`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team

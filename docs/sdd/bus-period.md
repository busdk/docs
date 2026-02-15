---
title: bus-period — accounting period open/close and locking (SDD)
description: Bus Period opens and closes accounting periods, generates closing and opening balance entries, carries forward opening entries from a prior workspace, and locks periods to prevent changes after close.
---

## bus-period — accounting period open/close and locking

### Introduction and Overview

Bus Period opens and closes accounting periods, generates closing and opening balance entries, carries forward opening entries from a prior workspace into the current workspace, and locks periods to prevent changes after close.

### Requirements

FR-PER-001 Period control datasets. The module MUST store period open, close, and lock states as schema-validated repository data. Acceptance criteria: period rows validate against schemas and are append-only.

FR-PER-002 Close and lock operations. The module MUST generate closing entries and enforce period locks. Acceptance criteria: close outputs are deterministic and locked periods reject writes.

FR-PER-003 Opening from prior workspace. The module MUST provide a CLI operation that generates the opening entry for a new fiscal year in the current workspace from the closing balances of a prior workspace (e.g. a separate workspace repository for the previous year). Acceptance criteria: the command reads the prior workspace, computes account balances as-of a specified date using the same logic as period close or journal balance, creates exactly one balanced journal transaction in the current workspace with deterministic provenance, and refuses to run when preconditions are not met (target period not open, opening entry already exists without `--replace`, account or period validation failures).

NFR-PER-001 Auditability. Period transitions MUST remain reviewable in repository history. Acceptance criteria: period control datasets preserve open and close boundaries without overwrites.

NFR-PER-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (period control dataset and schema). Other modules that need read-only access to period control raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the period dataset (and schema); consumers use these accessors for read-only access; no consumer hardcodes `periods.csv` outside this module.

Planned: automatic result-to-equity transfer at year end (profit/loss to equity account as part of close or a dedicated step). Until implemented, users post the transfer via [bus-journal](../sdd/bus-journal).

### System Architecture

Bus Period owns the period control datasets and uses journal data to generate closing entries. The `opening` subcommand reads journal and period data from a prior workspace and appends one opening transaction to the current workspace journal via existing journal APIs. The module integrates with validation, VAT, and reporting workflows that precede filing and exports.

### Key Decisions

KD-PER-001 Period control is recorded as repository data. Period transitions are stored in datasets so close and lock boundaries remain reviewable.

KD-PER-002 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of the period control dataset for read-only access. Write access and all period business logic (open, close, lock, opening entry) remain in this module.

### Component Design and Interfaces

Interface IF-PER-001 (module CLI). The module exposes `bus period` with subcommands `init`, `open`, `close`, `lock`, and `opening` and follows BusDK CLI conventions for deterministic output and diagnostics.

Interface IF-PER-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s) (e.g. period control CSV and schema). Given a workspace root path, the library returns the path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; all writes and period logic remain in this module.

The `init` command creates the baseline period control dataset and schema when they are absent. The baseline consists of the schema and a period control file that may be empty or contain only a header row; it does not pre-create any period rows. If both `periods.csv` and `periods.schema.json` already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If only one of them exists or the data is inconsistent, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

The `open` command marks the given period as open. If the period does not yet exist in the period control dataset, the command MUST create it (append a period record) and set its state to open, so that the workflow "init then open --period &lt;id&gt;" succeeds without any intermediate step. If the period already exists and is open, `open` is idempotent (exit 0, no change). If the period already exists and is closed or locked, behavior is implementation-defined (re-open may be refused or allowed; the command MUST exit non-zero with a clear diagnostic when it refuses).

Period selection is always explicit and flag-based. The `open`, `close`, and `lock` commands accept `--period <period>` as a required parameter and do not use positional period arguments. A period identifier is a stable string in one of three forms: `YYYY` for a full-year period, `YYYY-MM` for a calendar month, or `YYYYQn` for a quarter (where `n` is 1 through 4). This mirrors period usage in other modules such as `bus vat`, `bus loans`, and `bus payroll`, which also use `--period` and `YYYY-MM` or `YYYYQn` formats rather than positional arguments.

Close generates posting output and therefore accepts one additional optional flag: `--post-date <YYYY-MM-DD>`. When `--post-date` is omitted, the closing entry date defaults to the last date of the selected period, matching the default behavior of other posting-generating commands that accept `--post-date`.

#### Subcommand: opening

The `opening` subcommand generates the opening entry for a new fiscal year in the current workspace from the closing balances of a prior workspace. It is a required accounting workflow step for starting a new fiscal year correctly without manual file editing. Typical use: a prior-year workspace repository (e.g. 2023) has been closed and locked; the user has created a new workspace for the new year (e.g. 2024), initialized accounts and period control, opened the first period, and initialized the journal; `bus period opening` then produces a single balanced journal transaction that carries forward account balances from the prior workspace into the current workspace.

**Command signature.** `bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [optional flags]`. All of `--from`, `--as-of`, `--post-date`, and `--period` are required. The effective working directory for the current workspace is the directory given by `-C` / `--chdir` or the current directory.

**Flags.**

- `--from <path>`: Path to the prior workspace root. The command MUST resolve paths to that workspace’s period control, journal, and accounts datasets via the respective owning modules’ Go libraries (bus-period, bus-journal, bus-accounts), not by hardcoding file names. The path is resolved relative to the current process working directory (before any `-C`). The command does not perform network access; the prior workspace must be accessible on the local filesystem.
- `--as-of <YYYY-MM-DD>`: Closing date in the prior workspace. Account balances are computed as-of this date using the same internal logic as period close or journal balance in that workspace.
- `--post-date <YYYY-MM-DD>`: Posting date for the opening entry in the current workspace (typically the first day of the new fiscal year).
- `--period <YYYY-MM>`: Target period in the current workspace. The opening entry is associated with this period; the period must be open (see validation rules).
- `--equity-account <code>`: (Optional.) Account code for the balancing equity line (e.g. retained earnings). Default: `3200`. Rationale: many entities use a single retained-earnings or carry-forward account (often 3200 in common charts) so a fixed default reduces required flags in the common case. Users whose chart uses a different equity account for year rollover MUST override with `--equity-account`.
- `--include-zero`: (Optional.) Include accounts with zero balance in the opening entry. Default: false. By default only non-zero balances are included; when set, the command includes one line per account that exists in the prior workspace chart (or per account that has journal activity in the prior workspace, as defined by the implementation) so that the opening entry explicitly shows zero balances where desired.
- `--description <text>`: (Optional.) Override the default transaction description. When omitted, the description is deterministic: it MUST include provenance sufficient for audit, specifically the normalized path to the source workspace and the as-of date (e.g. “Opening balances from &lt;normalized-path&gt; as-of YYYY-MM-DD”). Normalization of the path (e.g. absolute or relative) is implementation-defined but MUST be stable for the same path so that repeated runs produce the same description.
- `--replace`: (Optional.) If an opening entry already exists for the target period that was created by this command (identified deterministically, e.g. by a fixed prefix or marker in the transaction description), remove only that entry (or those entries) and then create the new opening entry. The command MUST NOT remove arbitrary user postings; only entries that can be deterministically attributed to a previous `bus period opening` run for the same target period may be removed. If no such entry exists, `--replace` has no effect on removal and the command proceeds to create the opening entry. Default: false; when false, the command refuses to run if an opening entry for the target period already exists (as identified by the same deterministic rule).
- `--allow-as-of-mismatch`: (Optional.) Allow running when the prior workspace’s fiscal year end (from its workspace config, if available) does not match `--as-of`. When omitted, the command MUST refuse to run if the prior workspace has a defined fiscal year end and it does not equal `--as-of`, with a clear diagnostic. When set, the command proceeds so that operators can intentionally carry forward from a different cut-off date (e.g. mid-year migration). Default: false.

**Deterministic behavior and validation.** The command MUST read the prior workspace state and compute account balances as-of `--as-of` using the same internal logic as period close or journal balance (so that closing balances and opening-source balances are consistent). It MUST resolve paths to the prior workspace’s accounts, journal, and period datasets via the bus-accounts, bus-journal, and bus-period Go libraries (read-only path access). The command MUST require that the current workspace has a chart of accounts initialized (path and schema obtained via bus-accounts library). It MUST validate that every account code used in the opening entry exists in the current workspace chart of accounts; if any code is missing, it MUST exit non-zero with a clear diagnostic and MUST NOT write any journal data. The command MUST refuse to run if the target period is not open or is closed/locked. It MUST refuse to run if the prior workspace has a defined fiscal year end and that date does not match `--as-of`, unless `--allow-as-of-mismatch` is set. It MUST refuse to run if an opening entry for the target period already exists (identified as above) unless `--replace` is provided. The command MUST NOT directly edit files outside BusDK modules; it MUST use existing library APIs (e.g. bus-journal or shared journal layer) for journal append and validation so that all writes go through the same schema and balance checks.

**Output data changes.** The command creates exactly one balanced journal transaction in the current workspace, dated `--post-date`, with one line per (included) balance from the prior workspace plus a balancing line posted to the selected equity account. The transaction MUST include deterministic provenance in its description when `--description` is not set (normalized source workspace path and as-of date). The resulting journal MUST pass the same validation as any other journal transaction (balanced to zero, schema-valid, account codes present in the current chart). VAT reporting period and other workspace configuration (e.g. in [bus-config](../sdd/bus-config)) are not modified by this command.

**Acceptance criteria and invariants.** The generated opening entry MUST be balanced to zero. Output MUST be deterministic for the same inputs (same `--from`, `--as-of`, `--post-date`, `--period`, `--equity-account`, `--include-zero`, and prior/current workspace contents). Validation of the resulting journal (e.g. `bus journal validate` or equivalent) MUST pass. The command MUST NOT perform network or interactive operations.

**Example workflow (year rollover).** In the new workspace: run `bus accounts init` and populate the chart of accounts; run `bus period init`; run `bus period open --period 2024-01`; run `bus journal init`; then run `bus period opening --from ../sendanor-books-2023 --as-of 2023-12-31 --post-date 2024-01-01 --period 2024-01 --equity-account 3200`. VAT reporting period and other workspace configuration are handled by bus-config and are not modified by `bus period opening`.

Usage examples:

```bash
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

### Data Design

The module reads and writes the period control dataset at the workspace root as `periods.csv`, with a beside-the-table schema file `periods.schema.json`. Paths are root-level only: there is no subdirectory (for example, the data is not under `periods/periods.csv`). Period operations append records so period boundaries remain reviewable.

Period rows enter the dataset when the user runs `open --period <id>` for a period that is not yet present; the `open` command creates the period record and sets it to open. The `init` command creates only the dataset file and schema (empty or header-only); it does not insert any period rows. There is no separate "add period" command; opening a period is the way to create it.

Other modules that need read-only access to the period control dataset (e.g. to check open/closed state in another workspace) MUST obtain the path from this module’s Go library (IF-PER-002). All writes and period-domain logic remain in this module.

### Assumptions and Dependencies

Bus Period depends on journal datasets and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Period locks are a control boundary and must be enforced in the module to prevent edits to closed periods. Repository access controls protect underlying data.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Close, lock, or opening violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover period state transitions and close calculations, and command-level tests exercise `open`, `close`, `lock`, and `opening` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic period control.

### Glossary and Terminology

Period control dataset: the repository dataset that records period boundaries and locks.  
Period lock: a state that prevents edits to closed period data.  
Opening entry: a single balanced journal transaction that carries forward account balances from a prior workspace into the current workspace, produced by `bus period opening`.  
Prior workspace: the workspace (e.g. a separate repository for the previous fiscal year) whose closing balances are used as the source for an opening entry in the current workspace.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Accounting periods](../master-data/accounting-periods/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [End user documentation: bus-period CLI reference](../modules/bus-period)
- [Repository](https://github.com/busdk/bus-period)
- [Year-end close (closing entries)](../workflow/year-end-close)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)

### Document control

Title: bus-period module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-PERIOD`  
Version: 2026-02-15  
Status: Draft  
Last updated: 2026-02-15  
Owner: BusDK development team  

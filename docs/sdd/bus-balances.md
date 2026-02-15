---
title: bus-balances — balance snapshot dataset and opening/cutover journal materialization (SDD)
description: Bus Balances owns an append-only balance snapshot dataset, provides add/import to build snapshots, and apply to materialize a snapshot as one balanced journal transaction for opening or cutover.
---

## bus-balances — balance snapshot dataset and opening/cutover journal materialization

### Introduction and Overview

Bus Balances is a **CLI-first, deterministic, non-interactive, filesystem-only** module that owns a **balance snapshot dataset** (trial balance snapshot) as repository data and provides CLI commands to create and validate snapshots and to generate exactly one balanced journal transaction from a snapshot for opening or cutover. The module is a bridge in two steps: (1) from external balances (e.g. Excel) and manual entry **into** the snapshot dataset; (2) from the snapshot **into** normal [bus-journal](./bus-journal) data. Users do not edit the snapshot or journal files by hand; all writes go through the CLI and module APIs. The snapshot dataset is **append-only** and **reviewable in Git history**; the journal remains the canonical accounting output for reporting and filing.

The **core primitive** for building a snapshot is **`bus balances add`** — one row at a time. Bulk loading from a CSV is a convenience via **`bus balances import`**, which appends rows into the same snapshot dataset (it does **not** write journal data). Materializing a snapshot into a journal transaction is a **separate step**: **`bus balances apply`**, which reads the snapshot and writes exactly one balanced transaction through the bus-journal library. The module does not require a prior-year Bus workspace; the current workspace chart of accounts ([bus-accounts](./bus-accounts)), period state ([bus-period](./bus-period)), and journal ([bus-journal](./bus-journal)) are used for validation and for `apply`.

Intended users are implementers and operators who need to build opening or cutover balance snapshots and turn them into journal entries. This document is the module SDD for human review and implementation agents; correctness and completeness are verified by a human before the design is treated as authoritative. What is explicitly out of scope is listed in **Scope boundaries** below.

### Requirements

FR-BAL-001 **Owned snapshot dataset.** The module MUST own a balance snapshot dataset at the workspace root: `balances.csv` and its beside-the-table schema `balances.schema.json`. The dataset MUST be append-only (no overwrite of existing rows). Other modules MUST obtain the path to this dataset via this module's Go library path accessor, not by hardcoding file names. Acceptance criteria: after `bus balances init`, the files exist and validate; appends only add rows; no command deletes or overwrites existing snapshot rows.

FR-BAL-002 **Effective-record model for snapshot.** The snapshot dataset MUST use an effective-record rule: for a given as-of date and account code, the **effective balance** is the row with the latest `recorded_at` for that (as_of, account_code). This allows users to correct balances by appending a new row without editing history. Acceptance criteria: `list` and `apply` use only effective records (latest-wins per as_of, account_code); validation can check effective set for a given as-of.

FR-BAL-003 **Add as core command.** The module MUST provide `bus balances add` that appends exactly one row to the snapshot dataset. It MUST require `--as-of <YYYY-MM-DD>` and `--account <code>`, and either `--amount <signed>` or both `--debit` and `--credit`. It MUST refuse if both amount and debit/credit are supplied, or if neither is supplied. The account MUST exist in the current workspace chart (bus-accounts). Parsing and `recorded_at` MUST be deterministic. Acceptance criteria: after any successful `add`, `bus balances validate --as-of <date>` succeeds for that snapshot unless the effective set for that date is incomplete or inconsistent (e.g. user has not yet added all accounts they intend for that snapshot); "complete" for validation is defined as: effective rows for that as_of pass schema and account-existence checks and (if the module defines it) any internal consistency rule (e.g. optional check that effective balances sum to zero or that no duplicate account in effective set).

FR-BAL-004 **Import as bulk add (no journal write).** The module MUST provide `bus balances import` that reads a CSV and **appends one row per input line into the snapshot dataset** (same semantics as repeated `add`). It MUST NOT write journal data. Required: `--input <path>`, `--as-of <YYYY-MM-DD>`. Optional: `--format signed|dc`, `--source <text>`, `--allow-unknown-accounts`. When `--allow-unknown-accounts` is set, the module MUST report missing account codes and exit non-zero with **no writes** to the snapshot dataset. Acceptance criteria: import with valid CSV appends rows to balances.csv; import does not call bus-journal; with `--allow-unknown-accounts` and unknown accounts, no rows appended and exit non-zero.

FR-BAL-005 **Apply materializes snapshot to one journal transaction.** The module MUST provide `bus balances apply` that reads the **effective** snapshot for a given as-of date and generates **exactly one** balanced journal transaction in the current workspace via bus-journal APIs. Required: `--as-of <YYYY-MM-DD>`, `--post-date <YYYY-MM-DD>`, `--period <YYYY-MM>`. Preconditions: target period open (bus-period effective state), journal initialized, snapshot exists for that as-of (at least one effective balance row), every account_code in the effective snapshot exists in the chart. Optional: `--equity-account`, `--balancing-account` (mutual exclusivity; see FR-BAL-008), `--replace`, `--description`, `--include-zero`. Acceptance criteria: one run produces one transaction; transaction is balanced to zero and passes `bus journal validate`; deterministic line order (e.g. by account_code) and provenance in description when not overridden.

FR-BAL-006 **Preconditions for apply.** Before writing any journal data, `apply` MUST verify: (1) target period exists and is **open** (bus-period effective-record rules); (2) journal is initialized (bus-journal); (3) snapshot has at least one effective row for `--as-of`; (4) every account_code in the effective snapshot exists in the chart; (5) chosen balancing account exists. If any precondition fails, exit non-zero and do not write. Acceptance criteria: apply with period closed/locked fails with clear diagnostic; apply with empty snapshot for that as-of fails; unknown account in effective snapshot fails with row/account diagnostic.

FR-BAL-007 **Deterministic provenance and replace for apply.** When `--description` is not supplied, the generated journal transaction description MUST include a stable marker (e.g. `BUS_BALANCES_APPLY`), the as-of date, and the target period (snapshot key for replace). When `--replace` is set, the module MUST remove only prior transaction(s) created by this module for the same snapshot key (as-of date + target period) and then write the new transaction. When `--replace` is not set, if such a transaction already exists, the command MUST refuse and exit non-zero. Acceptance criteria: default description contains marker, as-of, period; second apply without replace refuses; with replace removes only that transaction and writes one new one.

FR-BAL-008 **Balancing account for apply.** The user MUST specify the balancing account via `--equity-account <code>` or `--balancing-account <code>`. The two flags are mutually exclusive in effect: if both are supplied, **`--balancing-account` wins**. If neither is supplied, the default is `3200` (documented and validated). The chosen account MUST exist in the chart. Acceptance criteria: exactly one balancing account per apply run; both supplied → balancing-account wins; neither → default 3200; missing/invalid balancing account → exit non-zero.

FR-BAL-009 **Posting semantics for apply.** The module MUST treat each effective snapshot row as the **final signed balance** for that account and MUST generate journal postings (debit/credit or signed per bus-journal model) against the balancing account. It MUST NOT infer account type; the snapshot's sign convention is used. The transaction MUST be balanced to zero and MUST pass `bus journal validate`. Acceptance criteria: positive amount ⇒ debit account, credit balancing; negative ⇒ credit account, debit balancing; `bus journal validate` succeeds after apply.

FR-BAL-010 **Validate and list.** The module MUST provide `bus balances validate [--as-of <YYYY-MM-DD>]` that validates schema and business rules; if `--as-of` is provided, validate that snapshot's effective set (e.g. all account_codes exist in chart, amounts parse, no duplicate account in effective set if that is a rule). MUST provide `bus balances list [--as-of <YYYY-MM-DD>]` that prints effective balances (latest-wins per as_of, account_code) by default; optional `--history` MAY show all rows. Acceptance criteria: validate exits 0 when dataset and effective set are valid; list output is deterministic and ordered.

FR-BAL-011 **Init and template.** The module MUST provide `bus balances init` that creates the balances dataset and schema when absent (idempotent: if both exist and are consistent, warn and exit 0). It MAY provide `bus balances template` that prints a CSV template (e.g. header and example row) to stdout for use with import. Acceptance criteria: init creates balances.csv and balances.schema.json; re-run init when files exist is idempotent; template does not write workspace files.

FR-BAL-012 **No manual file editing.** Users MUST NOT be required to edit `balances.csv` or journal files by hand for normal workflows; all snapshot and journal writes go through the CLI. Acceptance criteria: add, import, and apply are the only ways to write snapshot and journal data from this module; documentation states that manual edits are unsupported for auditability.

NFR-BAL-001 **Auditability.** The snapshot dataset and journal transactions MUST be reviewable in Git history with deterministic provenance. Acceptance criteria: append-only snapshot; apply writes one transaction with stable marker and snapshot key.

NFR-BAL-002 **Path exposure via Go library.** The module MUST expose Go library APIs that return the workspace-relative path(s) to `balances.csv` and `balances.schema.json`. Other modules that need read-only access to the snapshot MUST use these accessors.

NFR-BAL-003 **Operational constraints.** The module is filesystem-only and single-workspace with no network I/O. Security is limited to repository and filesystem access controls. No scalability or multi-tenant requirements apply. Reliability and maintainability are achieved by deterministic behavior, clear diagnostics, and append-only data. Acceptance criteria: no network calls; path resolution uses owning-module accessors only; exit codes and diagnostics are documented and deterministic.

### Scope boundaries

In scope:
- **Balance snapshot dataset** as owned, append-only repository data; **add** (one row) and **import** (bulk add from CSV) to build snapshots; **apply** to materialize a snapshot into exactly one balanced journal transaction for opening/cutover.
- Validation, list, init, template; deterministic replace semantics for apply; no-manual-edit workflow.

Out of scope:
- General ledger balance calculator or computing running balances from the journal.
- Automatically reconstructing historical transactions.
- Reconciling bank statements.
- Replacing [bus-period](./bus-period) opening-from-prior-workspace when the prior workspace exists (that flow remains preferred when available).

### System Architecture

Bus Balances is a CLI module `bus balances` that is **CLI-first, deterministic, non-interactive, and filesystem-only** (no network, no Git commands). It **owns** the balance snapshot dataset at the workspace root (`balances.csv`, `balances.schema.json`). It **reads** the chart of accounts path from the [bus-accounts](./bus-accounts) Go library, period control path and effective state from the [bus-period](./bus-period) Go library, and **writes** journal data only through the [bus-journal](./bus-journal) Go library APIs. It does not hardcode other modules' file names; path resolution uses owning-module accessors. All diagnostics go to stderr; exit codes are deterministic and documented.

**Data flow.** (1) **Snapshot building:** `add` and `import` append rows to `balances.csv`; effective record = latest `recorded_at` per (as_of, account_code). (2) **Snapshot → journal:** `apply` reads effective snapshot for a given as-of, builds one balanced transaction, and appends it via bus-journal. No other command writes journal data. (3) **Validation and listing:** `validate` and `list` read the snapshot (and optionally chart) and emit deterministic output.

### Key Decisions

KD-BAL-001 **Snapshot dataset is the durable intermediate; journal is the canonical accounting output.** Snapshots are stored in the owned dataset so users can build and correct them over time (append-only, latest-wins). The journal is written only when the user runs `apply`; that keeps the accounting ledger single-source-of-truth and avoids duplicate or ad-hoc balance tables elsewhere.

KD-BAL-002 **Add is the core primitive.** Building a snapshot is done primarily with `bus balances add` (one row at a time). `import` is a convenience that bulk-adds rows into the same dataset with the same semantics. This keeps the model simple and audit-friendly.

KD-BAL-003 **Apply is the only path to journal.** Only `bus balances apply` writes journal data. Import never writes journal; the two-step flow (snapshot → apply) is explicit and reviewable.

KD-BAL-004 **Effective-record model.** Latest `recorded_at` per (as_of, account_code) allows corrections without overwriting history and keeps the schema append-only.

KD-BAL-005 **Balancing account:** `--equity-account` or `--balancing-account`; if both supplied, `--balancing-account` wins; default `3200` when neither supplied. Safe replace for apply removes only transactions created by this module for the same snapshot key.

### Component Design and Interfaces

Interface IF-BAL-001 (module CLI). The module exposes `bus balances` with subcommands `init`, `add`, `import`, `apply`, `validate`, `list`, and optionally `template`. It follows BusDK CLI conventions ([standard global flags](../cli/global-flags), [CLI command naming](../cli/command-naming)), deterministic output, and clear stderr diagnostics. Exit codes: 0 on success; non-zero on invalid usage, precondition failure, or validation failure.

Interface IF-BAL-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to `balances.csv` and `balances.schema.json` given a workspace root. Other modules use these for read-only access (see [Data path contract for read-only cross-module access](./modules#data-path-contract-for-read-only-cross-module-access)).

#### Subcommand: init

**Signature.** `bus balances init [-C <dir>] [global flags]`

**Contract.** Creates `balances.csv` and `balances.schema.json` when absent. If both already exist and are schema-consistent, prints a warning to stderr and exits 0 without modifying. If only one exists or data is inconsistent, fails with clear error and does not write. Does not create or modify accounts, period, or journal datasets. Satisfies FR-BAL-001, FR-BAL-011.

#### Subcommand: add

**Signature.** `bus balances add --as-of <YYYY-MM-DD> --account <code> (--amount <signed> | --debit <n> --credit <n>) [--source <text>] [--notes <text>] [-C <dir>] [global flags]`

**Contract.**
- Appends **exactly one row** to the balances dataset.
- **Required:** `--as-of`, `--account`. **Amount:** either `--amount <signed>` (signed number) or both `--debit <n>` and `--credit <n>` (net = debit − credit). If both `--amount` and `--debit`/`--credit` are provided, the command MUST refuse (invalid usage, exit non-zero). If neither amount nor debit/credit is provided, MUST refuse.
- The account (`--account`) MUST exist in the current workspace chart of accounts (path from bus-accounts library); otherwise exit non-zero, clear diagnostic, no write.
- Trimming and number parsing MUST be deterministic. `recorded_at` MUST be set deterministically (e.g. current time in UTC or workspace timezone as documented).
- Optional `--source` and `--notes` are stored in the new row.

**Acceptance criteria.** After any successful `add`, `bus balances validate --as-of <date>` succeeds for that as-of date unless the effective set for that date is incomplete or inconsistent (e.g. user has not finished adding all accounts, or effective set fails an optional consistency rule). "Complete" for validation: effective rows pass schema and account-existence checks; the module MAY define an optional internal consistency rule (e.g. effective balances sum to zero) and document it. Satisfies FR-BAL-003.

#### Subcommand: import

**Signature.** `bus balances import --input <path> --as-of <YYYY-MM-DD> [--format signed|dc] [--source <text>] [--allow-unknown-accounts] [-C <dir>] [global flags]`

**Contract.**
- **Bulk add into the snapshot dataset only.** Validates and normalizes the input CSV and appends **one row per data line** to `balances.csv` with the same semantics as repeated `add` (same schema, effective-record model). **MUST NOT write journal data.**
- **Required:** `--input <path>`, `--as-of <YYYY-MM-DD>`.
- **Optional:** `--format signed` (default) or `dc` (columns account_code, amount vs account_code, debit, credit; net = debit − credit); `--source <text>` (stored in appended rows); `--allow-unknown-accounts`.
- **CSV rules:** Header required; deterministic trimming; single decimal separator (`.`); no thousands separators. For `signed`: columns `account_code`, `amount`. For `dc`: columns `account_code`, `debit`, `credit`.
- **Account validation:** Every `account_code` in the CSV MUST exist in the current workspace chart. If any is unknown and `--allow-unknown-accounts` is **not** set: exit non-zero, diagnostic with row/account, **no rows appended**. If `--allow-unknown-accounts` **is** set: report missing account codes (e.g. to stderr), exit non-zero, **no rows appended** (no writes to snapshot). Satisfies FR-BAL-004.

#### Subcommand: apply

**Signature.** `bus balances apply --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY-MM> [--equity-account <code> | --balancing-account <code>] [--replace] [--description <text>] [--include-zero] [-C <dir>] [global flags]`

**Preconditions (all required before any journal write).**
1. Target period (`--period`) exists in the period control dataset and its **effective state** (bus-period: latest record by `recorded_at` for that period) is **open**.
2. Workspace journal is initialized (bus-journal).
3. Snapshot has at least one **effective** balance row for `--as-of` (i.e. at least one (as_of, account_code) with a row).
4. Every `account_code` in the effective snapshot for that as-of exists in the workspace chart of accounts.
5. The chosen balancing account (from `--equity-account`, `--balancing-account`, or default `3200`) exists in the chart.

If any precondition fails: exit non-zero, clear diagnostic, **do not write** journal data.

**Contract.**
- Reads the **effective** snapshot for `--as-of` (latest-wins per account_code).
- Generates **exactly one** balanced journal transaction: one posting per effective account (in deterministic order, e.g. ascending account_code), plus one balancing posting to the balancing account. Zero-balance rows are included only if `--include-zero` is set (otherwise excluded by default).
- Writes via **bus-journal** library only; transaction MUST be balanced to zero and MUST pass `bus journal validate`.
- **Description:** When `--description` is not supplied, description MUST include: stable marker (e.g. `BUS_BALANCES_APPLY`), as-of date, target period (for replace detection). When `--description` is supplied, implementation MUST still embed marker and snapshot key so replace detection works.
- **Replace:** When `--replace` is set, remove only prior transaction(s) created by this module for the same snapshot key (as-of date + target period), then write the new transaction. When `--replace` is not set, if such a transaction already exists, refuse and exit non-zero.
- **Balancing account:** Mutual exclusivity: if both `--equity-account` and `--balancing-account` are supplied, **`--balancing-account` wins**. If neither, default `3200`.

**Posting semantics.** Each effective snapshot row has a signed `amount`. For amount X: if X > 0, debit account |X| and credit balancing |X|; if X < 0, credit account |X| and debit balancing |X| (or equivalent signed posting if bus-journal model uses signed amounts). The module does NOT infer account type; the snapshot's sign is used as-is. Resulting transaction MUST be balanced to zero.

**Deterministic ordering.** Journal lines MUST be emitted in a stable order (e.g. effective accounts sorted by account_code ascending, then balancing-account line last). Satisfies FR-BAL-005, FR-BAL-006, FR-BAL-007, FR-BAL-008, FR-BAL-009.

#### Subcommand: validate

**Signature.** `bus balances validate [--as-of <YYYY-MM-DD>] [-C <dir>] [global flags]`

**Contract.** Validates the snapshot dataset against its schema. If `--as-of` is provided, validates that snapshot's **effective set**: e.g. every account_code exists in the chart, amounts parse, and any defined internal consistency rule (e.g. no duplicate account in effective set, or optional sum-to-zero). Exit 0 when valid; non-zero with diagnostics when invalid. Satisfies FR-BAL-010.

#### Subcommand: list

**Signature.** `bus balances list [--as-of <YYYY-MM-DD>] [--history] [-C <dir>] [global flags]`

**Contract.** By default prints **effective** balances (one row per (as_of, account_code) with latest `recorded_at`). If `--as-of` is provided, restrict to that as_of. Output is deterministic and ordered (e.g. by as_of, then account_code). Optional `--history`: when supported, print all rows (full history) instead of effective only. Satisfies FR-BAL-010.

#### Subcommand: template

**Signature.** `bus balances template [-C <dir>] [global flags]`

**Contract.** Prints a CSV template (header and optionally one example row) to stdout for use with `import`. Does not read or write workspace files. Optional command; may be omitted in initial implementation. Satisfies FR-BAL-011.

### Data Design

The module owns a single balance snapshot dataset at the workspace root. Location, schema, and lifecycle are defined below.

**Location.** `balances.csv` and `balances.schema.json` at the workspace root (after applying `-C`/`--chdir`).

**Schema (minimum viable).** Each row represents one balance record for a snapshot (as-of date + account + amount). Fields:

- **as_of** (date, required) — Snapshot date; format YYYY-MM-DD.
- **account_code** (string, required) — Foreign key to [bus-accounts](./bus-accounts) `accounts.csv` code; must exist in current workspace chart.
- **amount** (number/decimal as string, required) — Signed balance; deterministic parsing (e.g. single decimal separator `.`, no thousands separators).
- **source** (string, optional) — e.g. "excel", "manual", or filename for provenance.
- **notes** (string, optional) — Free text.
- **recorded_at** (datetime, required) — When the row was appended; used for effective-record rule (latest wins per (as_of, account_code)).

**Primary key / append-only.** The dataset is append-only. No composite primary key that would prevent multiple rows for the same (as_of, account_code) — users may append corrections. Effective record = row with maximum `recorded_at` for each (as_of, account_code). If the schema uses a primary key for validation, it MUST be append-only friendly (e.g. include `recorded_at` or a unique row id so duplicates on (as_of, account_code) are allowed). Example: (as_of, account_code, recorded_at) as unique constraint, or a synthetic row_id as PK. Satisfies FR-BAL-001, FR-BAL-002.

### Assumptions and Dependencies

- **Workspace root and chdir.** The effective working directory is set by the process or by `-C`/`--chdir`. All dataset paths are resolved relative to it. Impact if false: commands fail with unclear or wrong paths; document that `-C` must be applied before any path resolution.
- **bus-accounts, bus-period, bus-journal libraries.** The [bus-accounts](./bus-accounts), [bus-period](./bus-period), and [bus-journal](./bus-journal) Go libraries are available. The module obtains account and period paths and effective state from them and writes journal data only through the bus-journal library. Impact if false: init/add/import/apply cannot validate accounts or period state or write journal entries; commands must exit non-zero with clear diagnostics.
- **Import CSV encoding and numbers.** Input CSV for import is UTF-8 (or a documented encoding). Numeric parsing uses a single decimal separator (`.`) and no thousands separators. Impact if false: import may misparse amounts or fail; document encoding and number format in user docs.
- **Single-workspace, filesystem-only.** The module does not use the network and operates on one workspace at a time. Impact if false: NFR-BAL-003 would not hold; document any new dependency (e.g. network, multi-workspace) in the SDD.

### Error Handling and Resilience

- On any validation or precondition failure, exit non-zero; do not write snapshot rows (for add/import) or journal (for apply) when the failure occurs before the write.
- Diagnostics MUST go to stderr and identify the exact row/field when applicable (e.g. "row 5: unknown account code 9999").
- Replace (apply) MUST remove only transactions created by this module for the same snapshot key; no other journal entries may be removed.
- Exit status MUST be documented: 0 success; non-zero for invalid usage, precondition failure, validation failure, or (import) `--allow-unknown-accounts` with missing accounts.

### Testing Strategy

**Unit tests (mandated).**
- **Parsing:** Import CSV parsing for both formats (signed, dc); trimming and decimal rules; invalid numbers and missing columns produce deterministic errors.
- **Effective-record selection:** For a given as_of, the effective row per account_code is the one with latest `recorded_at`; unit tests with multiple rows per (as_of, account_code) verify correct selection.
- **Deterministic ordering:** Apply generates journal lines in specified order (e.g. by account_code); two runs with same effective snapshot produce identical line order.
- **Apply transaction generation:** Building the balanced transaction from effective snapshot; balancing line; sum to zero.
- **Replace detection:** Identification of prior apply-created transactions by marker and snapshot key (as-of, period); matching and non-matching keys behave as specified.
- **Unknown accounts:** add refuses unknown account; import without `--allow-unknown-accounts` refuses and reports; import with `--allow-unknown-accounts` reports and does not append any row.

**End-to-end tests (mandated).**
- **Full workflow:** Init workspace (accounts init + minimal accounts including 3200), period add/open, journal init, **balances init**, **balances add** a few lines (different accounts, same as-of), **bus balances validate --as-of <date>** succeeds, **bus balances apply** with that as-of and post-date/period, **bus journal validate** succeeds. Assert journal contains exactly one new transaction from apply, balanced and with provenance.
- **Apply idempotency:** After the above, run apply again with same as-of/period without `--replace` → refuses, exit non-zero, clear diagnostic. Run apply with `--replace` → exit 0, previous apply-created transaction removed, one new transaction written; journal validate still passes.
- **Import:** Run **bus balances import** with a CSV (same or different as-of); assert rows appended to balances.csv; run **bus balances validate --as-of <date>**; run **bus balances apply**; journal validate succeeds.
- **Unknown accounts:** Import with CSV containing unknown account code (without `--allow-unknown-accounts`) → exit non-zero, no rows appended. Same CSV with `--allow-unknown-accounts` → missing account codes reported, exit non-zero, no rows appended. add with unknown account → exit non-zero, no row appended.

### Migration/Rollout

New module with new dataset; no migration of existing datasets. Workspaces that do not use bus-balances simply do not have `balances.csv` until they run `bus balances init`.

### Glossary and Terminology

**Balance snapshot:** the set of account balances as-of a date; stored as rows in the snapshot dataset with effective record = latest `recorded_at` per (as_of, account_code).  
**Cutover entry:** a journal transaction that establishes starting balances when adopting BusDK mid-stream; produced by `bus balances apply`.  
**Opening entry:** a special case of cutover entry at fiscal-year start.  
**Balancing account:** the equity or clearing/suspense account used to balance the apply transaction; `--equity-account` or `--balancing-account`, or default 3200.  
**Snapshot key (for apply/replace):** the pair (as-of date, target period) that identifies an apply run for idempotency and replace.  
**Effective record (snapshot):** for a given (as_of, account_code), the row with the maximum `recorded_at`; used by list and apply.  
**Effective state (period):** the state of a period from bus-period (latest record by `recorded_at` for that period); see [bus-period](./bus-period).

### Exit status

- **0** — Success (add/import appended rows; apply wrote transaction; validate/list succeeded; init created or was idempotent).
- **Non-zero** — Invalid usage (missing required flag, both amount and debit/credit, unknown `--format`), precondition failure (period not open, journal/snapshot missing, empty snapshot for as-of), validation failure (unknown account, invalid number, balancing account missing), or import with `--allow-unknown-accounts` and one or more missing account codes. On non-zero, no snapshot rows are appended (add/import) and no journal data is written (apply) except when the implementation defines a safe ordering for replace-then-write (e.g. replace only after preconditions and validation pass).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-accounts](./bus-accounts)
- [Module SDD: bus-journal](./bus-journal)
- [Module SDD: bus-period](./bus-period)
- [End user documentation: bus-balances](../modules/bus-balances)
- [End user documentation: bus-journal](../modules/bus-journal)
- [End user documentation: bus-period](../modules/bus-period)

### Document control

Title: bus-balances module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BALANCES`  
Version: 2026-02-15  
Status: Draft  
Last updated: 2026-02-16  
Owner: BusDK development team

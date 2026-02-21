---
title: bus-journal — post and query ledger journal entries
description: bus journal maintains the authoritative ledger as append-only journal entries.
---

## `bus-journal` — post and query ledger journal entries

### Synopsis

`bus journal init [-C <dir>] [global flags]`  
`bus journal add --date <YYYY-MM-DD> [--desc <text>] [--source-id <key>] [--if-missing] --debit <account>=<amount> ... --credit <account>=<amount> ... [-C <dir>] [global flags]`  
`bus journal add --bulk-in <file|-> [-C <dir>] [global flags]`  
`bus journal classify bank --profile <rules.yml> [--bank-csv <path>] [--loan-profiles <path>] [--suspense-account <acct> --bank-account <acct> --suspense-reason <text>] [-C <dir>] [global flags]`  
`bus journal classify apply --proposal <path> [-C <dir>] [global flags]`  
`bus journal classify suspense-propose --suspense-account <acct> [selectors] [-C <dir>] [global flags]`  
`bus journal classify suspense-apply --proposal <path> [-C <dir>] [global flags]`  
`bus journal template post --template-file <path> --template <id> --date <YYYY-MM-DD> --gross <amount> [options] [-C <dir>] [global flags]`  
`bus journal template apply --template-file <path> [options] [-C <dir>] [global flags]`  
`bus journal balance --as-of <YYYY-MM-DD> [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus journal` maintains the authoritative ledger as append-only journal entries.

It enforces balanced debits/credits and respects period close/lock boundaries.

Account names in `--debit` and `--credit` must exist in the workspace [chart of accounts](../master-data/chart-of-accounts/index) (maintained by [bus accounts](./bus-accounts)).

Postings to closed or locked periods are rejected (period state comes from [bus period](./bus-period)).

Other modules post into the journal; this CLI adds entries and reports balances.

### Commands

`init` creates the journal index and baseline datasets and schemas. If they already exist in full, `init` warns and exits 0 without changes. If they exist only partially, `init` fails and does not modify files.

`add` appends a balanced transaction with one or more debit and credit lines. Optional `--source-id <key>` records source identity, and `--if-missing` makes add idempotent when a posting with the same source identity already exists. For replay-scale streams, `add --bulk-in <file|->` reads JSON array or NDJSON and applies the same validation and idempotency semantics per transaction.

`template post` posts a single template-driven entry. A predicate in the template file selects a rule, then gross amount is split into base plus VAT with deterministic rounding. `template apply` runs the same logic in batch from bank CSV (or equivalent) input.

`balance` prints account balances as of a given date.

`classify` supports deterministic bank-driven proposal and apply flows. `classify bank` emits proposal rows from bank CSV via rules and loan profiles, and can fall back to configured suspense posting for unmatched rows. `classify apply` posts applicable proposal rows with idempotent voucher ids (`bank:<bank_txn_id>`). `classify suspense-propose` scans posted suspense rows and emits deterministic reclassification proposals, and `classify suspense-apply` posts approved reclassifications with ids such as `reclass:bank:<bank_txn_id>:<target_account>`.

### Options

`add` accepts `--date <YYYY-MM-DD>`, `--desc <text>`, and repeatable `--debit <account>=<amount>` / `--credit <account>=<amount>`.

Optional `--source-id <key>` records source identity. `--if-missing` makes add idempotent (no-op when a posting with the same source identity already exists).

For bulk streams, use `--bulk-in <file|->`. Accepted formats are JSON array and NDJSON (one JSON object per line). Stderr prints deterministic summary: `bulk add completed: applied=<n> skipped=<n> total=<n>`.

`--bulk-in` is mutually exclusive with single-add flags.

At least one debit and one credit are required per transaction, and total debits must equal total credits.

`balance` accepts `--as-of <YYYY-MM-DD>`. Global flags are defined in [Standard global flags](../cli/global-flags).

### Files

Every file owned by `bus journal` includes `journal` or `journals` in its filename.

The journal index is `journals.csv` at repository root. Period journal files are also at workspace root with date prefixes (for example `journal-2026.csv`) and beside schemas (for example `journal-2026.schema.json`).

The module does not use a journal subdirectory. Path resolution is owned by this module.

When validating accounts or period boundaries, journal uses [bus accounts](./bus-accounts) and [bus period](./bus-period) datasets through module-owned paths/APIs.

### Examples

```bash
bus journal init
bus journal add \
  --date 2026-01-31 \
  --desc "January rent" \
  --debit 6300=1200 \
  --credit 1910=1200
```

### Exit status

`0` on success. Non-zero on invalid usage, unbalanced postings, or schema or period violations.

### Idempotent posting and source keys

`bus journal add` accepts optional `--source-id <key>` to record source identity for the posting. With `--if-missing`, add is a no-op when a posting with that source identity already exists, so re-runs and CI can be safe without custom script guards. Uniqueness is enforced on the source identity; conflicts produce clear diagnostics.

### Posting templates (VAT split for bank-driven entries)

Posting templates with automatic VAT split are first-class.

A template file defines one or more templates. Each template has an identifier, a predicate, and posting rule fields (expense account, VAT rate/account, bank account).

The first matching predicate in file order is used.

For `template post`, required flags are `--template-file`, `--template`, `--date`, and `--gross`.

For `template apply`, input is bank CSV (or equivalent) whose columns must satisfy predicate fields.

The module splits gross into base + VAT with deterministic rounding and posts balanced lines with trace fields.

### Loan-payment classifier (principal/interest split)

Loan-payment classification is available via `classify bank --loan-profiles <file>` and `classify loan-propose` / `classify loan-apply`. Profile-driven matching and split policy determine principal, interest, and optional fee amounts for deterministic proposal rows before posting.

### Planned enhancements

Further enhancements are tracked in repository feature-request tracking. Core classify/learn/template/suspense flows are available as first-class commands.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus journal --help
journal --help

# same as: bus journal -V
journal -V

# simple posting + balance check
journal add --date 2026-01-31 --desc "Bank fee" --debit 6570=12.50 --credit 1910=12.50
journal balance --as-of 2026-01-31
```


### Development state

**Value promise:** Append balanced ledger postings to the workspace journal so reports, VAT, and filing can consume a single, authoritative transaction stream.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — Record-postings and balance steps are journey-complete; init (index+schema only; period files on first add), add by code/name, balance, dry-run, and NFR-JRN-001 closed-period reject are test-verified.

**Use case readiness:**  
[Accounting workflow](../workflow/accounting-workflow-overview): 70% — record-postings and balance steps are usable, and init/add/balance/dry-run/NFR-JRN-001 are verified. [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): 70% — append path, balances, NFR-JRN-001, and audit columns in period CSV are verified. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 70% — posting path is ready for payroll export, including init/add/balance and closed-period rejection checks.

**Current:** `tests/e2e.sh` verifies help, version, global flags (color, format, chdir, output, quiet, `--`, `-vv`), init (index+schema only; period files on first add), idempotent and partial-init, dry-run init/add, add by code and name, balance (TSV, `--as-of`, `-o`, `-q`), NFR-JRN-001 (closed period via journal-closed-periods.csv and periods.csv), NFR-JRN-004 (self-referencing FK in accounts), and missing-required-flags exit 2. Unit tests in `internal/app/run_test.go`, `internal/app/init_test.go`, `internal/app/integration_test.go`, `internal/journal/period_test.go`, `internal/journal/validate_test.go`, `internal/journal/add_test.go`, `internal/cli/flags_test.go` cover flags, init, balance/add, period integrity, validation, and post args.

**Planned next:** Continued replay workflow hardening and profile-driven ingest improvements; add-from-stdin and bulk add are implemented.

**Blockers:** [bus-period](./bus-period) writing closed-period file so period integrity is enforceable in full workflow.

**Depends on:** [bus-accounts](./bus-accounts) (chart of accounts for `add`/`balance`); [bus-period](./bus-period) (period state for closed/lock reject). Paths and data via those modules' APIs; see [Module SDD](../sdd/bus-journal).

**Used by:** [bus-reports](./bus-reports), [bus-vat](./bus-vat), [bus-reconcile](./bus-reconcile), [bus-filing](./bus-filing) (read journal data).

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Module SDD: bus-journal](../sdd/bus-journal)
- [Layout: Journal area](../layout/journal-area)
- [Design: Double-entry ledger](../design-goals/double-entry-ledger)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)

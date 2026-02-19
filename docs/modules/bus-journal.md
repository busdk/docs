---
title: bus-journal — post and query ledger journal entries
description: bus journal maintains the authoritative ledger as append-only journal entries.
---

## `bus-journal` — post and query ledger journal entries

### Synopsis

`bus journal init [-C <dir>] [global flags]`  
`bus journal add --date <YYYY-MM-DD> [--desc <text>] [--source-id <key>] [--if-missing] --debit <account>=<amount> ... --credit <account>=<amount> ... [-C <dir>] [global flags]`  
`bus journal template post --template-file <path> --template <id> --date <YYYY-MM-DD> --gross <amount> [options] [-C <dir>] [global flags]`  
`bus journal template apply --template-file <path> [options] [-C <dir>] [global flags]`  
`bus journal balance --as-of <YYYY-MM-DD> [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus journal` maintains the authoritative ledger as append-only journal entries. It enforces balanced debits and credits and respects period close and lock boundaries. Account names in `--debit` and `--credit` must exist in the workspace [chart of accounts](../master-data/chart-of-accounts/index) (maintained by [bus accounts](./bus-accounts)); postings to closed or locked periods are rejected (period state is maintained by [bus period](./bus-period)). Other modules post into the journal; this CLI adds entries and reports balances.

### Commands

- `init` creates the journal index and baseline period datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` appends a balanced transaction (one or more debit and credit lines). Optional `--source-id <key>` records source identity; with `--if-missing`, add is a no-op when a posting with that source identity already exists (idempotent add).
- `template post` posts a single template-driven entry: predicate in the template file selects the rule; the template defines expense account, VAT rate, VAT account, and bank account; gross amount is split into base + VAT with deterministic rounding. Requires `--template-file <path>`, `--template <id>`, `--date <YYYY-MM-DD>`, and `--gross <amount>`.
- `template apply` applies templates in batch from a bank CSV (or equivalent): each row is matched to a template by predicate, then the same split and posting logic as `template post` is applied. Requires `--template-file <path>` and input (e.g. bank CSV path or stdin); see template file schema and bank-CSV column expectations below.
- `balance` prints account balances as of a given date.

### Options

`add` accepts `--date <YYYY-MM-DD>`, `--desc <text>`, and repeatable `--debit <account>=<amount>` and `--credit <account>=<amount>`. Optional `--source-id <key>` records source identity; `--if-missing` makes add idempotent (no-op when a posting with that source identity already exists). See [Idempotent posting and source keys](#idempotent-posting-and-source-keys) below. The `<account>` value is the account code or name as stored in the workspace chart of accounts; use quotes when the name contains spaces. At least one debit and one credit are required; total debits must equal total credits. Unknown or invalid account names cause the command to fail. `balance` accepts `--as-of <YYYY-MM-DD>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus journal --help`.

### Files

Every file owned by `bus journal` includes “journal” or “journals” in the filename. The journal index is `journals.csv` at the repository root; period journal files sit at the workspace root with a date prefix (e.g. `journal-2026.csv`, `journal-2025.csv`), each with a beside-the-table schema (e.g. `journal-2026.schema.json`). The journal index, its schema, and all period journal files live in the workspace root only; the module does not use a subdirectory for journal data. Path resolution for journal data is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)). When validating account names or period boundaries, the journal uses the workspace chart of accounts and period state from [bus accounts](./bus-accounts) and [bus period](./bus-period) respectively. The journal reads the accounts dataset using the same schema semantics as bus-accounts; valid optional schema features in `accounts.schema.json` (for example foreign keys, including self-referencing parent/child relationships) are accepted and must not cause the journal to fail or emit unsupported-schema diagnostics.

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

Posting templates with automatic VAT split are first-class. A template file defines one or more templates: each has an identifier, a predicate (e.g. match on counterparty, reference, or amount sign), and posting rule fields (expense account, VAT rate, VAT account, bank account). Predicate semantics: the first template whose predicate matches the current row (or the single gross amount for `template post`) is used; predicates are evaluated in file order. For `template post`, required flags are `--template-file <path>`, `--template <id>`, `--date <YYYY-MM-DD>`, and `--gross <amount>`. For `template apply`, the input is a bank CSV (or equivalent) whose columns must include the fields referenced by the predicates (e.g. counterparty, reference, amount, date); column names and expected types are defined by the template file schema. The module splits the gross amount into base + VAT by the configured rate, posts balanced lines with deterministic rounding and trace fields, and supports dry-run and optional link to the source bank row. Template file schema (YAML or JSON), predicate syntax, and bank-CSV column expectations are documented in the [module SDD](../sdd/bus-journal) and in the relevant workflow pages.

### Loan-payment classifier (principal/interest split)

A loan-payment classifier that splits bank payments into principal vs interest/fee is not yet implemented. [bus-loans](./bus-loans) provides loan register, schedule, postings, and amortize but does not classify arbitrary bank rows. When the [suggested capability](../sdd/bus-journal#suggested-capabilities-out-of-current-scope) is adopted (in bus-journal or via bus-loans integration), module docs will document the loan-profile schema, split policy, and proposal/apply flow.

### Planned enhancements

Rule-based bank classification and posting (classify + apply from bank transactions) and learning classifications from prior-year data are not yet first-class commands. See [Suggested capabilities](../sdd/bus-journal#suggested-capabilities-out-of-current-scope) in the module SDD for details.

### Development state

**Value promise:** Append balanced ledger postings to the workspace journal so reports, VAT, and filing can consume a single, authoritative transaction stream.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — Record-postings and balance steps are journey-complete; init (index+schema only; period files on first add), add by code/name, balance, dry-run, and NFR-JRN-001 closed-period reject are test-verified.

**Use case readiness:**  
- [Accounting workflow](../workflow/accounting-workflow-overview): 70% — Record-postings and balance steps usable; init, add, balance, dry-run, NFR-JRN-001 verified.  
- [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): 70% — Append path, balance, NFR-JRN-001 verified; audit columns in period CSV.  
- [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 70% — Posting path ready for payroll export; init, add, balance, closed-period reject verified.

**Current:** `tests/e2e_bus_journal.sh` verifies help, version, global flags (color, format, chdir, output, quiet, `--`, `-vv`), init (index+schema only; period files on first add), idempotent and partial-init, dry-run init/add, add by code and name, balance (TSV, `--as-of`, `-o`, `-q`), NFR-JRN-001 (closed period via journal-closed-periods.csv and periods.csv), NFR-JRN-004 (self-referencing FK in accounts), and missing-required-flags exit 2. Unit tests in `internal/app/run_test.go`, `internal/app/init_test.go`, `internal/app/integration_test.go`, `internal/journal/period_test.go`, `internal/journal/validate_test.go`, `internal/journal/add_test.go`, `internal/cli/flags_test.go` cover flags, init, balance/add, period integrity, validation, and post args.

**Planned next:** Optional add-from-stdin (PLAN.md) to advance [Accounting workflow](../workflow/accounting-workflow-overview); README/help alignment (init = index+schema only).

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

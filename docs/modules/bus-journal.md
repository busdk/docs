---
title: bus-journal — post and query ledger journal entries
description: bus journal maintains the authoritative ledger as append-only journal entries.
---

## `bus-journal` — post and query ledger journal entries

### Synopsis

`bus journal init [-C <dir>] [global flags]`  
`bus journal add --date <YYYY-MM-DD> [--desc <text>] --debit <account>=<amount> ... --credit <account>=<amount> ... [-C <dir>] [global flags]`  
`bus journal balance --as-of <YYYY-MM-DD> [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus journal` maintains the authoritative ledger as append-only journal entries. It enforces balanced debits and credits and respects period close and lock boundaries. Other modules post into the journal; this CLI adds entries and reports balances.

### Commands

- `init` creates the journal index and baseline period datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` appends a balanced transaction (one or more debit and credit lines).
- `balance` prints account balances as of a given date.

### Options

`add` accepts `--date <YYYY-MM-DD>`, `--desc <text>`, and repeatable `--debit <account>=<amount>` and `--credit <account>=<amount>`. At least one debit and one credit are required; total debits must equal total credits. `balance` accepts `--as-of <YYYY-MM-DD>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus journal --help`.

### Files

Every file owned by `bus journal` includes “journal” or “journals” in the filename. The journal index is `journals.csv` at the repository root; period journal files sit at the workspace root with a date prefix (e.g. `journal-2026.csv`, `journal-2025.csv`), each with a beside-the-table schema (e.g. `journal-2026.schema.json`). The journal index, its schema, and all period journal files live in the workspace root only; the module does not use a subdirectory for journal data.

### Exit status

`0` on success. Non-zero on invalid usage, unbalanced postings, or schema or period violations.

### Development state

**Value:** Append balanced ledger postings to the workspace journal so reports, VAT, and filing can consume a single, authoritative transaction stream for the [accounting workflow](../workflow/accounting-workflow-overview).

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview).

**Completeness:** 60% (Stable for one use case) — init, add, and balance verified by e2e; idempotent init and deterministic balance output test-backed.

**Use case readiness:** Accounting workflow: 60% — init, add, balance verified; period integrity (reject postings in closed periods) and audit-trail fields are missing for full close step.

**Current:** E2e script `tests/e2e_bus_journal.sh` proves help, version, invalid color/format and quiet+verbose, chdir, init creating transactions/lines CSV and schema, idempotent init, dry-run add (no new rows), add with debit/credit pairs, balance with exact TSV and --as-of, --output and --quiet. Unit tests in `internal/journal/add_test.go` and `internal/app/run_test.go` cover journal add, validate, atomic write, and app run.

**Planned next:** Period integrity (reject postings in closed periods); layout alignment; audit-trail fields; interactive add; account by name.

**Blockers:** bus-period closed-period checks needed for full workflow integrity.

**Depends on:** [bus-period](./bus-period) (period integrity: reject postings in closed periods).

**Used by:** [bus-reports](./bus-reports), [bus-vat](./bus-vat), [bus-reconcile](./bus-reconcile), and [bus-filing](./bus-filing) read journal data.

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


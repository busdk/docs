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

**Value promise:** Append balanced ledger postings to the workspace journal so reports, VAT, and filing can consume a single, authoritative transaction stream for the accounting workflow.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — init, add (by code and name), balance, NFR-JRN-001, layout and audit columns verified by e2e and unit tests; interactive add not verified.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 70% — init, add, balance, period integrity and layout/audit columns verified; interactive add not verified. [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): 70% — postings, balancing, period reject and audit columns verified. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 70% — append posting path verified; init, add, balance, closed-period reject verified.

**Current:** E2e `tests/e2e_bus_journal.sh` proves help, version, invalid color/format, quiet+verbose, chdir, init (journals.schema.json, journals.csv), idempotent init, dry-run add, add by code and by name (Cash/Sales→1000/3000), balance (TSV, --as-of, --output, --quiet), period CSV audit columns (entry_id, transaction_id, posting_date, account_id, entry_sequence, voucher_id), and NFR-JRN-001 (add to closed period exits 1 with deterministic stderr). Unit tests `internal/journal/period_test.go`, `internal/app/init_test.go`, `internal/app/run_test.go`, `internal/journal/validate_test.go`, `internal/journal/add_test.go`, and `internal/app/integration_test.go` cover period integrity, init, flags/output/chdir, validation and post, add args, and balance/add flows.

**Planned next:** PLAN.md lists no open items; optional interactive add for usability (would advance accounting workflow).

**Blockers:** [bus-period](./bus-period) writing closed-period file for full workflow.

**Depends on:** [bus-period](./bus-period) (closed-period file for period integrity).

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


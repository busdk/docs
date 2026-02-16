---
title: bus-bank — import and list bank transactions
description: bus bank normalizes bank statement data into schema-validated datasets and provides listing output used for reconciliation and posting workflows..
---

## `bus-bank` — import and list bank transactions

### Synopsis

`bus bank init [-C <dir>] [global flags]`  
`bus bank import --file <path> [-C <dir>] [global flags]`  
`bus bank list [--month <YYYY-M>] [--from <date>] [--to <date>] [--counterparty <id>] [--invoice-ref <ref>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus bank` normalizes bank statement data into schema-validated datasets and provides listing output used for reconciliation and posting workflows.

### Commands

- `init` creates the baseline bank datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `import` ingests a bank statement file into normalized datasets.
- `list` prints bank transactions with deterministic filtering.

### Options

`import` accepts `--file <path>`. `list` supports `--month`, `--from`, `--to`, `--counterparty`, and `--invoice-ref`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus bank --help`.

### Files

`bank-imports.csv` and `bank-transactions.csv` at the repository root with beside-the-table schemas. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `bank/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on errors, including invalid filters or schema violations.

### Development state

**Value promise:** Initialize bank transaction datasets and import normalized statement data so [bus-reconcile](./bus-reconcile) and the [accounting workflow](../workflow/accounting-workflow-overview) can match bank activity to invoices and journal entries.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 60% — init, import, and list are test-verified; user can complete the bank step (create datasets, import statement, list transactions) before reconcile.

**Use case readiness:** Accounting workflow: 60% — init and import verified by e2e; list with filters and TSV verified; user can complete bank step before reconcile. Finnish company reorganisation: 60% — import and list verified; basis for reconciliation evidence. Finnish payroll handling: 60% — import and list verified for pay-day statement flow.

**Current:** Verified by tests only. `tests/e2e_bus_bank.sh` proves help, version, invalid usage (quiet+verbose, color, format), init (four files at workspace root, idempotent warning, partial-state fail), import `--file` and `--dry-run`, list (deterministic TSV, `--month`, `-o`, `-q`, `-f tsv`), and global flags (`-C`, `--`, `-vv`, `--no-color`). `internal/app/run_test.go` and `internal/app/import_test.go` prove init/list/import and import dry-run. `internal/bank/datasets_test.go` proves init create/idempotent/partial and list filters (month, from/to, counterparty, invoice-ref) via `ApplyListFilters*`. `internal/bank/schema_test.go`, `internal/bank/output_test.go`, and `internal/cli/flags_test.go` cover schema, output formatting, and flag parsing.

**Planned next:** Schema validation before append on import (accounting workflow); add counterparty_id and filter `list --counterparty` by entity id (accounting workflow); link imports to attachments metadata; `--dry-run` for init.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-reconcile](./bus-reconcile) uses bank datasets for match and allocate.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reconcile">bus-reconcile</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Bank accounts](../master-data/bank-accounts/index)
- [Owns master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module SDD: bus-bank](../sdd/bus-bank)
- [Workflow context: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)


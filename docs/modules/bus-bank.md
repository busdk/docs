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

`bank-imports.csv` and `bank-transactions.csv` at the repository root with beside-the-table schemas. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `bank/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid filters or schema violations.

### Development state

**Value:** Initialize bank transaction datasets and import normalized statement data so [bus-reconcile](./bus-reconcile) and the [accounting workflow](../workflow/accounting-workflow-overview) can match bank activity to invoices and journal entries.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview).

**Completeness:** 60% (Stable for one use case) — init, import, and list verified by e2e; idempotent init and list output shape test-backed.

**Use case readiness:** Accounting workflow: 60% — init and import verified; schema validation before append and counterparty_id would complete bank step before reconcile.

**Current:** E2e script `tests/e2e_bus_bank.sh` proves help, version, invalid quiet+verbose and color and format, init creating bank-imports and bank-transactions CSV and schema at workspace root, idempotent init warning, import --file appending from raw CSV with schema, and list with deterministic TSV. Unit tests in `internal/app/run_test.go` and `internal/bank/` cover app run, import, schema, validate, and output.

**Planned next:** Schema validation before append; counterparty_id and filter; link imports to attachments; --dry-run for init.

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


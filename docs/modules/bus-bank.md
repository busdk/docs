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

The first-class ERP history import workflow for bank data is profile-driven in design but not yet implemented in current module releases. Today, ERP-to-canonical bank ingestion is performed through generated explicit append scripts in migration repositories.

### Commands

- `init` creates the baseline bank datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `import` ingests a bank statement file into normalized datasets.
- `list` prints bank transactions with deterministic filtering.

### Options

`import` accepts `--file <path>`. `list` supports `--month`, `--from`, `--to`, `--counterparty`, and `--invoice-ref`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus bank --help`.

### ERP history import (planned)

The planned first-class import workflow is a short command invocation that references a versioned mapping profile and source export data, for example `bus bank import --profile imports/profiles/erp-bank-2024.yaml --source exports/erp/bank-2024.tsv --year 2024`. The profile owns deterministic mapping rules such as year filtering, transaction direction normalization, status mapping, and counterparty/reference lookup into canonical identifiers.

This command surface is not yet available in the current release. The current migration path remains generated explicit append scripts (for example `exports/2024/018-erp-bank-2024.sh`) built from ERP TSV mappings. Those scripts remain deterministic and auditable, but they are large and one-off compared with the planned reusable profile workflow.

### Reconciliation proposal flow (planned integration)

Deterministic reconciliation proposal generation in [bus-reconcile](./bus-reconcile) depends on stable bank transaction identity and normalized read fields from this module. The planned two-phase reconciliation flow uses bank transaction ID, amount, currency, booking date, and reference fields as deterministic proposal inputs, and then applies approved proposal rows in batch.

In this workspace, candidate planning for reconciliation is currently script-based (`exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`) while the first-class `bus reconcile propose/apply` workflow is not yet shipped.

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

**Planned next:** Add first-class profile-driven ERP bank import so historical ERP exports can be mapped into canonical bank datasets without generated mega-scripts; keep schema validation before append, counterparty_id/list filter alignment, import-to-attachments links, and `--dry-run` for init. Maintain deterministic transaction ID and read-field contract required by planned `bus reconcile propose/apply`.

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
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)


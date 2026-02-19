---
title: bus-bank — import and list bank transactions
description: bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows.
---

## `bus-bank` — import and list bank transactions

### Synopsis

`bus bank init [-C <dir>] [global flags]`  
`bus bank import --file <path> [-C <dir>] [global flags]`  
`bus bank import --profile <path> --source <path> [--year <YYYY>] [-C <dir>] [global flags]`  
`bus bank config [<subcommand>] [options] [-C <dir>] [global flags]`  
`bus bank list [--month <YYYY-M>] [--from <date>] [--to <date>] [--counterparty <id>] [--invoice-ref <ref>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus bank backlog [--month <YYYY-M>] [--from <date>] [--to <date>] [--detail] [--fail-on-backlog] [--max-unposted <n>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus bank` normalizes bank statement data into schema-validated datasets and provides listing output used for reconciliation and posting workflows. Ingest supports both single-statement files (`--file`) and profile-driven ERP import (`--profile --source`, optional `--year`), with deterministic artifacts verified by tests.

### Commands

- `init` creates the baseline bank datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `import` ingests a bank statement file (e.g. `--file <path>`) or runs profile-driven ERP import (`--profile <path> --source <path>`, optional `--year`) into normalized datasets.
- `config` manages counterparty normalization and reference extractors. Use `config counterparty add` to add canonical names and alias patterns, and `config extractors add` to add extractor patterns (e.g. regex) so bank message/reference fields yield normalized reference hints. When configured, `list` output includes normalized counterparty and extracted reference-hint columns.
- `list` prints bank transactions with deterministic filtering. When counterparty and extractor config are present, output includes normalized counterparty and extracted reference-hint columns (e.g. `erp_id`, `invoice_number_hint`).
- `backlog` reports posted versus unposted bank transactions for classification coverage. It reads bank transactions and reconciliation matches and supports detail and CI-friendly failure thresholds.

### Options

`import` accepts `--file <path>` for statement files, or `--profile <path> --source <path>` with optional `--year` for profile-driven ERP import. `list` supports `--month`, `--from`, `--to`, `--counterparty`, and `--invoice-ref`. `backlog` supports `--month`, `--from`, `--to`, `--detail`, `--fail-on-backlog`, and `--max-unposted <n>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus bank --help`.

### Profile-driven ERP history import

Profile-driven import is available: `bus bank import --profile <path> --source <path> [--year <YYYY>]` runs deterministic mapping from ERP export data into canonical bank datasets. The profile defines column mappings, direction normalization, and optional year filtering. Each run emits auditable plan and result artifacts; re-runs with the same profile and source yield byte-identical artifacts. Supported by e2e and unit tests (`tests/e2e_bus_bank.sh`, `internal/bank/profile_import_test.go`). See [Import ERP history into canonical invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets).

### Reconciliation proposal flow

Deterministic reconciliation proposal generation in [bus-reconcile](./bus-reconcile) depends on stable bank transaction identity and normalized read fields from this module. The two-phase flow uses bank transaction ID, amount, currency, booking date, and reference fields as deterministic proposal inputs; when counterparty and extractor config are configured, normalized counterparty and extracted reference hints (e.g. `erp_id`, `invoice_number_hint`) are available for match-by-reference in bus-reconcile. Script-based candidate workflows (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remain an alternative. The built-in `backlog` command provides classification coverage (posted vs unposted) for review and CI gates.

### Files

`bank-imports.csv` and `bank-transactions.csv` at the repository root with beside-the-table schemas. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `bank/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus bank init
bus bank import --file ./imports/bank/january-2026.csv
```

### Exit status

`0` on success. Non-zero on errors, including invalid filters or schema violations.

### Development state

**Value promise:** Initialize bank transaction datasets and import normalized statement data (file or profile-driven ERP) so [bus-reconcile](./bus-reconcile) and the [accounting workflow](../workflow/accounting-workflow-overview) can match bank activity to invoices and journal entries.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Import ERP history into canonical datasets](../workflow/import-erp-history-into-canonical-datasets), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — init, file and profile import, and list verified by e2e; user can complete bank ingest step including ERP history via profile.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 70% — init, file and profile import, list verified; user can complete bank step before reconcile. [Import ERP history](../workflow/import-erp-history-into-canonical-datasets): 70% — profile import with `--year`, dry-run, and byte-identical artifacts verified by e2e. [Finnish company reorganisation — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack): 70% — import and list verified; basis for reconciliation evidence. [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run): 70% — import and list verified for pay-day statement flow.

**Current:** `tests/e2e_bus_bank.sh` verifies help, version, invalid usage (quiet+verbose, color, format), init (four files at workspace root, idempotent warning, partial-state fail, `--dry-run`), import `--file` (schema validation, invalid currency fails, `--dry-run`), import `--profile --source` (plan/result artifacts, byte-identical re-run, `--dry-run`, `--year` filter, profile-without-source usage error), list (deterministic TSV, `--month`, `--counterparty`, `-o`, `-q`, `-f tsv`), backlog (`--detail`, TSV/JSON, `--fail-on-backlog`, `--max-unposted`), config counterparty add, config extractors add, and global flags (`-C`, `--`, `-vv`, `--no-color`). `internal/app/run_test.go` and `internal/app/import_test.go` verify init/list/import and import dry-run. `internal/bank/datasets_test.go` verifies init create/idempotent/partial and list filters (month, from/to, counterparty, invoice-ref). `internal/bank/profile_import_test.go` and `internal/bank/profile_test.go` verify profile import deterministic artifacts, year filter, dry-run no writes, and required source columns. `internal/bank/schema_test.go`, `internal/bank/output_test.go`, and `internal/cli/flags_test.go` cover schema, output formatting, and flag parsing. `path/path_test.go` verifies workspace-relative path accessors for bank datasets.

**Planned next:** None in PLAN.md; optional: help/synopsis alignment for profile and `--year` flags.

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

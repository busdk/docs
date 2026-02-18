---
title: bus-reconcile
description: bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.
---

## `bus-reconcile` — match bank transactions to invoices or journal entries

### Synopsis

`bus reconcile match --bank-id <id> (--invoice-id <id> | --journal-id <id>) [-C <dir>] [global flags]`  
`bus reconcile allocate --bank-id <id> [--invoice <id>=<amount>] ... [--journal <id>=<amount>] ... [-C <dir>] [global flags]`  
`bus reconcile list [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reconcile` links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. Reconciliation records are schema-validated and append-only. Use after importing bank data with `bus bank`.

The first-class two-phase reconciliation workflow (proposal generation plus batch apply) is planned but not yet implemented in current module releases. In this workspace, deterministic candidate planning is currently handled by custom scripts.

Planned proposal and apply outputs are also intended to feed migration parity and gap checks in [bus-validate](./bus-validate) and [bus-reports](./bus-reports), so reconciliation artifact fields remain deterministic and machine-readable.

### Commands

- `match` records a one-to-one link between a bank transaction and an invoice or journal transaction (amounts must match exactly).
- `allocate` records allocations for a bank transaction split across multiple invoices or journal entries (allocations must sum to the bank amount).
- `list` lists reconciliation records.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. `allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reconcile --help`.

### Deterministic proposals and batch apply (planned)

The planned command flow adds an explicit two-phase surface where proposal generation is separated from write operations. `bus reconcile propose --out <path>|-` generates deterministic reconciliation proposal rows with confidence and reason fields, and `bus reconcile apply --in <path>|-` consumes approved proposal rows and records canonical match or allocation writes deterministically, with `--dry-run` and idempotent re-apply semantics.

This command surface is not yet available in the current release. Current deterministic candidate workflows use scripts such as `exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Exit status

`0` on success. Non-zero on invalid usage or when amounts or references are invalid.

### Development state

**Value promise:** Link bank transactions to invoices or journal entries so the accounting workflow can reconcile bank activity and keep an explicit reconciliation history.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 60% — core match/allocate/list exists, but first-class proposal generation and batch apply are not yet implemented.

**Use case readiness:** Accounting workflow: 60% — manual reconciliation is available through match/allocate/list, but deterministic proposal/apply command flow is missing. Finnish company reorganisation: 60% — reconciliation evidence path is available, but candidate planning remains script-based. Finnish payroll handling: 60% — payroll bank reconciliation works with match/allocate, without first-class proposal/apply commands.

**Current:** Match (invoice and journal), allocate (invoice-only and mixed invoice+journal), list (including empty and bootstrap when matches.csv missing), and validation failures (amount/currency mismatch, sum mismatch, already reconciled, missing invoice/journal ref) are verified by `internal/app/run_test.go` and `tests/e2e_bus_reconcile.sh`. Invoice, journal, and bank dataset paths from [bus-invoices](./bus-invoices), [bus-journal](./bus-journal), and [bus-bank](./bus-bank) path accessors (workspace-relative) are verified by `internal/invoicepath/path_test.go`, `internal/journalpath/path_test.go`, `internal/bankpath/path_test.go`, and `tests/e2e_bus_reconcile.sh`. Global flags (help, version, quiet, verbose, color, format, output, chdir, `--`), quiet+verbose conflict, and flag parsing are verified by `internal/cli/flags_test.go` and `internal/app/run_test.go`. When a valid `matches` dataset exists, `match` works as expected; deterministic candidate planning still uses custom scripts (`exports/2024/025-reconcile-sales-candidates-2024.sh`, prepared `exports/2024/024-reconcile-sales-exact-2024.sh`) until first-class propose/apply are available.

**Planned next:** Add first-class `propose` and `apply` commands for deterministic candidate generation and batch apply, including confidence/reason reporting, `--dry-run`, and idempotent re-apply semantics. Keep canceled-invoice rejection in match and bank path resolution via [bus-bank](./bus-bank) Go library per data path contract. Keep proposal/apply artifact fields stable for downstream parity and gap checks in [bus-validate](./bus-validate) and [bus-reports](./bus-reports).

**Blockers:** None known. First-class propose/apply are not yet implemented.

**Depends on:** [bus-bank](./bus-bank), [bus-invoices](./bus-invoices), [bus-journal](./bus-journal).

**Used by:** End users for reconciliation; no other module invokes it.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bank">bus-bank</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-assets">bus-assets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-reconcile](../sdd/bus-reconcile)
- [Workflow: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)


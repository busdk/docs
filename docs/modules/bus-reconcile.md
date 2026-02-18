---
title: bus-reconcile
description: bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.
---

## `bus-reconcile` — match bank transactions to invoices or journal entries

### Synopsis

`bus reconcile match --bank-id <id> (--invoice-id <id> | --journal-id <id>) [-C <dir>] [global flags]`  
`bus reconcile allocate --bank-id <id> [--invoice <id>=<amount>] ... [--journal <id>=<amount>] ... [-C <dir>] [global flags]`  
`bus reconcile list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus reconcile propose --out <path>|- [options] [-C <dir>] [global flags]`  
`bus reconcile apply --in <path>|- [--dry-run] [options] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reconcile` links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. Reconciliation records are schema-validated and append-only. Use after importing bank data with `bus bank`.

The first-class two-phase reconciliation workflow is implemented: `bus reconcile propose` and `bus reconcile apply` (with `--dry-run` and idempotent re-apply) provide proposal generation and batch apply; `match`, `allocate`, and `list` remain for one-off use. Proposal and apply outputs feed migration parity and gap checks in [bus-validate](./bus-validate) and [bus-reports](./bus-reports).

### Commands

- `match` records a one-to-one link between a bank transaction and an invoice or journal transaction (amounts must match exactly).
- `allocate` records allocations for a bank transaction split across multiple invoices or journal entries (allocations must sum to the bank amount).
- `list` lists reconciliation records.
- `propose` generates deterministic reconciliation proposal rows from unreconciled bank and invoice/journal data; output includes confidence and reason fields.
- `apply` consumes approved proposal rows and records match or allocation writes deterministically; supports `--dry-run` and idempotent re-apply.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. `allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reconcile --help`.

### Deterministic proposals and batch apply

`bus reconcile propose --out <path>|-` generates deterministic reconciliation proposal rows with confidence and reason fields. `bus reconcile apply --in <path>|-` consumes approved proposal rows and records canonical match or allocation writes deterministically, with `--dry-run` and idempotent re-apply semantics. Script-based candidate workflows (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remain an alternative.

Exit codes and optional CI flags are not yet fully specified. Scripts that need to fail on backlog or incomplete apply may need to parse proposal or apply output. An optional extension is thresholds or strict exit codes for "no proposals" vs "partial apply"; when adopted, exit codes and optional CI flags will be documented in this module reference and the [module SDD](../sdd/bus-reconcile).

### Match by extracted reference keys

Propose and match currently use amount and reference only; there is no first-class use of bank-side extracted keys. This capability depends on [bus-bank](./bus-bank) [reference extractors](../sdd/bus-bank#suggested-capabilities-out-of-current-scope): when bus-bank exposes normalized reference fields (e.g. `erp_id`, `invoice_number_hint`) in bank list and export, bus-reconcile would use them in propose and match when joining to invoice or purchase-invoice ids. Expected field names and matching semantics would be documented in the SDD and this module; amount and currency checks would be retained; an optional "match by extracted key" path would improve match quality and reduce manual pairing. See the [module SDD](../sdd/bus-reconcile) for the suggested extension and input-contract change.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Exit status

`0` on success. Non-zero on invalid usage or when amounts or references are invalid. A strict exit-code contract for propose (e.g. "no proposals" vs "proposals generated") and apply (e.g. "partial apply" vs "all applied") is not yet specified; see [Deterministic proposals and batch apply](#deterministic-proposals-and-batch-apply) for the optional CI-friendly extension.

### Development state

**Value promise:** Link bank transactions to invoices or journal entries so the accounting workflow can reconcile bank activity and keep an explicit reconciliation history.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** Largely complete — match, allocate, list, propose, and apply (with dry-run and idempotent re-apply) are implemented; optional CI-friendly exit codes are not yet specified.

**Use case readiness:** Accounting workflow: propose and apply provide the two-phase flow; optional CI exit codes for backlog or partial apply are not yet documented. Finnish company reorganisation: reconciliation evidence path and propose/apply are available. Finnish payroll handling: payroll bank reconciliation works with match/allocate and propose/apply.

**Current:** Match (invoice and journal), allocate (invoice-only and mixed invoice+journal), list (including empty and bootstrap when matches.csv missing), and validation failures (amount/currency mismatch, sum mismatch, already reconciled, missing invoice/journal ref) are verified by `internal/app/run_test.go` and `tests/e2e_bus_reconcile.sh`. Invoice, journal, and bank dataset paths from [bus-invoices](./bus-invoices), [bus-journal](./bus-journal), and [bus-bank](./bus-bank) path accessors (workspace-relative) are verified by `internal/invoicepath/path_test.go`, `internal/journalpath/path_test.go`, `internal/bankpath/path_test.go`, and `tests/e2e_bus_reconcile.sh`. Global flags (help, version, quiet, verbose, color, format, output, chdir, `--`), quiet+verbose conflict, and flag parsing are verified by `internal/cli/flags_test.go` and `internal/app/run_test.go`. When a valid `matches` dataset exists, `match` works as expected; deterministic candidate planning still uses custom scripts (`exports/2024/025-reconcile-sales-candidates-2024.sh`, prepared `exports/2024/024-reconcile-sales-exact-2024.sh`) until first-class propose/apply are available.

**Planned next:** Optional CI-friendly behavior: thresholds or strict exit codes for "no proposals" vs "partial apply" so scripts can fail on backlog or incomplete apply without custom output parsing; document exit codes and optional CI flags when adopted.

**Blockers:** None known.

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


---
title: bus-reconcile
description: bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.
---

## `bus-reconcile` — match bank transactions to invoices or journal entries

### Synopsis

`bus reconcile match --bank-id <id> (--invoice-id <id> | --journal-id <id>) [-C <dir>] [global flags]`  
`bus reconcile allocate --bank-id <id> [--invoice <id>=<amount>] ... [--journal <id>=<amount>] ... [-C <dir>] [global flags]`  
`bus reconcile list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus reconcile init [--if-missing] [--force] [-C <dir>] [global flags]`  
`bus reconcile propose [options] [-C <dir>] [global flags]`  
`bus reconcile apply --in <path>|- [--dry-run] [options] [-C <dir>] [global flags]`
`bus reconcile post --kind invoice_payment --bank-account <id> --sales-account <id> --sales-vat-account <id> [--purchase-account <id> --purchase-vat-account <id>] [--if-missing] [--dry-run] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reconcile` links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. Reconciliation records are schema-validated and append-only. Use after importing bank data with `bus bank`.

The first-class two-phase reconciliation workflow is implemented: `bus reconcile propose` and `bus reconcile apply` (with `--dry-run` and idempotent re-apply) provide proposal generation and batch apply; `match`, `allocate`, and `list` remain for one-off use. Proposal and apply outputs feed migration parity and gap checks in [bus-validate](./bus-validate) and [bus-reports](./bus-reports). `bus reconcile post` adds deterministic journal posting from existing invoice-payment matches.

### Commands

- `match` records a one-to-one link between a bank transaction and an invoice or journal transaction (amounts must match exactly).
- `allocate` records allocations for a bank transaction split across multiple invoices or journal entries (allocations must sum to the bank amount).
- `list` lists reconciliation records.
- `init` bootstraps `matches.csv` and `matches.schema.json` at workspace root with deterministic defaults. Output is machine-readable TSV (`path`, `status`) and supports idempotent rerun (`unchanged`) or forced rewrite (`--force` -> `updated`).
- `propose` generates deterministic reconciliation proposal rows from unreconciled bank and invoice/journal data; output includes confidence and reason fields.
- `apply` consumes approved proposal rows and records match or allocation writes deterministically; supports `--dry-run` and idempotent re-apply. Incoming-mode proposals may include `target_kind=unmatched` no-op rows for deterministic backlog classification.
- `post` converts existing `invoice_payment` match rows to journal postings using invoice evidence (net + VAT). Sales postings are debit bank / credit sales / credit VAT; purchase postings are debit purchase / debit VAT / credit bank. Idempotency uses voucher id `bank:<bank_txn_id>` and `--if-missing` can skip already-posted vouchers.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. `allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. `propose` supports `--incoming` with deterministic keyword mapping flags (`--transfer-keywords`, `--owner-loan-keywords`, `--owner-investment-keywords`) and unresolved backlog output (`--unresolved-out <path>`), suspense fallback flags `--suspense-account <account> --suspense-reason <text>` for unresolved rows, suspense reclassification proposal mode `--suspense-reclass-account <account>` with optional selectors (`--bank-id`, `--from-date`, `--to-date`, `--counterparty`, `--reference`, `--amount`), and settlement evidence modes `--settlement-csv <file>` and provider-agnostic `--settlement-in <path> [--settlement-profile <json>] [--fail-on-ambiguity]`. `apply` supports settlement posting mode via `--settlement` plus posting accounts (`--bank-account`, `--sales-account`, `--vat-account`, `--fee-account`). Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reconcile --help`.

### Deterministic proposals and batch apply

`bus reconcile propose` generates deterministic reconciliation proposal rows with confidence and reason fields. `bus reconcile apply --in <path>|-` consumes approved proposal rows and records canonical match or allocation writes deterministically, with `--dry-run` and idempotent re-apply semantics. Use `--fail-if-empty` so that propose exits non-zero when no proposals are generated; this supports CI workflows that must fail on backlog or incomplete apply.

Incoming backlog classifier mode is available through propose/apply: `propose --incoming` can classify incoming rows as internal-transfer no-op pairs (`incoming_internal_transfer_paired` / one-sided no-op), owner investment, or owner loan using configurable keyword maps. Unclassified incoming rows can be exported to a deterministic backlog TSV via `--unresolved-out`. Applying these proposals writes `kind=unmatched` rows in `matches.csv` and is idempotent on re-apply.

Suspense fallback mode is available through propose/apply: `propose --suspense-account <account> --suspense-reason <text>` emits deterministic unmatched fallback rows for still-unresolved bank transactions (`target_id=suspense:<account>`). Applying these rows stores the classification target in `matches.csv` (`entry_id`) so replay traces remain explicit and idempotent.

Suspense reclassification mode is available through propose/apply: `propose --suspense-reclass-account <account>` emits deterministic candidate rows for existing suspense-classified unmatched matches; reviewers update approved proposal rows with final `target_id` values and apply them. Re-apply is idempotent by `(bank_txn_id, target_id)` and reports deterministic skipped status.

Settlement evidence mode is available through propose/apply: `propose --settlement-csv <file>` ingests structured settlement rows and emits deterministic payout proposals with explicit totals (`gross`, `base`, `vat`, `fee`, `net`) and source identifiers (`source_id`, optional `bank_row_id`). Provider-agnostic mode `propose --settlement-in <path> [--settlement-profile <json>]` ingests file or folder inputs (csv/tsv directly; pdf/xls/xlsx via sidecar csv/tsv), normalizes them to the same settlement row contract, and emits deterministic ingest diagnostics (`parsed_rows`, `normalized_rows`, `recovered_rows`, `ambiguous_rows`, `dropped_rows`); `--fail-on-ambiguity` makes ambiguous parse rows a hard failure. `apply --settlement` consumes those proposal rows and writes deterministic balanced journal postings (`Dr bank net`, `Dr fee`, `Cr sales`, `Cr VAT`), with dry-run reporting and idempotent re-apply by voucher reference.

Output from propose (or apply result sets) must be redirected using the **global** `--output` flag before the subcommand: for example `bus reconcile -o proposals.tsv propose` or `bus reconcile -o applied.tsv apply --in approved.tsv`. Placing `-o` after the subcommand is invalid. Script-based candidate workflows (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remain an alternative.

Exit semantics: success (0) when proposals are generated or apply completes; non-zero when usage is invalid, when `--fail-if-empty` is set and no proposals exist or input is empty, or when apply encounters errors. Runtime path or year resolution may still fail in some workspaces (e.g. missing or inconsistent period data); diagnostics identify the failure.

### Match by extracted reference keys

When [bus-bank](./bus-bank) is configured with counterparty and reference extractors, bank list output includes normalized reference fields such as `erp_id` and `invoice_number_hint`. Propose and match can use these extracted keys to join to invoice or purchase-invoice identifiers. Extracted-key semantics: `erp_id` aligns with ERP/internal identifiers; `invoice_number_hint` aligns with human or system invoice numbers. When both an amount match and an extracted-key match are available, precedence is implementation-defined (e.g. amount match first, then extracted key as tie-breaker or secondary path). Match-by-key behavior improves proposal quality and reduces manual pairing while retaining amount and currency checks. See the [module SDD](../sdd/bus-reconcile) for the full input contract.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Examples

```bash
bus reconcile list
bus reconcile -o ./tmp/reconcile-proposals.tsv propose
bus reconcile apply --in ./tmp/reconcile-proposals.tsv --dry-run
bus reconcile post --kind invoice_payment --bank-account 1910 --sales-account 3000 --sales-vat-account 2931 --if-missing
```

### Exit status

`0` on success. Non-zero on invalid usage, when amounts or references are invalid, when `--fail-if-empty` is set and propose yields no proposals, or when posting/apply validation fails. See [Deterministic proposals and batch apply](#deterministic-proposals-and-batch-apply) for CI flag behavior.

### Development state

**Value promise:** Link bank transactions to invoices or journal entries so the accounting workflow can reconcile bank activity and keep an explicit reconciliation history.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** Largely complete — match, allocate, list, propose, apply, and post are implemented; optional coverage extensions remain.

**Use case readiness:** Accounting workflow: propose and apply provide the two-phase flow; optional CI exit codes for backlog or partial apply are not yet documented. Finnish company reorganisation: reconciliation evidence path and propose/apply are available. Finnish payroll handling: payroll bank reconciliation works with match/allocate and propose/apply.

**Current:** Match (invoice and journal), allocate (invoice-only and mixed invoice+journal), list (including empty and bootstrap when matches.csv missing), propose, apply, and post (`invoice_payment` to journal VAT split with idempotent voucher checks) are verified by tests. Global flags (help, version, quiet, verbose, color, format, output, chdir, `--`) and path accessors are verified. Propose/apply/post are first-class; script-based candidate workflows remain optional.

**Planned next:** None in PLAN.md; propose/apply with `--fail-if-empty` and global `-o` are documented.

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
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)

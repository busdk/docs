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

Command names follow [CLI command naming](../cli/command-naming).

`bus reconcile` links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.
Reconciliation records are schema-validated and append-only.

Use `propose` + `apply` for the standard two-phase flow.
Use `match`, `allocate`, and `list` for one-off operations.
Use `post` to create deterministic journal postings from invoice-payment matches.

### Commands

`match` records one-to-one links between bank transactions and invoice or journal transactions, with exact amount matching. `allocate` records split allocations across multiple invoices or journal entries, and allocations must sum to the bank amount. `list` prints reconciliation records.
When bank extracted keys (`erp_id`, `invoice_number_hint`) prove a prior-year invoice identity that is not present in the current workspace invoice datasets, `match` and `allocate` can still use that historical invoice reference without requiring a duplicate import.

`init` bootstraps `matches.csv` and `matches.schema.json` at workspace root with deterministic defaults. New workspaces get `matches.csv` in shared `PCSV-1` storage by default, while older plain-CSV workspaces continue to work unchanged. Output is machine-readable TSV (`path`, `status`) and supports idempotent reruns (`unchanged`) or forced rewrite (`--force` returns `updated`).

`propose` generates deterministic proposal rows from unreconciled bank and invoice/journal data and includes confidence and reason fields. `apply` consumes approved proposals and writes matches or allocations deterministically, with `--dry-run` and idempotent re-apply behavior. Incoming-mode proposals can include `target_kind=unmatched` no-op rows for deterministic backlog classification.

`post` converts `invoice_payment` match rows to journal postings using invoice evidence (net plus VAT). Sales postings are debit bank, credit sales, and credit VAT. Purchase postings are debit purchase, debit VAT, and credit bank. Idempotency uses voucher id `bank:<bank_txn_id>`, and `--if-missing` skips already-posted vouchers.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`.
`allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. Invoice allocations are positive; journal allocations may be signed (non-zero) so net-settlement payouts can include fee adjustments while preserving exact bank-amount reconciliation.

`propose` supports incoming classification, suspense fallback/reclassification, settlement evidence modes, and explicit historical invoice-reference proposals via `--target-kind historical_invoice_payment`.
`apply` supports settlement posting mode, historical invoice-reference rows, and posting account flags.

For full option matrix and detailed semantics, see [Module reference: bus-reconcile](../modules/bus-reconcile).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reconcile --help`.

### Deterministic proposals and batch apply

`bus reconcile propose` generates deterministic reconciliation proposal rows with confidence and reason fields. `bus reconcile apply --in <path>|-` consumes approved proposal rows and records canonical match or allocation writes deterministically, with `--dry-run` and idempotent re-apply semantics. Use `--fail-if-empty` so that propose exits non-zero when no proposals are generated; this supports CI workflows that must fail on backlog or incomplete apply.

Incoming backlog classifier mode is available through propose/apply.
`propose --incoming` can classify rows as internal transfer, owner investment, or owner loan by configurable keywords.
Unclassified incoming rows can be exported via `--unresolved-out`.

Suspense fallback mode is available through propose/apply.
`propose --suspense-account <account> --suspense-reason <text>` emits deterministic fallback rows for unresolved transactions.

Suspense reclassification mode is also available through propose/apply using `--suspense-reclass-account <account>`.
Reviewers can approve edited proposal rows and apply them idempotently.

Settlement evidence mode is available through propose/apply.
`propose --settlement-csv <file>` and `propose --settlement-in <path>` normalize settlement inputs to deterministic proposal rows.
`apply --settlement` writes deterministic balanced journal postings with idempotent re-apply. Those settlement-applied journal vouchers are designed to be consumable by `bus vat --source reconcile --basis cash` coverage.

Historical invoice-reference mode is also available through propose/apply.
Use `propose --target-kind historical_invoice_payment --match-by-reference` when exact bank-side invoice evidence proves a prior-year invoice identity that is absent from current invoice datasets and reviewers want an explicit proposal artifact before apply. That evidence may come from `erp_id`, `invoice_number_hint`, or an exact bank `reference`. When no current invoice row exists and reviewers already know the prior-year invoice id, `apply` can also persist that reviewed label directly in a `historical_invoice_payment` row as long as the bank transaction still carries that exact invoice evidence.

Output from propose (or apply result sets) must be redirected using the **global** `--output` flag before the subcommand: for example `bus reconcile -o proposals.tsv propose` or `bus reconcile -o applied.tsv apply --in approved.tsv`. Placing `-o` after the subcommand is invalid. Script-based candidate workflows (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remain an alternative.

Exit semantics: success (0) when proposals are generated or apply completes; non-zero when usage is invalid, when `--fail-if-empty` is set and no proposals exist or input is empty, or when apply encounters errors. Runtime path or year resolution may still fail in some workspaces (e.g. missing or inconsistent period data); diagnostics identify the failure.

### Match by extracted reference keys

When [bus-bank](./bus-bank) is configured with counterparty and reference extractors, bank list output includes normalized reference fields such as `erp_id` and `invoice_number_hint`. Propose, match, and allocate can use these extracted keys to join to invoice or purchase-invoice identifiers. Exact-reference semantics: `erp_id` aligns with ERP/internal identifiers, `invoice_number_hint` aligns with human or system invoice numbers, and the plain bank `reference` remains available as an exact fallback for prior-year receivable receipts when the current workspace no longer contains the invoice row. Amount and currency checks always remain strict. When the current workspace does not contain the prior-year invoice row but exact bank invoice evidence proves identity, reviewers can request `--target-kind historical_invoice_payment` to produce an explicit proposal artifact instead of silently falling back. If the exact key itself is not the desired audit label, apply can preserve a reviewer-supplied prior-year invoice id in the historical row as long as no current-workspace invoice reference matches the bank evidence. See the [module reference](../modules/bus-reconcile) for the full input contract.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Examples

```bash
bus reconcile list
bus reconcile -o ./tmp/reconcile-proposals.tsv propose
bus reconcile apply --in ./tmp/reconcile-proposals.tsv --dry-run
bus reconcile propose --incoming --unresolved-out ./tmp/reconcile-unresolved.tsv
bus reconcile propose --suspense-account 2999 --suspense-reason "needs review"
bus reconcile post --kind invoice_payment --bank-account 1910 --sales-account 3000 --sales-vat-account 2931 --if-missing
```

### Exit status

`0` on success. Non-zero on invalid usage, when amounts or references are invalid, when `--fail-if-empty` is set and propose yields no proposals, or when posting/apply validation fails. See [Deterministic proposals and batch apply](#deterministic-proposals-and-batch-apply) for CI flag behavior.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus reconcile propose --incoming --unresolved-out ./tmp/reconcile-unresolved.tsv
reconcile propose --incoming --unresolved-out ./tmp/reconcile-unresolved.tsv

# same as: bus reconcile apply --in ./tmp/reconcile-approved.tsv --dry-run
reconcile apply --in ./tmp/reconcile-approved.tsv --dry-run

# same as: bus reconcile post --kind invoice_payment --bank-account 1910 --sales-account 3000 --sales-vat-account 2931 --if-missing
reconcile post --kind invoice_payment --bank-account 1910 --sales-account 3000 --sales-vat-account 2931 --if-missing
```

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
- [Module reference: bus-reconcile](../modules/bus-reconcile)
- [Workflow: Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)

---
title: bus-reconcile
description: bus reconcile matches bank transactions to invoices or journal entries, supports batch proposal workflows, and can turn approved invoice payments into journal postings.
---

## `bus-reconcile` — match bank transactions to invoices or journal entries

`bus reconcile` sits between imported bank data and posted accounting. Use it when you want to tell BusDK which bank row paid which invoice, which bank row belongs to which journal entry, or which rows still need a reviewed proposal.

For most teams there are two normal ways to use this module. The first is manual matching for one-off rows. The second is the proposal flow: generate candidate matches, review them, and then apply them in batch.

### Common workflows

Create the reconciliation dataset the first time:

```bash
bus reconcile init
```

Match one bank payment directly to one invoice:

```bash
bus reconcile match --bank-id bank:2026-01-001 --invoice-id INV-2026-1001
```

If the bank row keeps a stable source identity such as `bank_row:24887`, you can use that
instead of the canonical `bank_txn_id`. With the default shorthand mapping `b -> bank_row`,
this also works:

```bash
bus reconcile match --bank-id b24887 --invoice-id INV-2026-1001
```

Split one bank row between an invoice payment and a journal fee entry:

```bash
bus reconcile allocate \
  --bank-id bank:2026-01-045 \
  --invoice INV-2026-1044=120.00 \
  --journal fee-2026-01-31=4.90
```

Generate proposals, review them, and then apply them:

```bash
bus reconcile -o ./out/reconcile-proposals.tsv propose
bus reconcile apply --in ./out/reconcile-proposals.tsv --dry-run
bus reconcile apply --in ./out/reconcile-proposals.tsv
```

Turn approved invoice-payment matches into journal entries:

```bash
bus reconcile post \
  --kind invoice_payment \
  --bank-account 1910 \
  --sales-account 3000 \
  --sales-vat-account 2931 \
  --if-missing
```

### Synopsis

`bus reconcile [-C <dir>] [global flags] init [--if-missing] [--force]`  
`bus reconcile [-C <dir>] [global flags] match --bank-id <id|source-ref> (--invoice-id <id> | --journal-id <id>)`  
`bus reconcile [-C <dir>] [global flags] allocate --bank-id <id|source-ref> [--invoice <id>=<amount>] ... [--journal <id>=<amount>] ...`  
`bus reconcile [-C <dir>] [global flags] list`  
`bus reconcile [-C <dir>] [global flags] propose [options]`  
`bus reconcile [-C <dir>] [global flags] apply --in <path>|- [--dry-run] [--fail-if-partial] [options]`  
`bus reconcile [-C <dir>] [global flags] post --kind invoice_payment [posting options]`

### Which command should you use?

Use `match` when the relationship is obvious and one bank row belongs to exactly one invoice or journal entry.

Use `allocate` when one bank row has to be split across several targets, such as a payout that combines an invoice amount and a fee.

Use `propose` and `apply` when you want a review step. This is often the safest default for repeated operational work because the proposal file becomes an auditable review artifact.

Use `post --kind invoice_payment` when the reconciliation already exists and you want deterministic journal postings from it.

### Details that save time

`init` creates `matches.csv` and its schema. Do this once per workspace before the first real reconciliation run.

`propose` writes to stdout by default. If you want a file, remember that `--output` is a global flag and must come before the subcommand:

```bash
bus reconcile -o ./out/proposals.tsv propose
```

`--bank-id` accepts either the canonical `bank_txn_id` or a source reference that resolves to one bank row. This works consistently in `match`, `allocate`, and `propose`.

`apply --dry-run` is the safest first pass for reviewed proposal files. If you want scripts to fail when some rows were skipped or rejected, add `--fail-if-partial`.

`post --kind invoice_payment` uses invoice evidence to build the journal entry. Re-running with `--if-missing` is safe because already-posted voucher IDs are skipped.

### Advanced proposal modes

The batch proposal flow is broader than simple invoice matching.

It can emit historical invoice-reference proposals when the current workspace does not contain the older invoice row but the bank row still proves the identity. It can also emit incoming classifications, suspense fallbacks, suspense reclassification proposals, and settlement payout proposals.

If `bus-bank` has already preserved extracted hints or explicit `source_links` on the bank row, `propose` uses them to narrow invoice candidates before anything is written to `matches.csv`.

If you need those flows, start with `bus reconcile --help` and then test them with a saved proposal file and `apply --dry-run`.

### Typical workflow after bank import

One common BusDK flow looks like this:

```bash
bus bank import --file ./statements/2026-01.csv
bus reconcile -o ./out/reconcile-proposals.tsv propose
bus reconcile apply --in ./out/reconcile-proposals.tsv
bus reconcile post \
  --kind invoice_payment \
  --bank-account 1910 \
  --sales-account 3000 \
  --sales-vat-account 2931 \
  --if-missing
```

### Files

This module owns `matches.csv` and `matches.schema.json` at the workspace root. It reads bank rows, invoice datasets, and journal datasets from their owning modules.

### Exit status

`0` on success. Non-zero on invalid usage, inconsistent amounts, invalid references, or failed apply and posting operations. `propose --fail-if-empty` and `apply --fail-if-partial` are useful when you want scripts to fail on incomplete work.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus reconcile -o ./tmp/proposals.tsv propose
reconcile -o ./tmp/proposals.tsv propose

# same as: bus reconcile apply --in ./tmp/proposals.tsv --dry-run
reconcile apply --in ./tmp/proposals.tsv --dry-run

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

## bus-reconcile

### Name

`bus reconcile` — match bank transactions to invoices or journal entries.

### Synopsis

`bus reconcile <command> [options]`

### Description

`bus reconcile` links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. Reconciliation records are schema-validated and append-only. Use after importing bank data with `bus bank`.

### Commands

- `match` records a one-to-one link between a bank transaction and an invoice or journal transaction (amounts must match exactly).
- `allocate` records allocations for a bank transaction split across multiple invoices or journal entries (allocations must sum to the bank amount).
- `list` lists reconciliation records.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. `allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. For global flags and command-specific help, run `bus reconcile --help`.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Exit status

`0` on success. Non-zero on invalid usage or when amounts or references are invalid.

---

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


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

### Commands

- `match` records a one-to-one link between a bank transaction and an invoice or journal transaction (amounts must match exactly).
- `allocate` records allocations for a bank transaction split across multiple invoices or journal entries (allocations must sum to the bank amount).
- `list` lists reconciliation records.

### Options

`match` accepts `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. `allocate` accepts `--bank-id <id>` and repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reconcile --help`.

### Files

Reconciliation datasets and their beside-the-table schemas in the reconciliation area. Reads bank transactions and invoice/journal references. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `reconcile/` folder).

### Exit status

`0` on success. Non-zero on invalid usage or when amounts or references are invalid.

### Development state

**Value:** Link bank transactions to invoices or journal entries (match and allocate) so the [accounting workflow](../workflow/accounting-workflow-overview) can reconcile bank activity and keep an explicit reconciliation history.

**Completeness:** 30% (Some basic commands) — help, version, and global flags are implemented; unit tests cover run and flags. No e2e; match, allocate, and list are not verified.

**Current:** Unit tests in `internal/app/run_test.go` and `internal/cli/flags_test.go` prove run dispatch and flag parsing. No e2e script exists; match, allocate, and list behavior are not covered by tests.

**Planned next:** match (bank-id plus invoice-id or journal-id); allocate (bank-id with allocations); list with output/format; command-level tests.

**Blockers:** Missing verified match/allocate blocks the reconciliation workflow step.

**Depends on:** [bus-bank](./bus-bank), [bus-invoices](./bus-invoices), [bus-journal](./bus-journal).

**Used by:** End users for reconciliation; no other module invokes it.

See [Development status](../implementation/development-status).

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


---
title: bus-invoices
description: bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the…
---

## `bus-invoices` — create and manage sales and purchase invoices

### Synopsis

`bus invoices init [-C <dir>] [global flags]`  
`bus invoices add --type <sales|purchase> --invoice-id <id> --invoice-date <YYYY-MM-DD> [--due-date <YYYY-MM-DD>] --customer <name> [-C <dir>] [global flags]`  
`bus invoices list [--type <sales|purchase>] [--status <status>] [--month <YYYY-M>] [--from <YYYY-MM-DD>] [--to <YYYY-MM-DD>] [--due-from <YYYY-MM-DD>] [--due-to <YYYY-MM-DD>] [--counterparty <entity-id>] [--invoice-id <id>] [-C <dir>] [global flags]`  
`bus invoices import --profile <path> --source <path> [--source-lines <path>] [--year <YYYY>] [-C <dir>] [global flags]`  
`bus invoices validate [-C <dir>] [global flags]`  
`bus invoices pdf <invoice-id> --out <path> [-C <dir>] [global flags]`  
`bus invoices <invoice-id> add [--desc <text>] [--quantity <number>] [--unit-price <number>] [--income-account <account-name>] [--vat-rate <percent>] [-C <dir>] [global flags]`  
`bus invoices <invoice-id> validate [-C <dir>] [global flags]`  
`bus invoices postings [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus invoices` stores sales and purchase invoices as schema-validated repository data.
It validates totals and VAT amounts and can emit posting rows for the journal.

Invoice headers and lines reference entities, accounts, and attachments.
PDF rendering is delegated to [bus-pdf](./bus-pdf).
Evidence file storage is handled by [bus-attachments](./bus-attachments).

Profile-driven ERP import is available through `bus invoices import`.
Teams can still use generated scripts for migration-specific one-off logic.

### Commands

`init` creates baseline invoice datasets and schemas at workspace root when absent. If all eight files already exist and are consistent, `init` warns on stderr and exits `0` without changes. If state is partial or inconsistent, `init` fails and does not modify files.

`add` creates invoice headers, and `<invoice-id> add` appends line items for an existing invoice. `validate` checks full invoice datasets, while `<invoice-id> validate` checks one invoice’s lines and totals.

`list` returns invoice rows with optional filters (combined with logical `AND`). `import` maps ERP export data into canonical invoice datasets using a versioned profile and supports `--dry-run`. `pdf` delegates rendering to [bus-pdf](./bus-pdf). `postings` emits invoice posting rows for [bus-journal](./bus-journal).

`--legacy-replay` enables legacy-safe replay for mutating commands. In strict mode (default), add/import reject rows where `due_date` is earlier than `issue_date`; with `--legacy-replay`, those rows are preserved and emitted with deterministic warnings.

### Options

`bus invoices add` requires `--type`, `--invoice-id`, `--invoice-date`, and `--customer`, and supports optional `--due-date`.
`bus invoices <invoice-id> add` accepts line-level fields such as `--desc`, `--quantity`, `--unit-price`, `--income-account`, and `--vat-rate`.
`bus invoices pdf` takes positional `<invoice-id>` plus `--out <path>`.

`bus invoices list` supports filters for type/status/id/counterparty and date ranges (`--month`, `--from`, `--to`, `--due-from`, `--due-to`). `--month` is mutually exclusive with `--from`/`--to`, and date filters are inclusive.

`bus invoices import` requires `--profile <path>` and `--source <path>`, and optionally accepts `--source-lines <path>` and `--year <YYYY>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus invoices --help`.

### ERP history import

Profile-driven import maps ERP export rows into canonical invoice datasets with deterministic artifacts.
Profiles can include year filtering, status normalization, VAT line synthesis, and party lookup.

For replay performance diagnostics, set `BUSDK_PERF=1` when running `import`. The command emits deterministic per-table stderr diagnostics:

```bash
BUSDK_PERF=1 bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024
# bus-invoices: perf table=sales-invoices.csv rows=... elapsed_ms=... rows_per_sec=...
```

Generated append scripts are still useful for one-off migration logic.
They are no longer required for the standard ERP history import flow.

### Reconciliation proposal flow integration

Deterministic reconciliation in [bus-reconcile](./bus-reconcile) depends on stable invoice identity and open-item fields from this module.
The workflow uses invoice ID, status, amount, currency, due date, and reference fields as proposal inputs.

Candidate planning can still be scripted for migration-specific cases.
For the standard flow, use command-driven `bus reconcile propose` and `bus reconcile apply`.

### Files

All invoice master data lives in the workspace root (the effective working directory, e.g. after `-C`/`--chdir`). The module does not create or use an `invoices/` subdirectory. The eight owned files are: `sales-invoices.csv`, `sales-invoices.schema.json`, `sales-invoice-lines.csv`, `sales-invoice-lines.schema.json`, `purchase-invoices.csv`, `purchase-invoices.schema.json`, `purchase-invoice-lines.csv`, `purchase-invoice-lines.schema.json`. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus invoices add --type sales --invoice-id 1001 --invoice-date 2026-01-15 --due-date 2026-02-14 --customer "Acme Corp"
bus invoices 1001 add --desc "Consulting, 10h @ EUR 100/h" --quantity 10 --unit-price 100 --income-account "Consulting Income" --vat-rate 25.5
bus invoices validate
```

```bash
bus invoices pdf 1001 --out tmp/INV-1001.pdf
bus invoices list --status unpaid --due-to 2026-02-29
bus invoices import --profile imports/profiles/erp-invoices.yaml --source exports/erp/invoices.tsv --source-lines exports/erp/invoice-lines.tsv --year 2025
bus invoices -C ./workspace postings --format tsv --output ./out/invoice-postings.tsv
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage, schema violations, or reference errors.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus invoices list --status unpaid --due-to 2026-02-29
invoices list --status unpaid --due-to 2026-02-29

# same as: bus invoices INV-2026-004 add --desc "Support retainer" --quantity 1 --unit-price 1500 --income-account "Services" --vat-rate 25.5
invoices INV-2026-004 add --desc "Support retainer" --quantity 1 --unit-price 1500 --income-account "Services" --vat-rate 25.5

# same as: bus invoices import --profile imports/profiles/erp-invoices.yaml --source exports/erp/invoices.tsv --source-lines exports/erp/invoice-lines.tsv --year 2025
invoices import --profile imports/profiles/erp-invoices.yaml --source exports/erp/invoices.tsv --source-lines exports/erp/invoice-lines.tsv --year 2025
```


### Development state

**Value promise:** Maintain sales and purchase invoices as schema-validated workspace data so VAT, reconciliation, and PDF export can use a single source of invoice records in the accounting and sale-invoicing journeys.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 80% — record-invoices and postings journey step completable; init, add, validate, list, postings verified by e2e and unit tests; pdf not verified in e2e.

**Use case readiness:** Accounting workflow: 80% — record-invoices and postings step completable; pdf not verified. Sale invoicing: 80% — create, validate, list, postings verified; pdf step blocked by [bus-pdf](./bus-pdf). Finnish company reorganisation: 80% — invoice evidence-pack baseline verified; pdf not in journey.

**Current:** Init/add/validate/list/import/postings are verified by e2e and unit tests. PDF command behavior is verified at module level; end-to-end PDF output still depends on [bus-pdf](./bus-pdf) availability. For detailed test matrix and implementation notes, see [Module SDD: bus-invoices](../sdd/bus-invoices).

**Planned next:** Keep add/init help alignment (--due-date optional, workspace root wording per PLAN.md). Maintain deterministic open-item read semantics required by `bus reconcile propose/apply`. Optional: attachment_id validation (FR-005) for Finnish compliance.

**Blockers:** [bus-pdf](./bus-pdf) required for `bus invoices pdf`. None for init/add/validate/list/postings.

**Depends on:** [bus-pdf](./bus-pdf) (for `bus invoices pdf`).

**Used by:** [bus-reconcile](./bus-reconcile), [bus-vat](./bus-vat).

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-journal">bus-journal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Layout: Minimal example layout (directory structure)](../layout/minimal-example-layout)
- [Owns master data: Sales invoices](../master-data/sales-invoices/index)
- [Owns master data: Sales invoice rows](../master-data/sales-invoice-rows/index)
- [Owns master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Owns master data: Purchase posting specifications](../master-data/purchase-posting-specifications/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Owns master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-invoices](../sdd/bus-invoices)
- [Layout: Invoices area](../layout/invoices-area)
- [Workflow: Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing)
- [Workflow: Create a sales invoice](../workflow/create-sales-invoice)
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)

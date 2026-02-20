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

Command names follow [CLI command naming](../cli/command-naming). `bus invoices` stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the journal. Invoice headers and lines reference entities, accounts, and attachments. PDF rendering is delegated to [bus-pdf](./bus-pdf), and evidence file storage is handled by [bus-attachments](./bus-attachments).

Profile-driven ERP import is implemented with `bus invoices import`. Teams can also keep using generated scripts when they need migration-specific custom logic.

### Commands

- `init` creates the baseline invoice datasets and schemas (sales and purchase headers and lines and their schemas) in the workspace root when they are absent. If all eight files already exist and are consistent, `init` prints a warning to stderr and exits 0 without changing anything. If only some exist or data is inconsistent, `init` fails with an error and does not modify any file.
- `add` adds a new invoice header (sales or purchase).
- `<invoice-id> add` adds a line item to an existing invoice.
- `validate` validates invoice datasets and module rules for the workspace.
- `<invoice-id> validate` validates line items and totals for an invoice.
- `list` lists invoices with optional filters. Multiple filters are combined with logical AND.
- `import` maps ERP export data into canonical invoice datasets using a versioned profile. It writes deterministic import plan and result artifacts and supports `--dry-run`.
- `pdf` renders an invoice PDF; layout and output are produced by the PDF module (e.g. bus-pdf).
- `postings` emits invoice posting rows for [bus-journal](./bus-journal).

### Options

`bus invoices add` accepts `--type <sales|purchase>`, `--invoice-id <id>`, `--invoice-date <YYYY-MM-DD>`, optional `--due-date <YYYY-MM-DD>`, and `--customer <name>`. `bus invoices <invoice-id> add` accepts `--desc <text>`, `--quantity <number>`, `--unit-price <number>`, `--income-account <account-name>`, and `--vat-rate <percent>`. `bus invoices pdf` takes `<invoice-id>` as a positional argument and `--out <path>`.

`bus invoices list` supports `--type <sales|purchase>`, `--status <status>`, `--month <YYYY-M>`, `--from <YYYY-MM-DD>`, `--to <YYYY-MM-DD>`, `--due-from <YYYY-MM-DD>`, `--due-to <YYYY-MM-DD>`, `--counterparty <entity-id>`, and `--invoice-id <id>`. Date filters apply to the invoice date in the header; `--due-from` and `--due-to` apply to the due date. `--month` is mutually exclusive with `--from` or `--to`. `--from` and `--to` are inclusive; the same applies to `--due-from` and `--due-to`. `--status` and `--counterparty` match the header values exactly (e.g. unpaid or paid; entity identifiers from `bus entities`).

`bus invoices import` requires `--profile <path>` and `--source <path>`, and supports optional `--source-lines <path>` and `--year <YYYY>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus invoices --help`.

### ERP history import

Profile-driven import is available in the current release. For example, `bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024` maps ERP export rows into canonical invoice datasets with deterministic output artifacts. Profiles can include year filtering, status normalization, VAT line synthesis, and party lookup.

For replay performance diagnostics, set `BUSDK_PERF=1` when running `import`. The command emits deterministic per-table stderr diagnostics:

```bash
BUSDK_PERF=1 bus invoices import --profile imports/profiles/erp-invoices-2024.yaml --source exports/erp/invoices-2024.tsv --year 2024
# bus-invoices: perf table=sales-invoices.csv rows=... elapsed_ms=... rows_per_sec=...
```

Generated append scripts are still useful when a migration needs one-off custom logic, but they are no longer required for the standard ERP history import flow.

### Reconciliation proposal flow integration

Deterministic reconciliation proposal generation in [bus-reconcile](./bus-reconcile) depends on stable invoice identity and open-item fields from this module. The two-phase reconciliation flow uses invoice ID, status, amount, currency, due date, and reference fields as deterministic proposal inputs, and then applies approved proposal rows in batch.

Candidate planning can still be done with scripts (for example `exports/2024/025-reconcile-sales-candidates-2024.sh` and prepared `exports/2024/024-reconcile-sales-exact-2024.sh`) when teams need custom migration-specific logic, but first-class `bus reconcile propose/apply` is available for deterministic command-driven workflows.

### Files

All invoice master data lives in the workspace root (the effective working directory, e.g. after `-C`/`--chdir`). The module does not create or use an `invoices/` subdirectory. The eight owned files are: `sales-invoices.csv`, `sales-invoices.schema.json`, `sales-invoice-lines.csv`, `sales-invoice-lines.schema.json`, `purchase-invoices.csv`, `purchase-invoices.schema.json`, `purchase-invoice-lines.csv`, `purchase-invoice-lines.schema.json`. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus invoices add --type sales --invoice-id 1001 --invoice-date 2026-01-15 --due-date 2026-02-14 --customer "Acme Corp"
bus invoices 1001 add --desc "Consulting, 10h @ EUR 100/h" --quantity 10 --unit-price 100 --income-account "Consulting Income" --vat-rate 25.5
```

```bash
bus invoices pdf 1001 --out tmp/INV-1001.pdf
bus invoices list --status unpaid
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage, schema violations, or reference errors.

### Development state

**Value promise:** Maintain sales and purchase invoices as schema-validated workspace data so VAT, reconciliation, and PDF export can use a single source of invoice records in the accounting and sale-invoicing journeys.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 80% — record-invoices and postings journey step completable; init, add, validate, list, postings verified by e2e and unit tests; pdf not verified in e2e.

**Use case readiness:** Accounting workflow: 80% — record-invoices and postings step completable; pdf not verified. Sale invoicing: 80% — create, validate, list, postings verified; pdf step blocked by [bus-pdf](./bus-pdf). Finnish company reorganisation: 80% — invoice evidence-pack baseline verified; pdf not in journey.

**Current:** Verified only. E2E `tests/e2e_bus_invoices.sh` proves help, version, usage exit 2, init (eight files in workspace root only, no `invoices/`, attachment_id in schemas), init --dry-run, validate (missing/success), list TSV and all filters (--type, --status, --month, --from/--to, --due-from/--due-to, --counterparty, --invoice-id), add header and `<invoice-id> add`, `<invoice-id> validate`, total_net and total_vat validation, add and line add refuse when validation fails, add/line add --dry-run, postings (output and --dry-run), and global flags (--output, --chdir, --quiet, --format, --color, --); pdf invoked but e2e expects non-zero (bus-pdf not in PATH). Unit tests in `cmd/bus-invoices/run_test.go`, `internal/initarea/initarea_test.go`, `internal/validate/*`, `internal/add/add_test.go`, `internal/cli/flags_test.go`, `internal/cli/help_test.go`, `internal/cli/color_test.go`, `internal/pdf/pdf_test.go`, `internal/posting/posting_test.go`, and `paths/paths_test.go` cover run behavior, init area, validation, add, flags, help, color, pdf delegation, postings, and path accessors.

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

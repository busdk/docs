---
title: bus-invoices
description: bus invoices creates and validates sales and purchase invoices, imports ERP invoice history, renders invoice PDFs, and emits posting data for downstream accounting workflows.
---

## `bus invoices` — create and manage sales and purchase invoices

`bus invoices` stores invoice headers and invoice lines as workspace data. Use it when you create sales invoices, record purchase invoices, import invoice history, validate invoice totals, or prepare invoice-driven posting data for downstream accounting.

It is the invoice owner in BusDK. Evidence files belong in [bus-attachments](./bus-attachments), PDF rendering goes through [bus-pdf](./bus-pdf), and posting flows continue into [bus-journal](./bus-journal) or [bus-reconcile](./bus-reconcile).

### Common tasks

Create the baseline invoice datasets:

```bash
bus invoices init
```

Create one sales invoice and add a line to it:

```bash
bus invoices add \
  --type sales \
  --invoice-id INV-2026-001 \
  --invoice-date 2026-02-16 \
  --due-date 2026-03-16 \
  --customer "Acme Corp"

bus invoices INV-2026-001 add \
  --desc "Consulting" \
  --quantity 10 \
  --unit-price 100 \
  --income-account "Consulting Income" \
  --vat-rate 25.5
```

Validate all invoices and list unpaid ones:

```bash
bus invoices validate
bus invoices list --status unpaid --due-to 2026-03-31
```

Validate one invoice only:

```bash
bus invoices INV-2026-001 validate
```

Render one invoice as PDF:

```bash
bus invoices pdf INV-2026-001 --out INV-2026-001.pdf
```

Import ERP invoice history with a reusable profile:

```bash
bus invoices import \
  --profile ./profiles/erp-invoices.yaml \
  --source ./exports/invoices.tsv \
  --source-lines ./exports/invoice-lines.tsv \
  --year 2025
```

Emit invoice-driven posting rows for downstream accounting:

```bash
bus invoices postings
```

### Synopsis

`bus invoices init [-C <dir>] [global flags]`  
`bus invoices add --type <sales|purchase> --invoice-id <id> --invoice-date <YYYY-MM-DD> [--due-date <YYYY-MM-DD>] --customer <name> [-C <dir>] [global flags]`  
`bus invoices list [--type <sales|purchase>] [--status <status>] [--month <YYYY-M>] [--from <YYYY-MM-DD>] [--to <YYYY-MM-DD>] [--due-from <YYYY-MM-DD>] [--due-to <YYYY-MM-DD>] [--counterparty <entity-id>] [--invoice-id <id>] [-C <dir>] [global flags]`  
`bus invoices import --profile <path> --source <path> [--source-lines <path>] [--year <YYYY>] [-C <dir>] [global flags]`  
`bus invoices validate [-C <dir>] [global flags]`  
`bus invoices classify [--min-confidence <0..1>] [--apply] [--fail-on-missing-evidence] [-C <dir>] [global flags]`  
`bus invoices pdf <invoice-id> --out <path> [-C <dir>] [global flags]`  
`bus invoices <invoice-id> add [line options] [-C <dir>] [global flags]`  
`bus invoices <invoice-id> validate [-C <dir>] [global flags]`  
`bus invoices postings [-C <dir>] [global flags]`

### Which command should you use?

Use `init` once per workspace.

Use `add` for invoice headers and `<invoice-id> add` for invoice lines.

Use `validate` before you trust totals or downstream posting output.

Use `list` for operational filtering such as unpaid invoices, one month, or one counterparty.

Use `pdf` when you want the rendered document.

Use `import` when a profile-driven ERP history import is easier than manual creation.

Use `postings` when you want the workspace-level `invoice-postings.csv` dataset for downstream journal work.

Use `classify` mainly for recurring purchase-line categorization workflows.

### Typical workflow

A simple sales-invoice flow often looks like this:

```bash
bus invoices add \
  --type sales \
  --invoice-id INV-2026-001 \
  --invoice-date 2026-02-16 \
  --due-date 2026-03-16 \
  --customer "Acme Corp"

bus invoices INV-2026-001 add \
  --desc "Consulting" \
  --quantity 10 \
  --unit-price 100 \
  --income-account "Consulting Income" \
  --vat-rate 25.5

bus invoices validate
bus invoices pdf INV-2026-001 --out INV-2026-001.pdf
```

For migration work, the more common flow is:

```bash
bus invoices import \
  --profile ./profiles/erp-invoices.yaml \
  --source ./exports/invoices.tsv \
  --source-lines ./exports/invoice-lines.tsv \
  --year 2025

bus invoices validate
bus invoices list --type sales --month 2025-12
```

### Important behavior

Invoice totals and VAT totals are validated against the line data when those totals are present in the datasets.

`list` combines filters with logical `AND`.

`--month` is the short path for calendar-month filtering. Use `--from` and `--to` when you need an explicit date range instead. `--month` cannot be combined with `--from` or `--to`.

`--if-missing` and `--upsert` are replay-oriented helpers. They cannot be combined. For line-level `<invoice-id> add`, they also require an explicit `--line-no`.

`--legacy-replay` exists for old non-normalized source data. Keep it as a migration/replay tool rather than your default normal workflow.

`pdf` uses its own `--out` flag instead of the global `--output` flag.

`postings` writes `invoice-postings.csv` and `invoice-postings.schema.json` into the workspace. It does not stream the posting rows to stdout.

### Files

This module owns the sales and purchase invoice header and line datasets at the workspace root. It can also emit `invoice-postings.csv` and its schema for downstream posting flows.

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice, `list` is the main command that benefits from output capture, filters, and TSV output. `init`, `add`, `import`, `classify --apply`, and `postings` are the main mutation-producing commands where `--dry-run` is useful.

For the full option and filter matrix, run `bus invoices --help`.

### Exit status

`0` on success. Non-zero on invalid usage, schema violations, invalid invoice references, total mismatches, or failed imports.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus invoices list --status unpaid --due-to 2026-03-31
invoices list --status unpaid --due-to 2026-03-31

# same as: bus invoices INV-2026-004 add --desc "Support retainer" --quantity 1 --unit-price 1500 --income-account "Services" --vat-rate 25.5
invoices INV-2026-004 add --desc "Support retainer" --quantity 1 --unit-price 1500 --income-account "Services" --vat-rate 25.5

# same as: bus invoices import --profile ./profiles/erp-invoices.yaml --source ./exports/invoices.tsv --source-lines ./exports/invoice-lines.tsv --year 2025
invoices import --profile ./profiles/erp-invoices.yaml --source ./exports/invoices.tsv --source-lines ./exports/invoice-lines.tsv --year 2025
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-journal">bus-journal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Sales invoices](../master-data/sales-invoices/index)
- [Owns master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module reference: bus-invoices](../modules/bus-invoices)
- [Module reference: bus-attachments](../modules/bus-attachments)
- [Module reference: bus-journal](../modules/bus-journal)
- [Workflow: Create a sales invoice](../workflow/create-sales-invoice)
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)

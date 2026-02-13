---
title: bus-invoices
description: bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the…
---

## bus-invoices

### Name

`bus invoices` — create and manage sales and purchase invoices.

### Synopsis

`bus invoices init [-C <dir>] [global flags]`  
`bus invoices add --type <sales|purchase> --invoice-id <id> --invoice-date <YYYY-MM-DD> --due-date <YYYY-MM-DD> --customer <name> [-C <dir>] [global flags]`  
`bus invoices list [--type <sales|purchase>] [--status <status>] [--month <YYYY-M>] [--from <YYYY-MM-DD>] [--to <YYYY-MM-DD>] [--due-from <YYYY-MM-DD>] [--due-to <YYYY-MM-DD>] [--counterparty <entity-id>] [--invoice-id <id>] [-C <dir>] [global flags]`  
`bus invoices pdf <invoice-id> --out <path> [-C <dir>] [global flags]`  
`bus invoices <invoice-id> add [--desc <text>] [--quantity <number>] [--unit-price <number>] [--revenue-account <account-name>] [--vat-rate <percent>] [-C <dir>] [global flags]`  
`bus invoices <invoice-id> validate [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus invoices` stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the journal. Invoice headers and lines reference entities, accounts, and attachments. PDF rendering is delegated to [bus-pdf](./bus-pdf); evidence file storage is handled by [bus-attachments](./bus-attachments).

### Commands

- `init` creates the baseline invoice datasets and schemas (sales and purchase headers and lines and their schemas) in the workspace root when they are absent. If all eight files already exist and are consistent, `init` prints a warning to stderr and exits 0 without changing anything. If only some exist or data is inconsistent, `init` fails with an error and does not modify any file.
- `add` adds a new invoice header (sales or purchase).
- `<invoice-id> add` adds a line item to an existing invoice.
- `<invoice-id> validate` validates line items and totals for an invoice.
- `list` lists invoices with optional filters. Multiple filters are combined with logical AND.
- `pdf` renders an invoice PDF; layout and output are produced by the PDF module (e.g. bus-pdf).

### Options

`bus invoices add` accepts `--type <sales|purchase>`, `--invoice-id <id>`, `--invoice-date <YYYY-MM-DD>`, `--due-date <YYYY-MM-DD>`, and `--customer <name>`. `bus invoices <invoice-id> add` accepts `--desc <text>`, `--quantity <number>`, `--unit-price <number>`, `--revenue-account <account-name>`, and `--vat-rate <percent>`. `bus invoices pdf` takes `<invoice-id>` as a positional argument and `--out <path>`.

`bus invoices list` supports `--type <sales|purchase>`, `--status <status>`, `--month <YYYY-M>`, `--from <YYYY-MM-DD>`, `--to <YYYY-MM-DD>`, `--due-from <YYYY-MM-DD>`, `--due-to <YYYY-MM-DD>`, `--counterparty <entity-id>`, and `--invoice-id <id>`. Date filters apply to the invoice date in the header; `--due-from` and `--due-to` apply to the due date. `--month` is mutually exclusive with `--from` or `--to`. `--from` and `--to` are inclusive; the same applies to `--due-from` and `--due-to`. `--status` and `--counterparty` match the header values exactly (e.g. unpaid or paid; entity identifiers from `bus entities`).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus invoices --help`.

### Files

All invoice master data lives in the workspace root (the effective working directory, e.g. after `-C`/`--chdir`). The module does not create or use an `invoices/` subdirectory. The eight owned files are: `sales-invoices.csv`, `sales-invoices.schema.json`, `sales-invoice-lines.csv`, `sales-invoice-lines.schema.json`, `purchase-invoices.csv`, `purchase-invoices.schema.json`, `purchase-invoice-lines.csv`, `purchase-invoice-lines.schema.json`.

### Examples

```bash
bus invoices add --type sales --invoice-id 1001 --invoice-date 2026-01-15 --due-date 2026-02-14 --customer "Acme Corp"
bus invoices 1001 add --desc "Consulting, 10h @ EUR 100/h" --quantity 10 --unit-price 100 --revenue-account "Consulting Revenue" --vat-rate 25.5
```

```bash
bus invoices pdf 1001 --out tmp/INV-1001.pdf
bus invoices list --status unpaid
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage, schema violations, or reference errors.

---

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
- [Workflow: Create a sales invoice](../workflow/create-sales-invoice)


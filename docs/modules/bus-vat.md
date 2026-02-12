## bus-vat

### Name

`bus vat` — compute VAT reports and exports.

### Synopsis

`bus vat init [-C <dir>] [global flags]`  
`bus vat report --period <period> [-C <dir>] [global flags]`  
`bus vat export --period <period> [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus vat` computes VAT totals per reporting period, validates VAT code and rate mappings, and reconciles invoice VAT with ledger postings. It writes VAT summaries and export data as repository data for archiving and filing. Period selection uses the same `--period` form as other period-scoped commands.

### Commands

- `init` creates the baseline VAT datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their schemas). If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `report` computes and emits VAT summary for a period.
- `export` writes VAT export output for a period (e.g. for filing).

### Options

`report` and `export` require `--period <period>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus vat --help`.

### Files

Reads invoice and journal data and VAT reference datasets (e.g. `vat-rates.csv`). Writes VAT summaries and exports as root-level datasets with schemas. When period-specific report or return data is saved to its own file, it is stored at the workspace root with a date prefix (e.g. `vat-reports-2026Q1.csv`, `vat-returns-2026Q1.csv`), not in a subdirectory. VAT master data (vat-rates.csv, vat-reports.csv, vat-returns.csv and their schemas) is stored in the workspace root only; the module does not use a subdirectory for that data.

### Exit status

`0` on success. Non-zero on invalid usage or VAT mapping violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-vat](../sdd/bus-vat)
- [Layout: VAT area](../layout/vat-area)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)


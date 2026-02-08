## bus-vat

### Name

`bus vat` — compute VAT reports and exports.

### Synopsis

`bus vat <command> [options]`

### Description

`bus vat` computes VAT totals per reporting period, validates VAT code and rate mappings, and reconciles invoice VAT with ledger postings. It writes VAT summaries and export data as repository data for archiving and filing. Period selection uses the same `--period` form as other period-scoped commands.

### Commands

- `report` computes and emits VAT summary for a period.
- `export` writes VAT export output for a period (e.g. for filing).

### Options

`report` and `export` require `--period <period>`. For global flags and command-specific help, run `bus vat --help`.

### Files

Reads invoice and journal data and VAT reference datasets (e.g. `vat-rates.csv`). Writes VAT summaries and exports under period paths (e.g. `2026/vat-reports/`, `2026/vat-returns/`) and root datasets with schemas.

### Exit status

`0` on success. Non-zero on invalid usage or VAT mapping violations.

### See also

Module SDD: [bus-vat](../sdd/bus-vat)  
Layout: [VAT area](../layout/vat-area)  
Workflow: [VAT reporting and payment](../workflow/vat-reporting-and-payment)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

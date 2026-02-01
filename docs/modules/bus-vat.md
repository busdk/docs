## bus-vat

Bus VAT computes VAT totals per reporting period, validates VAT code and rate
mappings against reference data, and reconciles invoice VAT with ledger
postings.

### How to run

Run `bus vat` … and use `--help` for available
subcommands and arguments.

### Subcommands

- `report`: Compute VAT summaries for a reporting period.
- `export`: Write VAT output files for archiving or filing workflows.

### Data it reads and writes

It reads invoice data from [`bus invoices`](./bus-invoices) and
postings from [`bus journal`](./bus-journal), optionally uses
VAT reference datasets such as `vat-rates.csv` in the repository root, and uses
JSON Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes VAT summaries and export files for reporting and archiving (for
example under `2026/vat-reports/` and `2026/vat-returns/`, tracked from
`vat-reports.csv` and `vat-returns.csv` in the repository root), and emits
diagnostics for VAT mismatches or missing mappings.

### Finnish compliance responsibilities

Bus VAT MUST compute VAT reports from journal and invoice data with traceable references and ensure VAT outputs are derivable without manual rewriting of history. It MUST retain VAT code, rate, base, and tax amount in source data used for reporting, it MUST represent VAT corrections as new entries that reference the originals, and it MUST output VAT summaries with links to underlying postings and vouchers suitable for Vero filing.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It consumes data from [`bus invoices`](./bus-invoices),
[`bus journal`](./bus-journal), and
[`bus accounts`](./bus-accounts), and feeds
[`bus filing`](./bus-filing) and statutory reporting workflows.

### See also

Repository: https://github.com/busdk/bus-vat

For VAT dataset layout and reporting workflow context, see [VAT area](../layout/vat-area) and [VAT reporting and payment](../workflow/vat-reporting-and-payment).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reports">bus-reports</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

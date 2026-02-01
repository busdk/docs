## Minimal example layout

A minimal example layout keeps module datasets in the repository root so tools can read and write directly in the current working directory. When a dataset is split into multiple files over time, keep the actual files under a period directory and track them from a root-level index table such as `journals.csv` or `attachments.csv`.

When a filename includes a date, use the `YYYY[MM[DD]]-name.suffix` pattern, with hyphens instead of underscores. For VAT, the default filed-return filename is `YYYYMM-vat-return.csv`.

```text
my-business-books/
  README.md
  datapackage.json
  accounts.csv
  accounts.schema.json
  entities.csv
  entities.schema.json
  sales-invoices.csv
  sales-invoices.schema.json
  sales-invoice-lines.csv
  sales-invoice-lines.schema.json
  purchase-invoices.csv
  purchase-invoices.schema.json
  purchase-invoice-lines.csv
  purchase-invoice-lines.schema.json
  budgets.csv
  budgets.schema.json
  attachments.csv
  attachments.schema.json
  journals.csv
  journals.schema.json
  vat-rates.csv
  vat-rates.schema.json
  vat-returns.csv
  vat-returns.schema.json
  vat-reports.csv
  vat-reports.schema.json
  2025/
    journals/
      2025-journal.csv
      2025-journal.schema.json
  2026/
    journals/
      2026-journal.csv
      2026-journal.schema.json
    vat-returns/
      202603-vat-return.csv
      202603-vat-return.schema.json
    vat-reports/
      202603-vat-report.csv
      202603-vat-report.schema.json
    attachments/
      20260115-INV-1001.pdf
```

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./layout-principles">Data directory layout (principles)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./repository-readme-expectations">Repository-level README expectations</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

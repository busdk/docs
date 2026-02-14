---
title: Minimal example layout
description: A minimal example layout keeps module datasets in the repository root so tools can read and write directly in the current working directory.
---

## Minimal example layout

A minimal example layout keeps module datasets in the repository root so tools can read and write directly in the current working directory. When a dataset is split into multiple files over time, keep the actual files in the workspace root with a date or period prefix and track them from a root-level index table such as `journals.csv` or `attachments.csv`.

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
  journal-2025.csv
  journal-2025.schema.json
  journal-2026.csv
  journal-2026.schema.json
  vat-rates.csv
  vat-rates.schema.json
  vat-returns.csv
  vat-returns.schema.json
  vat-reports.csv
  vat-reports.schema.json
  vat-reports-2026Q1.csv
  vat-returns-2026Q1.csv
  attachments/
    2026/
      01/
        20260115-INV-1001.pdf
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./minimal-workspace-baseline">Minimal workspace baseline (after initialization)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./repository-readme-expectations">Repository-level README expectations</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

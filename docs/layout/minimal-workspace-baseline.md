---
title: Minimal workspace baseline (after initialization)
description: This page defines the minimal workspace baseline that must exist after a fresh initialization so that the end-to-end bookkeeping workflow can run without…
---

## Minimal workspace baseline (after initialization)

This page defines the minimal workspace baseline that must exist after a fresh initialization so that the end-to-end bookkeeping workflow can run without relying on implicit dataset creation. It is the contract that makes workspace initialization testable and reviewable as repository data.

The baseline is derived from the initialization workflow in [Initialize a new repository](../workflow/initialize-repo), the workflow narrative in [Accounting workflow overview](../workflow/accounting-workflow-overview), and the layout invariants in [Data directory layout (principles)](./layout-principles) and [Schemas beside datasets](./schemas-area). The full baseline below is produced when `bus init` is run with all module-include flags (see [bus-init](../modules/bus-init)); running `bus init` with no flags creates only `datapackage.json` and accounting entity settings.

### Baseline layout invariants

Canonical module datasets live in the workspace root as plain files. Every module that owns master data stores its datasets and schemas in the workspace root only — never under a subdirectory (for example, no `accounts/`, `entities/`, or `invoices/` folders for those datasets). Each dataset has a beside-the-dataset Table Schema JSON file with the same base name (for example `accounts.csv` beside `accounts.schema.json`). BusDK does not require a dedicated `schemas/` directory.

When a dataset is split across multiple files over time, the workspace root still contains a single index table for that dataset family (for example `journals.csv` or `vat-reports.csv`). The index table records which period-scoped files exist and where they live in the repository. Period-scoped files are stored in the workspace root with a date or period prefix — for example period journal files use names like `journal-2026.csv` (with a beside-the-table schema), not a subdirectory such as `2026/journals/`.

### Baseline workspace configuration

After initialization, the workspace MUST include `datapackage.json` at the workspace root. This file serves as a deterministic manifest of datasets and schemas, and it stores accounting entity settings (base currency, fiscal year boundaries, and VAT reporting expectations) as workspace-level configuration rather than as per-row fields in operational datasets. See [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration).

### Baseline datasets and schemas

After initialization, the following root-level datasets and their beside-the-dataset schemas MUST exist. Files may be empty baseline tables, but they must be present and schema-valid so that later commands can operate deterministically.

- Chart of accounts: `accounts.csv` and `accounts.schema.json` (see [Accounts area](./accounts-area))
- Counterparties: `entities.csv` and `entities.schema.json` (see [Accounts area](./accounts-area))
- Evidence index: `attachments.csv` and `attachments.schema.json` (see [`bus attachments`](../modules/bus-attachments) and [Invoice PDF storage](./invoice-pdf-storage))
- Journal index: `journals.csv` and `journals.schema.json` (see [Journal area](./journal-area))
- Sales invoices: `sales-invoices.csv` and `sales-invoices.schema.json` (see [Invoices area](./invoices-area))
- Sales invoice lines: `sales-invoice-lines.csv` and `sales-invoice-lines.schema.json` (see [Invoices area](./invoices-area))
- Purchase invoices: `purchase-invoices.csv` and `purchase-invoices.schema.json` (see [Invoices area](./invoices-area))
- Purchase invoice lines: `purchase-invoice-lines.csv` and `purchase-invoice-lines.schema.json` (see [Invoices area](./invoices-area))
- VAT reference data: `vat-rates.csv` and `vat-rates.schema.json` (see [VAT area](./vat-area))
- VAT return index: `vat-returns.csv` and `vat-returns.schema.json` (see [VAT area](./vat-area))
- VAT report index: `vat-reports.csv` and `vat-reports.schema.json` (see [VAT area](./vat-area))
- Period control: `periods.csv` and `periods.schema.json` at the workspace root — not under a subdirectory such as `periods/` (see [`bus period`](../modules/bus-period))
- Normalized bank imports and transactions:
  
  `bank-imports.csv` and `bank-imports.schema.json`, and `bank-transactions.csv` and `bank-transactions.schema.json` (see [`bus bank`](../modules/bus-bank))

Budgeting is optional for the end-to-end statutory bookkeeping chain. If budgeting is enabled in a workspace, it MUST follow the same conventions (root-level datasets with beside-the-dataset schemas). A minimal example is `budgets.csv` beside `budgets.schema.json` (see [Budgeting area](./budget-area)).

### Workspace manifest

The workspace’s Frictionless Data Package descriptor (`datapackage.json`) is the manifest of datasets, paths, and schema references for whole-workspace validation and deterministic exports. It must list every baseline dataset and its schema reference so whole-workspace validation and exports can be performed deterministically. See [Data Package organization](../data/data-package-organization).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./layout-principles">Data directory layout (principles)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../layout/index">BusDK Design Spec: Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./minimal-example-layout">Minimal example layout</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->


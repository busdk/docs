---
title: Minimal workspace baseline (after initialization)
description: This page defines the minimal workspace baseline that must exist after a fresh initialization so that the end-to-end bookkeeping workflow can run without…
---

## Minimal workspace baseline (after initialization)

This page defines the minimal workspace baseline that must exist after a fresh initialization so that the end-to-end bookkeeping workflow can run without relying on implicit dataset creation. It is the contract that makes workspace initialization testable and reviewable as repository data.

The baseline is derived from the initialization workflow in [Initialize a new repository](../workflow/initialize-repo), the workflow narrative in [Accounting workflow overview](../workflow/accounting-workflow-overview), and the layout invariants in [Data directory layout (principles)](./layout-principles) and [Schemas beside datasets](./schemas-area). The full baseline below is produced when `bus init` is run with all module-include flags (see [bus-init](../modules/bus-init)); running `bus init` with no flags creates only `datapackage.json` and accounting entity settings.

### Baseline layout invariants

Canonical module datasets live in the workspace root as plain files. Every module that owns master data stores its datasets and schemas in the workspace root only — never under a subdirectory (for example, no `accounts/`, `entities/`, or `invoices/` folders for those datasets). Each dataset has a beside-the-dataset Table Schema JSON file with the same base name (for example `accounts.csv` beside `accounts.schema.json`). BusDK does not require a dedicated `schemas/` directory. Path ownership belongs to the module that owns each dataset; other modules obtain paths from the owning module (see [Data path contract for read-only cross-module access](../sdd/modules#data-path-contract-for-read-only-cross-module-access)). The design allows future configuration of these paths (for example in a data package).

When a dataset is split across multiple files over time, the workspace root still contains a single index table for that dataset family (for example `journals.csv` or `vat-reports.csv`). The index table records which period-scoped files exist and where they live in the repository. Period-scoped files are stored in the workspace root with a date or period prefix — for example period journal files use names like `journal-2026.csv` (with a beside-the-table schema), not a subdirectory such as `2026/journals/`.

### Baseline workspace configuration

After initialization, the workspace MUST include `datapackage.json` at the workspace root. This file serves as a deterministic manifest of datasets and schemas, and it stores accounting entity settings (base currency, fiscal year boundaries, and VAT reporting expectations) as workspace-level configuration rather than as per-row fields in operational datasets. See [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration).

### Baseline datasets and schemas

After initialization, the following root-level datasets and their beside-the-dataset schemas MUST exist. Files may be empty baseline tables, but they must be present and schema-valid so that later commands can operate deterministically.

Required root-level baseline pairs include chart of accounts (`accounts.csv` and `accounts.schema.json`) and counterparties (`entities.csv` and `entities.schema.json`) in the [Accounts area](./accounts-area), plus evidence index (`attachments.csv` and `attachments.schema.json`) for attachment metadata.

Journal and invoice baselines include `journals.csv` with `journals.schema.json`, `sales-invoices.csv` with `sales-invoices.schema.json`, `sales-invoice-lines.csv` with `sales-invoice-lines.schema.json`, `purchase-invoices.csv` with `purchase-invoices.schema.json`, and `purchase-invoice-lines.csv` with `purchase-invoice-lines.schema.json`.

VAT and period baselines include `vat-rates.csv` with `vat-rates.schema.json`, `vat-returns.csv` with `vat-returns.schema.json`, `vat-reports.csv` with `vat-reports.schema.json`, and period control `periods.csv` with `periods.schema.json` at workspace root.

Banking baselines include `bank-imports.csv` with `bank-imports.schema.json` and `bank-transactions.csv` with `bank-transactions.schema.json`.

Budgeting is optional for the end-to-end statutory bookkeeping chain. If budgeting is enabled in a workspace, it MUST follow the same conventions (root-level datasets with beside-the-dataset schemas). A minimal example is `budgets.csv` beside `budgets.schema.json` (see [Budgeting area](./budget-area)).

### Workspace manifest

The workspace’s Frictionless Data Package descriptor (`datapackage.json`) is the manifest of datasets, paths, and schema references for whole-workspace validation and deterministic exports. It must list every baseline dataset and its schema reference so whole-workspace validation and exports can be performed deterministically. See [Data Package organization](../data/data-package-organization).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./layout-principles">Data directory layout (principles)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../layout/index">BusDK Design Spec: Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./minimal-example-layout">Minimal example layout</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Initialize a new repository](../workflow/initialize-repo)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Data directory layout (principles)](./layout-principles)
- [bus-init module](../modules/bus-init)

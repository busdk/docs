---
title: Data directory layout (principles)
description: BusDK organizes data so commands operate directly in the current working directory.
---

## Data directory layout (principles)

BusDK organizes data so commands operate directly in the current working directory. Canonical module datasets live in the repository root as plain files, with their JSON Table Schemas stored beside them using the same base name. Master data that a module owns (all owned datasets and their beside-the-table schemas) must be stored in that same working directory only; BusDK does not use subdirectories for master data (for example, there is no `accounts/`, `invoices/`, or `periods/` directory for those datasets).

When a module needs multiple files over time, the repository root still contains a single index table (for example `journals.csv`, `attachments.csv`, or `vat-reports.csv`) that records which files exist, which period each file covers, and where they live in the repository. Period-scoped files are kept directly in the repository root with a date or period prefix for disambiguation — for example period journal files use names like `journal-2026.csv` and `journal-2025.csv`, not subdirectories such as `2026/journals/`. The only exception is attachment evidence files: they are stored under `./attachments/yyyy/mm/yyyymmdd-filename...` (see [bus attachments](../modules/bus-attachments) and [Invoice PDF storage](./invoice-pdf-storage)).

Path ownership and read-only access between modules are defined in the [Data path contract for read-only cross-module access](../sdd/modules#data-path-contract-for-read-only-cross-module-access) in the module SDDs: the module that owns a dataset exposes its path (for example via its Go library) so that other modules do not hardcode file names, and the design supports future path configuration.

For Finnish compliance, the layout MUST support audit-trail review and long-term readability, and it MUST be documented in the repository methods description. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./journal-area">Journal area (general ledger transactions)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../layout/index">BusDK Design Spec: Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./minimal-workspace-baseline">Minimal workspace baseline (after initialization)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

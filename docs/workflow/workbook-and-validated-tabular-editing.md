---
title: Workbook and validated tabular editing
description: Local web-based workbook over workspace datasets with schema-validated editing, formula projection, and optional agent-driven operations.
---

## Workbook and validated tabular editing

As a BusDK workspace user you get a lightweight, local, web-based workbook that shows workspace datasets as spreadsheet-like tables and lets you create and edit rows with strict schema validation, so you can maintain reliable typed tabular data without accidentally breaking formats. Formula-projected fields and, when enabled, an agent that can run Bus CLI tools support reproducible, auditable calculations and transformations. The workbook is the generic entry point; Bus modules can later provide dedicated, task-specific screens that write to the same validated workspace data.

The [bus-sheets](../modules/bus-sheets) module is the canonical implementation. It embeds [bus-api](../modules/bus-api) in-process and relies on [bus-data](../modules/bus-data) and [bus-bfl](../modules/bus-bfl) for schema, row operations, and formula semantics. Module readiness is summarised in [Development status — BusDK modules](../implementation/development-status#workbook-and-validated-tabular-editing) under **Workbook and validated tabular editing**.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./inventory-valuation-and-cogs">Inventory valuation and COGS postings</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evolution-over-time">Evolution over time (extending the model)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-sheets](../modules/bus-sheets)
- [bus-api](../modules/bus-api)
- [bus-data](../modules/bus-data)
- [bus-bfl](../modules/bus-bfl)
- [Development status — BusDK modules](../implementation/development-status#workbook-and-validated-tabular-editing)

---
title: Library tables
description: BusDK UI library table component contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TextTable`](./text-table) renders static tabular scalar text.
[`DataTable`](./data-table) renders dense records with column
definitions, row objects, optional status cells, metadata, row events, or row
links.

Rows require stable ids when they emit events. Row links use same-origin paths,
host-resolved resource URLs, or allowlisted `https:` URLs. Invalid links fail
validation before render.

```gx
package notesui

var notesTable = (
  <DataTable rows={notes} columns={noteColumns}></DataTable>
)
```

## Consequence

Product modules project records into generic rows while keeping
business-specific labels in their own view models.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TextTable](./text-table)
- [DataTable](./data-table)

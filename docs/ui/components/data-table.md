---
title: DataTable UI component
description: Dedicated BusDK UI reference for DataTable.
---

## Purpose

`DataTable` is a data display component. Dense records table. Use for repeated records with actions and status.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `columns` | yes | array of `{key,label,component}` | `key` and `label` required; each cell reads `row[key]`. A custom `component` receives `{value,row,column}`. |
| `rows` | yes | array or `{ bind: path }` | Projected view-model records. Rows need stable `id` only when command row actions are present. |
| `rowActions` | no | action item array | Same item shape as [`ActionBar`](./action-bar): non-empty `label` plus exactly one of `action` or `href`. Command items emit `{rowID, action}` and require each row to have `id`; link-only actions may omit row `id`. Row links use binding form such as `href: { bind: row.detailURL }` or template form `/notes/{row.id}`; row `{id: "n1"}` resolves to `/notes/n1`. |
| `empty` | no | slot node or string | Rendered when `rows` is empty; default is no rows message. |

## Boundary

Rows are projected view models: product-owned display objects with only the
fields the table needs. They are not raw provider DTOs, so provider-only fields
and permission details stay outside the table.

## Example

```yaml
data:
  notes:
    - { id: note-1, title: Evidence note, status: review }
view:
  kind: DataTable
  props:
    rows: { bind: notes }
    columns:
      - { key: title, label: Note }
      - { key: status, label: Status, component: StatusPill }
    rowActions:
      - { label: Open, action: open-note }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./text-table">TextTable</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./record-list">RecordList</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

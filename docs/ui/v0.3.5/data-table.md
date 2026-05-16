---
title: DataTable UI component
description: Dedicated BusDK UI reference for DataTable.
---

## Purpose

`DataTable` is a data display component. Dense records table. Use for repeated records with events and status.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `columns` | yes | array of `{key,label,component}` | `key` and `label` required; each cell reads `row[key]`. A custom `component` receives `{value,row,column}`. |
| `rows` | yes | array or Go value | Projected view-model records. Rows need stable `id` only when row events are present. |
| `rowEvents` | no | event item array | Same item shape as [`EventBar`](../v0.2.2/event-bar): non-empty `label` plus exactly one of `onClick` or `href`. Click items run the named event; source identity identifies the row and event item, and rows need stable `id`. Link-only items may omit row `id`. Row links use Go expression such as `href.bind: row.detailURL` or template form `/notes/{row.id}`; row `id: n1` resolves to `/notes/n1`. |
| `empty` | no | slot node or string | Rendered when `rows` is empty; default is no rows message. |

## Boundary

Rows are projected view models: product-owned display objects with only the
fields the table needs. They are not raw provider DTOs, so provider-only fields
and permission details stay outside the table.

## Example

```yaml
data:
  notes:
    - id: note-1
      title: Evidence note
      status: review
view:
  kind: DataTable
  props:
    rows:
      bind: notes
    columns:
      - key: title
        label: Note
      - key: status
        label: Status
        component: StatusPill
    rowEvents:
      - label: Open
        onClick: open-note
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

Row link URLs must be same-origin paths or host-allowlisted `https:` URLs.
Reject `javascript:`, `data:`, path traversal, and credential-bearing URLs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

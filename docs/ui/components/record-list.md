---
title: RecordList UI component
description: Dedicated BusDK UI reference for RecordList.
---

## Purpose

`RecordList` is a data display component. Repeated non-tabular records. Use when summary layout fits better than columns.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array or binding to array | Projected items in display order. Missing required binding fails validation; an empty array renders `empty` when supplied or the default empty state when omitted. |
| `itemComponent` | yes | registered component name | Renderer for each item. The runtime invokes it with props `{item,index,count}` where `item` is the current array item, `index` is zero-based, and `count` is total item count. Unknown component names fail validation. |
| `empty` | no | slot node | Empty state shown only when `items` resolves to an empty array. |

## Boundary

Item order is preserved. `RecordList` does not sort, filter, or mutate records;
the product view model owns ordering and visibility.

## Example

```yaml
kind: RecordList
props:
  items: { bind: notes }
  itemComponent: SummaryItem
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./data-table">DataTable</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./summary-item">SummaryItem</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

---
title: RecordList UI component
description: Dedicated BusDK UI reference for RecordList.
---

## Purpose

`RecordList` is a data display component. Repeated non-tabular records. Use when summary layout fits better than columns.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array or Go value | Projected items in display order. Missing required value fails validation; an empty array renders `empty` when supplied or the default empty state when omitted. |
| `itemComponent` | yes | registered component name | Renderer for each item. The runtime invokes it with props `{item,index,count}` where `item` is the current array item, `index` is zero-based, and `count` is total item count. Unknown component names fail validation. |
| `empty` | no | slot node | Empty state shown only when `items` resolves to an empty array. |

## Boundary

Item order is preserved. `RecordList` does not sort, filter, or mutate records;
the product view model owns ordering and visibility.

## Example

```yaml
kind: RecordList
props:
  items:
    bind: notes
  itemComponent: SummaryItem
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

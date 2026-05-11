---
title: SummaryItem UI component
description: Dedicated BusDK UI reference for SummaryItem.
---

## Purpose

`SummaryItem` is a data display component. Title/meta/detail summary row. Use for search results and record summaries.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or binding | Primary text. Empty or missing title fails validation. |
| `meta` | no | string or binding | Secondary text. Omitted or missing binding renders no meta line. |
| `detail` | no | string or binding | Description. Omitted or missing binding renders no detail text. |
| `badge` | no | string or binding | Compact label. Omitted or missing binding renders no badge. |

## Boundary

All text is escaped.

## Example

```yaml
kind: SummaryItem
props:
  title: Evidence note
  meta: bus-ui
  detail: Needs review
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./record-list">RecordList</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./timeline">Timeline</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

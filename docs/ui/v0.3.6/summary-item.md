---
title: SummaryItem UI component
description: Dedicated BusDK UI reference for SummaryItem.
---

## Purpose

`SummaryItem` is a data display component. Title/meta/detail summary row. Use for search results and record summaries.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or Go value | Primary text. Empty or missing title fails validation. |
| `meta` | no | string or Go value | Secondary text. Omitted or missing value renders no meta line. |
| `detail` | no | string or Go value | Description. Omitted or missing value renders no detail text. |
| `badge` | no | string or Go value | Compact label. Omitted or missing value renders no badge. |

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

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: TextTable UI component
description: Dedicated BusDK UI reference for TextTable.
---

## Purpose

`TextTable` is a data display component. Simple deterministic table. Use for compact static tabular output.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `headers` | yes | string array | Header cells. |
| `rows` | yes | array of row arrays | Body rows. Each row must contain exactly one cell per `headers` entry. Cells may be string, number, boolean, null, or a safe inline node using the normal `kind` plus `props` object shape, such as `Text`, `StatusPill`, or `LinkButton`; unsupported objects fail validation. |

## Boundary

Headers and row order are stable. `TextTable` does not infer missing cells or
hide extra cells, because that would make table meaning ambiguous.

## Example

```yaml
kind: TextTable
props:
  headers:
    - Module
    - Status
  rows:
    - - bus-ui
      - review
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

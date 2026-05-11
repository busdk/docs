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
| `rows` | yes | array of row arrays | Body rows. Each row must contain exactly one cell per `headers` entry. Cells may be string, number, boolean, null, or a safe inline node such as `Text`, `StatusPill`, or `LinkButton`; unsupported objects fail validation. |

## Boundary

Headers and row order are stable. `TextTable` does not infer missing cells or
hide extra cells, because that would make table meaning ambiguous.

## Example

```yaml
kind: TextTable
props:
  headers: [Module, Status]
  rows:
    - [bus-ui, review]
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./submit-state">SubmitState</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./data-table">DataTable</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

---
title: Icon UI component
description: Dedicated BusDK UI reference for Icon.
---

## Purpose

`Icon` is a navigation/action/form component. Shared SVG icon. Use shared symbols instead of product-local SVG copies.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless `path` | icon name | Shared icon from the bus-ui icon registry documented in the component catalog. Provide exactly one of `name` or `path`. |
| `path` | yes unless `name` | SVG path | Custom SVG path `d` data using only path commands and numbers. It must come from audited project assets, not user input. Provide exactly one of `name` or `path`; both or neither fail validation. |
| `title` | no | string | Supplemental accessible description only when the icon itself conveys standalone meaning. It is not the accessible name for icon-only actions; those must use `IconButton.ariaLabel`. Omit `title` for decorative icons next to visible text. |

## Boundary

Decorative icons omit titles when text already labels the action.

## Example

```yaml
kind: Fragment
children:
  - kind: Icon
    props:
      name: download
  - kind: Text
    props:
      value: Download report
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./status-pill">StatusPill</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./form">Form</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

---
title: Icon UI component
description: Dedicated BusDK UI reference for Icon.
---

## Purpose

`Icon` renders a shared SVG symbol. Use shared symbols instead of product-local
SVG copies.

The initial registry contains these names: `add`, `archive`, `check`, `close`,
`download`, `edit`, `error`, `info`, `menu`, `open`, `refresh`, `search`,
`settings`, `upload`, and `warning`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless `path` | icon name | Shared icon from the registry above. Provide exactly one of `name` or `path`. |
| `path` | yes unless `name` | SVG path | Custom SVG path `d` data using only path commands and numbers. It must come from audited project assets, not user input. Provide exactly one of `name` or `path`; both or neither fail validation. |
| `title` | no | string | Supplemental accessible description only when the icon itself conveys standalone meaning. It is not the accessible name for icon-only events; those must use `IconButton.ariaLabel`. Omit `title` for decorative icons next to visible text. |

## Boundary

Decorative icons omit titles when text already labels the event.

## Example

```gx
package reportui

var downloadLabel = (
  <span>
    <Icon name="download"></Icon>
    Download report
  </span>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

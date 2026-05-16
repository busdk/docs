---
title: Panel UI component
description: Dedicated BusDK UI reference for Panel.
---

## Purpose

`Panel` is a shell/layout component. Bounded titled work surface. Use for focused regions such as forms, settings, and detail views.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or Go value | Escaped title. |
| `children` | yes | node list | Panel body. |
| `events` | no | `EventBar` item array or placement/items object | Default placement is header; set `placement: footer` for footer events. Items use EventBar shape. |
| `attrs` | no | safe attribute map | Allows `id`, `class`, `data-*`, and `aria-*`; event handlers, inline style, and unsafe URL attributes are rejected. User attrs merge after framework attrs except protected classes are preserved. |

## Boundary

Title and body render in stable order.

## Example

```gx
package reviewui

var draftPanel = (
  <Panel title="Draft">
    <p>Ready to review</p>
  </Panel>
)
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

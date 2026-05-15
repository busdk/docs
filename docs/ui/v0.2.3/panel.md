---
title: Panel UI component
description: Dedicated BusDK UI reference for Panel.
---

## Purpose

`Panel` is a shell/layout component. Bounded titled work surface. Use for focused regions such as forms, settings, and detail views.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or binding | Escaped title. |
| `children` | yes | node list | Panel body. |
| `events` | no | `EventBar` item array or placement/items object | Default placement is header; set `placement: footer` for footer events. Items use EventBar shape. |
| `attrs` | no | safe attribute map | Allows `id`, `class`, `data-*`, and `aria-*`; event handlers, inline style, and unsafe URL attributes are rejected. User attrs merge after framework attrs except protected classes are preserved. |

## Boundary

Title and body render in stable order.

## Example

```yaml
kind: Panel
props:
  title: Draft
children:
  - kind: Text
    props:
      value: Ready to review
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

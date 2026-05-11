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
| `actions` | no | [`ActionBar`](./action-bar) item array or `{placement,items}` | Default placement is header; set `placement: footer` for footer actions. Items use ActionBar shape. |
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
    props: { value: Ready to review }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./assistant-shell">AssistantShell</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./surface-card">SurfaceCard</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

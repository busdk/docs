---
title: Component UI component
description: Dedicated BusDK UI reference for Component.
---

## Purpose

`Component` is a foundation component: a reusable function from validated props
and slots to nodes. It may read the provided view-model data for rendering, but
it must not mutate product state, call providers, perform permission decisions,
or infer business policy.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `kind` | yes | literal `Component` | Identifies this node as a reusable component invocation. Other node kinds use their own component pages and validation rules. |
| `props.name` | yes | component identifier | Selects a registered component. |
| `props` | yes | component-specific object | Holds `name` plus any props validated by the selected component. |
| `slots` | no | named child nodes | Used for structured regions. May be combined with `children` only when the selected component declares both. |
| `children` | no | child nodes | Used for simple content. If the selected component supports only slots, stray children fail validation. |

## Boundary

Business state is already projected before rendering.

## Example

```yaml
data:
  status: warning
view:
  kind: Component
  props:
    name: StatusSummary
    status: { bind: status }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Paths resolve from
the current component data scope: repeated-item data first, then component
props, then document `data`. Missing bindings render the component default when
the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./v-node">VNode</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./template">Template</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

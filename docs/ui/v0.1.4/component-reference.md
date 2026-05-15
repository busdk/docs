---
title: Component UI component
description: Dedicated BusDK UI reference for Component.
---

## Purpose

`Component` is a foundation component: an invocation of a reusable uppercase
tag from validated props and slots to nodes. In `v0.1.4`, component definitions
come from local `.gx` `component` declarations or host-registered Go component
functions named in the package registry. The selected definition owns the prop
and slot contract used by each invocation. The invocation may read
provided view-model data for rendering, but it must not mutate product state,
call providers, perform permission decisions, or infer business policy.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `kind` | yes | literal `Component` | Identifies this node as a reusable component invocation. Other node kinds use their own component pages and validation rules. |
| `props.name` | yes | component identifier | Selects a registered component. Names use UpperCamelCase for template tags or lowerCamelCase/kebab-case for registry-only helpers; unknown names fail validation. |
| `props` | yes | component-specific object | Holds `name` plus any props validated by the selected component. |
| `slots` | no | map of slot name to child-node array | Used for structured regions. Each key must match a slot declared by the selected component, and each value is an ordered node array. Required slots must be present. Unknown slot names fail validation. May be combined with `children` only when the selected component declares both. |
| `children` | no | child nodes | Used for simple content. If the selected component supports only slots, stray children fail validation. |

## Boundary

Business state is already projected before rendering.

## Node Shape

```yaml
kind: Component
props:
  name: StatusSummary
  status: warning
children:
  - kind: Element
    props:
      tag: span
    children:
      - kind: Text
        props:
          value: Needs review
```

The selected `StatusSummary` definition validates `status` and decides whether
the invocation accepts `children`, `slots`, both, or neither.

Named slots use this node shape:

```yaml
kind: Component
props:
  name: Notice
slots:
  title:
    - kind: Text
      props:
        value: Saved
  body:
    - kind: Element
      props:
        tag: p
      children:
        - kind: Text
          props:
            value: The draft is stored.
```

The selected `Notice` definition must declare `title` and `body`; otherwise
the slot keys fail validation.

## GX Example

```gx
package reviewui

component StatusSummary(status) = (
  <section class="bus-status-summary">
    <span>{status}</span>
  </section>
)

var summary = <StatusSummary status={"warning"}></StatusSummary>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Custom components](./custom-components)
- [GX tooling](../v0.1.3/gx-tooling)

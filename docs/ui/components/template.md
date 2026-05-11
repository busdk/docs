---
title: Template UI component
description: Dedicated BusDK UI reference for Template.
---

## Purpose

`Template` is a foundation component. Static tree with dynamic slots. Use for hot paths where structure is stable and only values change.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | template identifier | Selects a compiled template registered by the host renderer or `bus-ui` template bundle. Valid names come from that registry; unknown names fail validation before rendering. |
| `slots` | yes | map of slot names to values | Supplies only the slot names declared by the selected template. Values are escaped text, booleans, numbers, safe attribute values, or bindings to those values. Missing required slots and unknown extra slots fail validation. Attribute slots must use the same safe URL/path and token rules as normal component props. |
| `children` | no | node list | Allowed only when the selected template declares a `children` slot. Supplying children to a template without that slot fails validation. |

## Boundary

Template documents do not invent template names. The host renderer publishes the available template registry, and product modules choose from that list. Slot values are bounded and escaped before they are inserted, so templates keep stable structure while dynamic data stays data.

## Example

```yaml
kind: Template
props:
  name: terminal-output-line
  slots:
    stream: stdout
    text: { bind: chunk.text }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./component">Component</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./app-shell">AppShell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

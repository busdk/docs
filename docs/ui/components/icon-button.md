---
title: IconButton UI component
description: Dedicated BusDK UI reference for IconButton.
---

## Purpose

`IconButton` is a navigation/action/form component. Icon-only command button. Use for compact repeated commands.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `icon` | yes | icon name | Visual symbol from the bus-ui icon registry documented in [Icon](./icon); unknown names fail validation. |
| `ariaLabel` | yes | string | Non-empty descriptive accessible name for the icon-only control. |
| `action` | no | action token | Command token from the document top-level `actions` map or a registered Go runtime handler; unresolved supplied tokens fail validation. Omitted renders a non-command icon button only when disabled or used as static chrome. |
| `disabled` | no | boolean | Default `false`; disabled icon buttons do not emit actions. |
| `variant` | no | primary, secondary, danger, ghost | Default secondary. |

## Boundary

Icon-only controls remain accessible.

## Example

This component-only example assumes `archive` is already declared in the
document `actions` map or registered by Go code.

```yaml
kind: IconButton
props:
  icon: archive
  ariaLabel: Archive note
  action: archive
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./button">Button</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./link-button">LinkButton</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

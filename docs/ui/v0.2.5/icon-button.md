---
title: IconButton UI component
description: Dedicated BusDK UI reference for IconButton.
---

## Purpose

`IconButton` is a navigation/event/form component. Icon-only button. Use for
compact repeated event controls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `icon` | yes | icon name | Visual symbol from the bus-ui icon registry documented in Icon; unknown names fail validation. |
| `ariaLabel` | yes | string | Non-empty descriptive accessible name for the icon-only control. |
| `click` | no | event name | Event name from the runtime `events` map or a registered Go runtime handler; unresolved supplied names fail validation. Omitted renders a non-emitting icon button only when disabled or used as static chrome. |
| `disabled` | no | boolean | Default `false`; disabled icon buttons do not emit events. |
| `variant` | no | primary, secondary, danger, ghost | Default secondary. |

## Boundary

Icon-only controls remain accessible.

## Example

This component-only example assumes `archive` is already declared in the
runtime `events` map or registered by Go code.

```yaml
kind: IconButton
props:
  icon: archive
  ariaLabel: Archive note
  click: archive
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: Menu UI component
description: Dedicated BusDK UI reference for Menu.
---

## Purpose

`Menu` is a navigation/event component for command choices. Use `Select` for
submitted form values; use `Menu` when choosing an item immediately triggers an
event.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `trigger` | yes | string or node | Button label/content. |
| `items` | yes | array of `{label,value,onClick}` | `label` is non-empty string, `onClick` is a stable event name, and `value` is string/number defaulting to `onClick`. `value` and `onClick` must be unique within the menu. Activating runs the named event with `{value}`. |
| `selected` | no | value | Must match `items[].value`; omitted means no item is selected, and unknown selected values fail validation. |

## Boundary

Menu items expose stable events.

## Example

```yaml
kind: Menu
props:
  trigger: More
  items:
    - label: Rename
      onClick: rename
    - label: Archive
      onClick: archive
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

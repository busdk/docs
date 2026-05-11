---
title: Menu UI component
description: Dedicated BusDK UI reference for Menu.
---

## Purpose

`Menu` is a navigation/action component for command choices. Use `Select` for
submitted form values; use `Menu` when choosing an item immediately triggers an
action.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `trigger` | yes | string or node | Button label/content. |
| `items` | yes | array of `{label,value,action}` | `label` is non-empty string, `action` is stable action token, and `value` is string/number defaulting to `action`. `value` and `action` must be unique within the menu. Activating emits `data-ui-action` with payload `{value, action}`. |
| `selected` | no | value | Must match `items[].value`; omitted means no item is selected, and unknown selected values fail validation. |

## Boundary

Menu items expose stable actions.

## Example

```yaml
kind: Menu
props:
  trigger: More
  items:
    - { label: Rename, action: rename }
    - { label: Archive, action: archive }
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./action-bar">ActionBar</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./tabs">Tabs</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

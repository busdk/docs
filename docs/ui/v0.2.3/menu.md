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
| `items` | yes | item slice | Each item has a non-empty `Label`, optional `Value`, and `OnClick` Go callback. `Value` defaults to the label when omitted and must be unique within the menu. Activating an item calls its callback with the selected item value. |
| `selected` | no | value | Must match `items[].value`; omitted means no item is selected, and unknown selected values fail validation. |

## Boundary

Menu items expose typed Go callbacks. Product modules own the command meaning,
authorization checks, and resulting state updates.

## Example

```gx
func RecordMenu(rename func(string), archive func(string)) gx.Node {
	return <Menu trigger={"More"} items={[]ui.MenuItem{
		{Label: "Rename", Value: "rename", OnClick: rename},
		{Label: "Archive", Value: "archive", OnClick: archive},
	}}></Menu>
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

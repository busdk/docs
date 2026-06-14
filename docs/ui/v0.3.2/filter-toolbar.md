---
title: FilterToolbar UI component
description: Dedicated BusDK UI reference for FilterToolbar.
---

## Purpose

`FilterToolbar` is a node-first navigation/event/form component. Use it as a
compact filter surface above tables and lists.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `SourceID` | recommended for events | string | Stable source id included in submit and reset events. If omitted, the renderer uses the component tree path as the source. |
| `onSubmit` | yes | callback | Runs when the toolbar form is submitted. The event identifies the toolbar source; the app controller decides what filter state to read. |
| `fields` | yes | `Field` props array | Preferred node-first field composition path. |
| `bodyHTML` | no | string | Compatibility escape hatch for trusted legacy toolbar markup. |
| `reset` | no | callback | Omitted hides reset. When present, the handler should clear filter state, and the UI may also clear local draft inputs after success. |

## Boundary

Toolbar wraps without changing field names. The preferred path is typed field
composition; `BodyHTML` remains only for trusted compatibility fragments.

## Example

```go
package notesui

import (
	gx "github.com/busdk/bus-gx/pkg/gx"
	uikit "github.com/busdk/bus-ui/pkg/uikit"
)

func noteFilters() (string, error) {
	return uikit.FilterToolbarChecked(uikit.FilterToolbarProps{
		SourceID: "note-filters",
		Fields: []uikit.FieldProps{
			{
				Label:       "Search",
				ControlID:   "query",
				ControlName: "query",
				RenderControlNode: func(attrs map[string]string) (gx.Node, error) {
					return uikit.TextInputNodeChecked(uikit.TextInputProps{
						Name:  "query",
						Attrs: attrs,
					})
				},
			},
		},
	})
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

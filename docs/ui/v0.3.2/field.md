---
title: Field UI component
description: Dedicated BusDK UI reference for Field.
---

## Purpose

`Field` wraps one visible form control with its label, hint, and validation
message.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `label` | yes | string | Visible label; empty labels fail validation. |
| `renderControlNode` | yes | node callback | Preferred typed control composition path. |
| `bodyHTML` | no | string | Compatibility escape hatch for trusted legacy control markup. |
| `hint` | no | string | Help text associated through `aria-describedby`; omitted renders no hint. |
| `error` | no | string | Validation error associated through `aria-describedby` and marks the control invalid. |

## Boundary

`Field` associates the label with the child control automatically when the
child has `name` and no `id`; otherwise it uses the child `id`. A child with
neither `id` nor `name` fails validation because the label would be inaccessible.
`RenderControlNode` is the preferred node-first path; `BodyHTML` remains only
for trusted compatibility fragments. When you need HTML, render the resulting
node through the public `pkg/ui` boundary.

## Example

```go
package notesui

import (
	"github.com/busdk/bus-ui/pkg/ui"
)

func searchField() (string, error) {
	node, err := ui.Field(ui.FieldProps{
		Label:       "Search",
		ControlID:   "q",
		ControlName: "q",
		RenderControlNode: func(attrs map[string]string) (ui.GxNode, error) {
			return ui.Input(ui.InputProps{
				Type: ui.InputTypeSearch,
				Name: "q",
				Attrs: attrs,
			})
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
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

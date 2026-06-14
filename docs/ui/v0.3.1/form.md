---
title: Form UI component
description: Dedicated BusDK UI reference for Form.
---

## Purpose

`Form` is the public node-first navigation/event/form component. Use it for
native submit behavior while routing the submit through a runtime event.

In templates, `<Form>` invokes this component. Lowercase `<form>` remains a
safe HTML-compatible element; reusable Bus UI behavior belongs in the uppercase
component.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `SourceID` | recommended for events | string | Stable source id included in submit events. If omitted, the renderer uses the component tree path as the source. |
| `method` | yes | GET or POST | Native method. |
| `onSubmit` | yes | `func()` or `func(gx.SubmitEvent)` | Submit callback. The form controller calls it after a submitter click or enter-submit passes native form rules. `gx.SubmitEvent` carries form id, submitter id/name/value, dataset values, and explicit prevent-default state from [typed event payloads](../v0.1.15/typed-event-payloads). |
| `bodyNodes` | yes | node list | Preferred form body composition path. |

## Boundary

Enter-submit works without local JavaScript. Same-origin paths, HTTP methods,
and external-origin allowlists belong to the receiving resource or navigation
entry, not the form component. Submit events identify the form source and
submitter; app controllers decide what model or form state to read.
`BodyNodes` is the preferred node-first composition path. When you need HTML,
render the node through the public `pkg/ui` boundary.

## Example

```go
package notesui

import (
	gx "github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/ui"
)

func noteForm() (string, error) {
	field, err := ui.Field(ui.FieldProps{
		Label:       "Title",
		ControlID:   "note-title",
		ControlName: "title",
		RenderControlNode: func(attrs map[string]string) (ui.GxNode, error) {
			return ui.Input(ui.InputProps{
				Type:  ui.InputTypeText,
				Name:  "title",
				Attrs: attrs,
			})
		},
	})
	if err != nil {
		return "", err
	}
	node, err := ui.Form(ui.FormProps{
		SourceID: "note-editor",
		Method:   ui.FormMethodPost,
		BodyNodes: []gx.Node{
			field,
			gx.Element("button", gx.Props{"type": "submit", "variant": "primary"}, gx.Text("Save")),
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}
```

## Runtime Terms

`onSubmit` has no return value. Validation failures, pending state, and
provider errors are ordinary Go state owned by the parent component. The typed
payload source includes the form `SourceID` when present, otherwise the
renderer-generated tree path. Resource and navigation helpers called by the
callback must accept only same-origin paths or host-allowlisted `https:` URLs
and must reject `javascript:`, `data:`, path traversal, and credential-bearing
URLs.

## Legacy compatibility

`BodyHTML` remains available only for trusted migration fragments that still
need to bridge old string markup into the node-first form shell.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

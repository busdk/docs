---
title: Bus UI v0.1.6 Go controllers and events
description: Patch roadmap for event identity and typed Go controller handlers.
---

## Purpose

`v0.1.6` adds event identity and typed Go controller handlers. Templates attach
event names to tags through props such as `click` and `submit`; emitted events
identify the interaction, and the Go controller decides which model, form, or
component state to read.

## Deliverables

1. Validate event names in templates and Go controller registrations.
2. Emit source identity for clicked controls, submitted forms, and component
   events.
3. Keep request payload selection in Go controller code.
4. Reject inline JavaScript handlers and component-specific action formats.

Event names are lower-case kebab-case strings such as `save-draft`. They must
start with a letter and then contain letters, numbers, and single hyphens;
unknown names or names not registered in the Go controller fail validation
before render.

Supported event props in v0.1.6 are:

| Prop | Allowed tags | Source kind | Trigger |
| --- | --- | --- | --- |
| `click` | `button`, `a`, and uppercase component tags that declare `click` | `control` or `component` | `click` |
| `submit` | `form` | `form` | `submit` |

Other event-looking attributes, including `onclick`, `on-click`, `change`,
`input`, and inline JavaScript handler values, fail template validation in this
patch. Component declarations must list `click` before a component invocation
may use it.

`event.Source` contains stable interaction identity:

```go
type EventSource struct {
	Kind        string
	ID          string
	Path        []int
	Trigger     string
	FormID      string
	SubmitterID string
	ComponentID string
	ItemID      string
}
```

Source constraints are:

| Source | Required fields | Optional fields | Constraints |
| --- | --- | --- | --- |
| Control | `Kind: "control"`, `ID` or `Path`, `Trigger` | `FormID`, `ItemID` | `Trigger` is the prop name such as `click`; `ID` is the control `id` when present, otherwise `Path` is required. |
| Form | `Kind: "form"`, `FormID` or `Path`, `Trigger: "submit"` | `SubmitterID`, `ItemID` | `SubmitterID` is the clicked submit button `id` when present; the controller reads form state by `FormID` or `Path`. |
| Component | `Kind: "component"`, `ComponentID` or `Path`, `Trigger` | `ItemID` | `ComponentID` is the component `id` when present; repeated rows set `ItemID` to the stable row identity. |

`Path` is the zero-based child index route from the mounted root to the source
node after fragments are flattened. For example, path `[0, 2, 1]` means root
child `0`, then that node's child `2`, then that node's child `1`. Paths are a
fallback identity only; authors should prefer stable `id` values for controls,
forms, and components that need durable event identity. If a template inserts,
removes, or reorders siblings before a path-addressed node, its path changes.

Typed controller handlers use this registration shape:

```go
type SaveDraftEvent struct {
	Source gx.EventSource
}

controller.Register("save-draft", gx.TypedHandler(func(ctx context.Context, event SaveDraftEvent) error {
	return saveDraft(ctx, currentDraft(event.Source))
}))
```

`gx.TypedHandler` binds `gx.Event.Source` into the `Source` field by type.
Additional event metadata comes only from framework-owned source metadata, such
as `ItemID`, `SubmitterID`, `Trigger`, `FormID`, and `ComponentID`. Metadata
keys map to exported struct fields by exact field name. Supported field types
are `string`, `bool`, signed and unsigned integers, and aliases of those types;
empty metadata may bind to a zero value only when the field is tagged
`gx:",optional"`. Templates do not provide request payloads; the controller
reads current form or model state using `Source`. Registration validation fails
before render when the event name is not registered, the handler argument is
not a struct, the struct omits `Source gx.EventSource`, required metadata is
missing, or metadata cannot be assigned to the target field type.

## Example

```gx
package notesui

var editor = (
  <form id="draft-editor" submit="save-draft">
    <button id="save-button" type="submit">Save draft</button>
  </form>
)
```

```go
package notesui

import (
	"context"

	"github.com/busdk/bus-gx/pkg/gx"
)

type SaveDraftEvent struct {
	Source gx.EventSource
}

var controller = gx.NewController()

func init() {
	controller.Register("save-draft", gx.TypedHandler(func(ctx context.Context, event SaveDraftEvent) error {
		return saveDraft(ctx, currentDraft(event.Source))
	}))
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Event concept](./event)
- [Binding concept](../v0.1.5/binding)

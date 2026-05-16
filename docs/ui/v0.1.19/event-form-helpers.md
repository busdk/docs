---
title: Event and form helpers
description: BusDK UI v0.1.19 ergonomic Go helpers for GX event payloads and form data.
---

## Contract

`v0.1.19` adds ergonomic `bus-ui` helpers around the typed GX event payloads
from [v0.1.15](../v0.1.15/typed-event-payloads) and the browser adapters from
[v0.1.16 form values](../v0.1.16/form-values) and
[files](../v0.1.16/files). The helpers keep native
HTML-like event names such as `onClick`, `onSubmit`, `onInput`, and
`onChange`, while giving handlers ordinary Go access to target metadata, form
values, files, keyboard data, focus transitions, and drag/drop items.

```go
import (
	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/uikit/uievent"
)

func SaveForm(client DraftClient) func(gx.SubmitEvent) {
	return func(event gx.SubmitEvent) {
		event.PreventDefault()

		form, err := uievent.Form(event)
		if err != nil {
			return
		}

		client.Save(Draft{
			Title:     form.Value("title"),
			Submitter: form.SubmitterName(),
		})
	}
}
```

## Helper Reference

`uievent.Form(event gx.SubmitEvent) (Form, error)` returns form values,
submitter id/name/value, `data-*` attributes, and prevent-default state. It
returns an error when no form source is available.

`uievent.Input(event gx.InputEvent) Input` returns current value, checked state
when available, and target identity. Missing browser fields become zero values.

`uievent.Files(event gx.FileInputEvent) ([]uievent.File, error)` returns safe
file metadata and reader handles through the [file adapter](../v0.1.16/files).
It returns an error when browser file access is unavailable.

`uievent.Keyboard(event gx.KeyboardEvent) Keyboard` returns key, code,
modifier flags, and repeat state.

`uievent.Focus(event gx.FocusEvent) Focus` returns source and destination
target snapshots when the browser provides them.

`uievent.Drop(event gx.DragEvent) (Drop, error)` returns drag/drop item
metadata and file handles through the same file adapter boundary as file
inputs. It returns an error when browser drag data is unavailable.

The helper values expose a compact surface:

| Value | Key API | Defaults and Constraints |
| --- | --- | --- |
| `Form` | `Value(name string) string`, `Values(name string) []string`, `SubmitterID() string`, `SubmitterName() string`, `SubmitterValue() string`, `Data(name string) string`, `DefaultPrevented() bool` | `Value` returns the first value. `Values` preserves repeated form fields in DOM order. Missing fields return `""` or an empty slice. |
| `Input` | `Value string`, `Checked bool`, `Target gx.EventTarget`, `Data(name string) string` | Missing value is `""`; missing checked state is `false`. |
| `File` | `Name string`, `Size int64`, `Type string`, `Open(ctx context.Context) (io.ReadCloser, error)` | Matches the [file adapter](../v0.1.16/files). Missing type is `""`; empty selections return an empty list. |
| `Keyboard` | `Key string`, `Code string`, `Alt bool`, `Ctrl bool`, `Meta bool`, `Shift bool`, `Repeat bool` | Missing string fields are `""`; missing modifiers are `false`. |
| `Focus` | `Target gx.EventTarget`, `RelatedTarget gx.EventTarget` | Missing related target is the zero target. |
| `Drop` | `Target gx.EventTarget`, `Files []File`, `Data(name string) string` | Missing data returns `""`; missing files return an empty list. |

## Requirements

- Helpers wrap typed Go payloads and never expose raw JavaScript values.
- Form helpers preserve repeated field names.
- File helpers expose metadata and reader handles, not raw browser objects.
- Drag/drop helpers share the file safety rules used by file inputs.
- Prevent-default behavior is explicit and observable in tests.
- Missing browser fields become zero values or empty collections.

## Boundary

This patch does not upload files, fetch resources, store sessions, or own
business validation. Product modules still validate form meaning, file policy,
authorization, and provider-specific request bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Expanded intrinsic elements](../v0.1.14/expanded-intrinsic-elements)
- [Typed event payloads](../v0.1.15/typed-event-payloads)
- [Form value adapter](../v0.1.16/form-values)
- [File adapter](../v0.1.16/files)
- [Effect runtime](../v0.1.18/effect-runtime)

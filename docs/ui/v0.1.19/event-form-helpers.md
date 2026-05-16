---
title: Event and form helpers
description: BusDK UI v0.1.19 ergonomic Go helpers for GX event payloads and form data.
---

## Contract

`v0.1.19` adds ergonomic `bus-ui` helpers around the typed GX event payloads
from [v0.1.15](../v0.1.15/typed-event-payloads) and the browser adapters from
[v0.1.16](../v0.1.16/minimal-browser-adapters). The helpers keep native
HTML-like event names such as `onClick`, `onSubmit`, `onInput`, and
`onChange`, while giving handlers ordinary Go access to target metadata, form
values, files, keyboard data, focus transitions, and drag/drop items.

```go
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

The submit helper exposes form data, submitter id/name/value, `data-*`
attributes, and explicit prevent-default state. Input and change helpers expose
current value, checked state where available, selected files for file inputs,
and target identity. Keyboard helpers expose key, code, modifier flags, and
repeat. Focus helpers expose focus-in and focus-out direction. Drag/drop
helpers expose safe item metadata and file handles through the same file
adapter boundary as file inputs.

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
- [Minimal browser adapters](../v0.1.16/minimal-browser-adapters)
- [Effect runtime](../v0.1.18/effect-runtime)

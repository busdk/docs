---
title: Form value adapter
description: BusDK UI v0.1.16 form value extraction adapter.
---

## Contract

Form values are read from a submitted form or a mounted form element through a
Go API. The adapter returns ordinary Go data and does not require string event
names.

```gx
import (
	"errors"

	"github.com/busdk/bus-gx/pkg/gx"
	gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"
)

func Editor() gx.Node {
	return (
		<form onSubmit={save}>
			<input name="title"></input>
			<input name="tag"></input>
			<input name="tag"></input>
			<button type="submit">Save</button>
		</form>
	)
}

func save(event gx.SubmitEvent) {
	values, err := gxwasm.FormValues(event)
	if err != nil {
		if errors.Is(err, gxwasm.ErrUnavailable) {
			reportBrowserUnavailable(err)
			return
		}
		report(err)
		return
	}
	title := values.Get("title")
	tags := values["tag"]
	saveDraft(title, tags)
}
```

The adapter preserves repeated field names. It exposes string values first;
multipart file content belongs to the [file adapter](./files).

`FormValues` and `MountedFormValues` return `net/url.Values`. `Get(name)`
returns the first value for a field. Indexing the map by field name returns the
full slice in DOM insertion order, including repeated controls with the same
`name`.

Mounted form reads use a CSS selector and return the same `net/url.Values`
shape:

```go
values, err := gxwasm.MountedFormValues("#note-editor")
if err != nil {
	report(err)
	return
}
title := values.Get("title")
```

An empty selector returns an error. A selector that does not match an element,
or matches an element that is not a form, returns an error naming the selector
problem. Host builds return errors matching `gxwasm.ErrUnavailable`.

## Requirements

- `FormValues` accepts submit-event form context when the callback was invoked
  from a form submit.
- Mounted-form lookup is a browser adapter concern, not a GX node property.
- Repeated field names remain addressable in insertion order.
- Host builds return errors matching `gxwasm.ErrUnavailable`.
- Browser calls without an active submit event also match
  `gxwasm.ErrUnavailable`.
- Invalid mounted selectors return ordinary errors that name the selector
  problem, such as an empty selector or a selector that does not match a form.

## Boundary

The form value adapter does not validate product input, authorize submission,
upload files, execute resources, or choose which data to send. Application and
library code decide that from ordinary Go state and callbacks.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./minimal-browser-adapters">Minimal browser adapters</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./files">File adapter</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Minimal browser adapters](./minimal-browser-adapters)
- [Typed event payloads](../v0.1.15/typed-event-payloads)

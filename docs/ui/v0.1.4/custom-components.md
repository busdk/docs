---
title: Bus UI v0.1.4 custom components
description: Patch roadmap for reusable GX and registered Bus UI components.
---

## Purpose

`v0.1.4` adds reusable components to [GX templates](../v0.1.3/). Uppercase
tags resolve to local or registered components, component props are validated,
and body content becomes children or named slots.

Lowercase standard HTML names keep resolving through the safe element adapter
set introduced by earlier Core patches. A template scope or host may replace a
lowercase adapter for a name such as `button` or `form`, but the replacement
must preserve deterministic output, safe attributes, accessible semantics, and
event validation.

## Deliverables

1. Resolve uppercase component tags deterministically.
2. Support component props, body children, and declared slots.
3. Reject unknown components, unknown slots, missing required props, and invalid
   prop types before render.
4. Allow higher-level components to be implemented from smaller GX components.
5. Keep data bindings, controller handlers, resources, effects, lifecycle
   hooks, and browser hydration outside this version.

## Prerequisites

Run the examples from the Go package directory that owns the `.gx` file. The
package must use the v0.1.4 `bus-gx` implementation, `bus gx` must be on
`PATH`, and the package must resolve `github.com/busdk/bus-gx` through the
BusDK workspace or a local module `replace`.

## Minimal Component

```gx
package notices

component Notice(message) = (
  <section class="bus-notice">
    <span>{message}</span>
  </section>
)

var noticeExample = <Notice message={"Saved"}></Notice>
```

Save the component example as `notice.gx`. `bus gx lint --format json
notice.gx` exits `0` and emits an empty diagnostics array.

## Children and Slots

Body content becomes the component's default children when the declaration
names `children`:

```gx
package notices

component Notice(children) = (
  <section class="bus-notice">
    {children}
  </section>
)

var noticeWithChildren = (
  <Notice>
    <strong>Saved</strong>
  </Notice>
)
```

Named slots are declared with `slot` parameters and passed with matching
`slot` attributes:

```gx
package notices

component Notice(title slot, body slot) = (
  <section class="bus-notice">
    <header>{title}</header>
    <div>{body}</div>
  </section>
)

var noticeWithSlots = (
  <Notice>
    <span slot="title">Saved</span>
    <p slot="body">The draft is stored.</p>
  </Notice>
)
```

Save the children snippet as `notice_children.gx` before running:

```sh
bus gx render notice_children.gx --entry noticeWithChildren --format html
```

The command emits the same child order as the source after deterministic
attribute sorting and text escaping. A child with an undeclared `slot` value
fails lint with `code: unknown-slot`.

## Registered Components

Hosts may register Go components in the package registry before lint or
render. Registry entries use the same validated prop and slot contract as
local GX components:

Save this Go file as `registry.go` in the same Go module package as
`callout.gx`:

```go
package notices

import "github.com/busdk/bus-gx/pkg/gx"

func Register(reg *gx.Registry) {
	reg.MustComponent("Callout", gx.ComponentSpec{
		Props: []gx.PropSpec{
			{Name: "tone", Type: gx.StringProp},
		},
		Slots: []gx.SlotSpec{
			{Name: "body", Required: true},
		},
		Render: func(ctx gx.ComponentContext) (gx.Node, error) {
			return gx.Element("aside", gx.Props{
				"class": "bus-callout bus-callout-" + ctx.String("tone"),
			}, ctx.Slot("body")), nil
		},
	})
}
```

```gx
package notices

var registeredCallout = (
  <Callout tone={"info"}>
    <p slot="body">Review before sending.</p>
  </Callout>
)
```

Save the GX snippet as `callout.gx` beside `registry.go`. From that package
directory, `bus gx lint --registry notices.Register callout.gx` loads the
package registry and exits `0`. Without that registry entry, the same file
exits non-zero with `code: unknown-component` at the `Callout` tag.

This misspelled tag fixture exits non-zero and emits a JSON diagnostic with
`code: unknown-component` at the `Notcie` tag:

```gx
package notices

component Notice(message) = <span>{message}</span>
var badTag = <Notcie message={"Saved"}></Notcie>
```

This missing prop fixture exits non-zero and emits a JSON diagnostic with
`code: missing-prop` at the `Notice` tag:

```gx
package notices

component Notice(message) = <span>{message}</span>
var missingProp = <Notice></Notice>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component concept](./component)
- [v0.1.3 GX compiler](../v0.1.3/)

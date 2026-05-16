---
title: Callback props
description: BusDK UI v0.1.6 function callback prop contract.
---

## Purpose

`v0.1.6` adds function callback properties. Templates pass ordinary Go
function values through GX markup, and generated Go preserves those
expressions so the Go compiler checks the types.

## Component Props

A component declares callback props in its props struct:

```go
type ButtonProps struct {
	Click    func()
	Children []gx.Node
}
```

The corresponding GX call passes the callback as a Go expression:

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

func SaveButton(saveDraft func()) gx.Node {
  return (
    <Button click={saveDraft}>
      Save draft
    </Button>
  )
}
```

The compiler lowers the callback expression into the props struct:

```go
func SaveButton(saveDraft func()) gx.Node {
	return Button(ButtonProps{
		Click: saveDraft,
		Children: []gx.Node{
			gx.Text("Save draft"),
		},
	})
}
```

Callback props use the same attribute-to-field mapping as other component
props. `click={saveDraft}` maps to `Click`. A callback expression must be
assignable to the selected field type.

## Element Props

Lowercase elements can also carry callback properties. This is how native
browser elements expose callbacks to the frontend runtime:

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

func SaveButton(saveDraft func()) gx.Node {
  return (
    <button class="primary" click={saveDraft}>
      Save draft
    </button>
  )
}
```

The compiler lowers the element to a normal node with a function-valued
property in [Props](../v0.1.1/props):

```go
func SaveButton(saveDraft func()) gx.Node {
	return gx.Element("button", gx.Props{
		"class": "primary",
		"click": saveDraft,
	}, gx.Text("Save draft"))
}
```

Element callback properties extend the `v0.1.1` attribute-only
[Props](../v0.1.1/props) contract with runtime-only function values. The
native element surface is defined by [intrinsic elements](./intrinsic-elements).

Function-valued element properties are retained in the
[render tree](../v0.1.1/render-tree-contract) for runtimes and tests, but they
are not serialized as HTML attributes by static HTML rendering.

## Boundary

This patch defines how callback functions are represented and type checked in
GX output. It does not define browser listener mounting, callback payload
structs, a dispatch registry, or shared application behavior. Applications and
component authors decide what each callback does in ordinary Go.

String values are not callback handlers. A callback prop such as
`click={saveDraft}` must not accept `click="save-draft"`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Intrinsic elements](./intrinsic-elements)
- [v0.1.4 component calls](../v0.1.4/component-reference)
- [v0.1.5 component composition](../v0.1.5/)

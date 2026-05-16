---
title: bus-gx — GX core render tree and source tools
description: End-user reference for the bus-gx module and the currently implemented v0.1.6 GX callback and intrinsic interactivity patch.
---

## `bus-gx` — GX core render tree and source tools

Current implemented UI roadmap version: **v0.1.6 GX callbacks and intrinsic
interactivity**.

`bus-gx` is the low-level Go module for BusDK GX render-tree code and `.gx`
source tooling. Through `v0.1.6`, it provides the safe static HTML foundation
in `github.com/busdk/bus-gx/pkg/gx`, source-only formatting and linting
helpers in `github.com/busdk/bus-gx/pkg/gx/source`, and a static compiler that
lowers checked `.gx` expressions into ordinary Go with package-scope function
component calls, GX markup inside Go function bodies, braced expression
children, component body children, component callback props, and intrinsic
callback props for the first interactive lowercase elements.

The module installs as the `bus gx` command family through the BusDK
dispatcher. It implements `fmt`, `fmt --check`, `lint`, `lint --format json`,
and `compile` for `.gx` files. Browser mounting, DOM listener wiring, bindings,
controllers, lifecycle hooks, hydration, data loading, and runtime resources
belong to later UI roadmap versions.

## Import

```go
import (
	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-gx/pkg/gx/source"
)
```

## Public API

| API | Purpose |
| --- | --- |
| `gx.Node` | Interface for values that normalize to a validated `gx.VNode`. |
| `gx.Renderer` | Interface for deterministic HTML renderers. |
| `gx.HTMLRenderer` | Default concrete renderer. |
| `gx.RenderHTML` | Convenience function for rendering one `gx.Node`. |
| `gx.VNode` | Normalized render-tree shape for tests and renderers. |
| `gx.Text` | Escaped scalar text node constructor. |
| `gx.Element` | Safe lowercase intrinsic element constructor. |
| `gx.Fragment` | Child group that renders without a wrapper. |
| `gx.Props` | Deterministic validated attribute map. |
| `source.CurrentVersion` | Implemented source-tool/compiler patch version. |
| `source.ParseFile` | Source-only `.gx` parser with stable locations. |
| `source.FormatFile` | In-memory deterministic `.gx` formatter. |
| `source.FormatPaths` | File formatter used by the CLI. |
| `source.LintFile` | Source-only `.gx` linter. |
| `source.CompileFile` | Deterministic `.gx` to `.go` compiler. |
| `source.ExtractEntries` | Package-local template entry extractor. |
| `source.WriteHuman` | Stable human diagnostics. |
| `source.WriteJSON` | Stable JSON diagnostics. |

## Example

```go
node := gx.Element("p",
	gx.Props{"class": "message"},
	gx.Text("Hello <Bus>"),
)

html, err := gx.RenderHTML(node)
```

The rendered HTML is:

```html
<p class="message">Hello &lt;Bus&gt;</p>
```

## Safety Boundary

Text is escaped. Static attributes are validated, sorted, and escaped. Element
tags are limited to the safe intrinsic allowlist: the structural tags from
`v0.1.1` plus `button`, `form`, `input`, and `label` from `v0.1.6`. Raw HTML,
event-handler attributes such as `onclick`, URL-bearing attributes such as
`href` and `src`, inline `style`, malformed names, unsupported scalar values,
non-finite numbers, unsupported callback props, and callback values with the
wrong type fail validation.

Source tools keep the same closed boundary. Lowercase `.gx` tags are limited
to the safe intrinsic element allowlist. Uppercase tags resolve to
package-scope Go functions or method values shaped as `func(P) gx.Node`, where
`P` is a struct props type. Braced body expressions are typed as ordinary Go:
`string` becomes escaped text, `gx.Node` becomes one child, and `[]gx.Node` is
spliced in source order. Raw text inside markup is rejected; authors must use
`Text` or braced expressions so formatting cannot silently discard content.

`v0.1.6` callback props are ordinary Go function values. Component callback
props use the selected component's props struct type. Intrinsic callbacks are
limited to `button click={func()}`, `form submit={func()}`, `input
input={func(string)}`, and `input change={func(string)}`. Those functions stay
in `gx.Props` and normalized `gx.VNode` attributes for future browser runtime
consumers, while `gx.RenderHTML` validates and omits function-valued props from
static HTML.

## Source Tools

Minimal `.gx` source:

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

type NoticeProps struct {
	Message  string
	Tone     string `gx:",optional"`
	Children []gx.Node
}

type ButtonProps struct {
	Label string
	Click func()
}

func Notice(props NoticeProps) gx.Node {
	return <section class={props.Tone}><p>{props.Message}</p>{props.Children}</section>
}

func Button(props ButtonProps) gx.Node {
	return <button click={props.Click} type="button">{props.Label}</button>
}

func NoteEditor(save func(), setTitle func(string)) gx.Node {
	return (
		<form submit={save}><label for="title">{"Title"}</label><input input={setTitle} name="title"></input><Button click={save} label={"Save"}></Button></form>
	)
}

func saveDraft() {}
func setTitle(value string) {}

var suffix = []gx.Node{gx.Text("!")}
var hello = <Notice message={"Hello Bus"} tone={"message"}>{gx.Text(" from GX")}{suffix}<Button click={saveDraft} label={"Save"}></Button></Notice>
```

Save the sample as `hello.gx`. With BusDK commands on `PATH`:

```sh
bus gx fmt --check hello.gx
bus gx lint --format json hello.gx
bus gx compile hello.gx --output hello.go
```

Valid source prints an empty JSON diagnostics array for `lint --format json`.
Invalid source prints stable diagnostics with `file`, `line`, `column`,
`endLine`, `endColumn`, `code`, `severity`, and `message`.

`compile` writes a generated Go file in the same package as the source file.
`compile` preserves the surrounding Go declaration shape. The example above
lowers component body content to a `Children []gx.Node` field and lowers
braced children according to their Go type. Function-valued callback props stay
as Go values:

```go
func Button(props ButtonProps) gx.Node {
	return gx.Element("button", gx.Props{"click": props.Click, "type": "button"}, gx.Text(props.Label))
}

func NoteEditor(save func(), setTitle func(string)) gx.Node {
	return (gx.Element("form", gx.Props{"submit": save}, gx.Element("label", gx.Props{"for": "title"}, gx.Text("Title")), gx.Element("input", gx.Props{"input": setTitle, "name": "title"}), Button(ButtonProps{Click: save, Label: "Save"})))
}

var hello = Notice(NoticeProps{Message: "Hello Bus", Tone: "message", Children: func() []gx.Node {
	var __gxChildren []gx.Node
	__gxChildren = append(__gxChildren, gx.Text(" from GX"))
	__gxChildren = append(__gxChildren, suffix...)
	__gxChildren = append(__gxChildren, Button(ButtonProps{Click: saveDraft, Label: "Save"}))
	return __gxChildren
}()})
```

Direct `.gx` to HTML rendering and browser event mounting are outside this
version. Compile `.gx` to Go first, then use the generated Go from an ordinary
Go program.

## Verify Installed Command

With BusDK commands on `PATH`, the installed dispatcher should report the
implemented version:

```sh
bus gx version
```

Expected output:

```text
bus-gx v0.1.6
```

Use `bus gx fmt --check`, `bus gx lint --format json`, and
`bus gx compile <file.gx> --output <file.go>` on project `.gx` files in CI.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI v0.1.1 Core node foundation](../ui/v0.1.1/)
- [Core node acceptance](../ui/v0.1.1/acceptance)
- [Shared interfaces](../ui/v0.1.1/interfaces)
- [Props reference](../ui/v0.1.1/props)
- [UI v0.1.2 GX source tools](../ui/v0.1.2/)
- [GX source tool acceptance](../ui/v0.1.2/acceptance)
- [UI v0.1.3 GX compiler](../ui/v0.1.3/)
- [GX compiler acceptance](../ui/v0.1.3/acceptance)
- [UI v0.1.4 GX components](../ui/v0.1.4/)
- [GX component acceptance](../ui/v0.1.4/acceptance)
- [UI v0.1.5 GX markup bodies](../ui/v0.1.5/)
- [UI v0.1.6 GX callbacks and intrinsic interactivity](../ui/v0.1.6/)

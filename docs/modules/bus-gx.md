---
title: bus-gx - GX core render tree, source tools, and WASM runtime
description: End-user reference for the bus-gx module and the currently implemented v0.1.11 WASM app acceptance patch.
---

## `bus-gx` - GX core render tree, source tools, and WASM runtime

Current implemented UI roadmap version: **v0.1.11 WASM app acceptance**.

`bus-gx` is the low-level Go module for BusDK GX render-tree code and `.gx`
source tooling. Through `v0.1.11`, it provides the safe static HTML foundation
in `github.com/busdk/bus-gx/pkg/gx`, source-only formatting and linting helpers
in `github.com/busdk/bus-gx/pkg/gx/source`, a static compiler that lowers
checked `.gx` expressions into ordinary Go, and
`github.com/busdk/bus-gx/pkg/gx/wasm` for mounting a GX root from Go
WebAssembly with redacted post-mount diagnostics behind a narrow browser API
boundary. It also provides `github.com/busdk/bus-gx/pkg/gxtest` for
deterministic render, compiler, and WASM callback tests, plus a module-owned
WASM acceptance app under `tests/wasm-app` that proves the v0.1.x pieces work
together from `.gx` source to generated Go to browser-mounted Go WebAssembly.

The module installs as the `bus gx` command family through the BusDK
dispatcher. It implements `fmt`, `fmt --check`, `lint`, `lint --format json`,
and `compile` for `.gx` files. The WASM runtime mounts one `func() gx.Node`
root, reruns it on explicit updates, renders directly into the DOM, wires the
first intrinsic button/form/input callbacks, and reports redacted post-mount
render/callback diagnostics through an optional Go hook. Browser access stays
behind `pkg/gx/wasm`; the module does not create a global JavaScript framework
facade, generate inline JavaScript callbacks, or serialize callback/diagnostic
metadata into DOM attributes. Bindings, controller registries, effects,
resources, logging transports, product logging, raw HTML, and hydration are
outside the current module boundary.

## Import

```go
import (
	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-gx/pkg/gx/source"
	gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"
	"github.com/busdk/bus-gx/pkg/gxtest"
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
| `gxwasm.Mount` | Mount one root `func() gx.Node` into a browser element. |
| `gxwasm.Options` | Optional runtime hooks, currently `OnError func(error)`. |
| `gxwasm.Update` | Rerun the current root and replace the mounted DOM subtree. |
| `gxwasm.Unmount` | Clear the current mount and release retained callbacks. |
| `gxwasm.Handle` | Explicit mount handle with `RequestUpdate` and `Unmount`. |
| `gxtest.RenderHTML` | Test helper for deterministic escaped HTML. |
| `gxtest.VNode` | Test helper for normalized render-tree assertions. |
| `gxtest.RequireProp` | Typed test helper for scalar and callback props. |
| `gxtest.CompileGX` | Test helper for generated Go fixture output. |
| `gxtest.MountWASM` | Browser-backed Go WebAssembly test harness. |

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
in `gx.Props` and normalized `gx.VNode` attributes. `gx.RenderHTML` validates
and omits function-valued props from static HTML. `gxwasm` wires the supported
intrinsic callbacks to browser events when rendering in Go WebAssembly, and
`form submit` callbacks prevent default browser form submission.

`v0.1.8` runtime diagnostics stay framework-owned and redacted. Selector
lookup, invalid root, and initial render failures are returned directly from
`gxwasm.Mount`. After a successful mount, render failures and callback panics
are reported through `gxwasm.Options{OnError: func(error)}`. If no handler is
configured, the runtime writes the same redacted diagnostic to browser
`console.error` when available.

`v0.1.9` keeps browser API use limited to the Go-facing runtime helpers:
mount, update, unmount, and the intrinsic callback wiring above. The runtime
does not expose `window.BusGX`-style framework globals, inline JavaScript
handler strings, secret-bearing runtime configuration in DOM attributes, raw
HTML passthrough, local storage helpers, file drop APIs, streaming readers,
close guards, product logging helpers, or a client log transport.

`v0.1.10` adds `pkg/gxtest` for tests only. The helpers fail through
`testing.TB`, make no network calls, read no host credentials, and do not add
product-specific harness behavior. The WASM harness installs a scoped test DOM
fixture, uses the real `gxwasm.Mount` path, and supports tag, `#id`, and
simple `tag[attr=value]` selectors.

`v0.1.11` adds the complete acceptance fixture for the v0.1.x line. The
fixture keeps editor state in ordinary Go package values, renders a `.gx`
component function with lowercase `form`, `label`, `input`, `button`, and `p`
elements, compiles that source to checked-in Go, verifies `bus gx fmt --check`,
`bus gx lint --format json`, and `bus gx compile`, then runs host and
browser-backed tests through the real runtime and `gxtest` helpers. The save
path is owned by the form `submit` callback; the separate clear button covers
button `click`, and input editing flows through `input={func(string)}`.

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

Compile `.gx` to Go first, then use the generated Go from an ordinary Go
program. In a Go WebAssembly frontend, those generated component functions can
be rendered by a `gxwasm` root.

## Go WebAssembly Runtime

`pkg/gx/wasm` mounts one root function into a browser element:

```go
package main

import (
	"fmt"

	"github.com/busdk/bus-gx/pkg/gx"
	gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"
)

var title string

func App() gx.Node {
	return gx.Element("form", gx.Props{"submit": save},
		gx.Element("input", gx.Props{"input": setTitle, "name": "title"}),
		gx.Element("button", gx.Props{"type": "submit"}, gx.Text("Save")),
		gx.Element("p", nil, gx.Text(title)),
	)
}

func setTitle(value string) {
	title = value
	gxwasm.Update()
}

func save() {}

func reportRuntime(err error) {
	fmt.Println(err)
}

func main() {
	if _, err := gxwasm.Mount("#app", App, gxwasm.Options{OnError: reportRuntime}); err != nil {
		panic(err)
	}
	select {}
}
```

`gxwasm.Mount` renders the returned node tree directly into the matching DOM
element. `gxwasm.Update` and `Handle.RequestUpdate` rerun the same root and
replace the runtime-owned DOM subtree. `gxwasm.Unmount` and `Handle.Unmount`
clear the mount and release retained JavaScript callbacks so events do not call
Go after unmount.

`gxwasm.Mount("#app", App)` remains valid when no runtime diagnostics hook is
needed. Passing one `gxwasm.Options` value configures post-mount diagnostics.
Errors returned before mount succeeds are not sent to `OnError`. Errors after
mount succeeds use stable redacted categories such as `runtime-render-failed`
and `runtime-callback-failed`; raw panic values and raw node validation details
are not included.

## Test Helpers

`pkg/gxtest` keeps component, generated-output, and WASM callback tests small:

```go
html := gxtest.RenderHTML(t,
	gx.Element("p", gx.Props{"class": "message"}, gx.Text("Hello")),
)
vnode := gxtest.VNode(t,
	gx.Element("button", gx.Props{"click": save}, gx.Text("Save")),
)
click := gxtest.RequireProp[func()](t, vnode, "click")
click()
generated := gxtest.CompileGX(t, "hello.gx",
	"package demo\n\nvar hello = <p>{\"Hello\"}</p>\n",
)
```

Browser-backed tests run through `make test-wasm`:

```sh
make test-wasm
```

```go
h := gxtest.MountWASM(t, "#app", view)
h.Input("input[name=title]", "Draft")
h.Submit("form")
if got := h.HTML(); got == "" {
	t.Fatal("empty mounted HTML")
}
if diagnostics := h.Diagnostics(); len(diagnostics) != 0 {
	t.Fatalf("diagnostics = %v", diagnostics)
}
```

## Verify Installed Command

With BusDK commands on `PATH`, the installed dispatcher should report the
implemented version:

```sh
bus gx version
```

Expected output:

```text
bus-gx v0.1.11
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
- [UI v0.1.7 GX Go WebAssembly runtime](../ui/v0.1.7/)
- [UI v0.1.8 GX Go WebAssembly runtime diagnostics](../ui/v0.1.8/)
- [UI v0.1.9 GX browser API boundaries](../ui/v0.1.9/)
- [UI v0.1.10 Core test helpers](../ui/v0.1.10/)
- [UI v0.1.11 WASM app acceptance](../ui/v0.1.11/)

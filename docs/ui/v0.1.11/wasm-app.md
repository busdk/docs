---
title: WASM app acceptance
description: BusDK UI v0.1.11 complete GX frontend acceptance fixture.
---

## Contract

`v0.1.11` proves the v0.1.x line is usable as a small Go equivalent of
TSX/React. A test app keeps state in Go, renders through component functions
that contain GX markup, compiles `.gx` to `.go`, mounts in the browser through
Go WebAssembly, handles form submit, button click, and input callbacks,
rerenders, and asserts the result.

The acceptance fixture must include:

1. a module-owned fixture under `bus-gx/tests/wasm-app/`;
2. a `.gx` component function using lowercase `form`, `label`, `input`, and
   `button` elements;
3. ordinary Go state and callbacks used by that component;
4. `bus gx fmt --check`, `bus gx lint --format json`, and
   `bus gx compile <file.gx> --output <file.go>`;
5. a host test that verifies generated Go matches the checked-in output;
6. a browser-backed e2e test run by `make test-wasm`;
7. no YAML binding files, controller registry, component registry, custom
   event names, global JavaScript facade, or raw HTML.

Run `make test-wasm` from the `bus-gx` module checkout. The target needs
`node` on `PATH` and the executable Go WebAssembly test runner at
`$(go env GOROOT)/lib/wasm/go_js_wasm_exec`; if either is missing, the target
prints a skip message. When the environment is available, the target passes
only when the fixture enters text into the input, clicks a button callback,
submits the form callback, observes the expected Go state changes, observes
the rerendered DOM, and reports no runtime diagnostics.

## Example Shape

```gx
package app

import (
	"github.com/busdk/bus-gx/pkg/gx"
	gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"
)

var title string
var savedTitle string
var saves int
var clears int

func setTitle(value string) {
	title = value
	gxwasm.Update()
}

func save() {
	savedTitle = title
	saves++
	gxwasm.Update()
}

func clear() {
	title = ""
	clears++
	gxwasm.Update()
}

func status() string {
	return "Draft: " + title
}

func Editor() gx.Node {
	return (
		<form id="editor" submit={save}><label for="title">{"Title"}</label><input id="title" input={setTitle} name="title" value={title}></input><button click={clear} type="button">{"Clear"}</button><button type="submit">{"Save"}</button><p id="status">{status()}</p></form>
	)
}
```

The generated Go is ordinary package code. Callback values remain function
values in `gx.Props`; static HTML rendering omits them, and the WASM runtime
wires them to DOM events.

## Boundary

This patch is an acceptance slice, not a new feature family. It may add small
fixes needed to make earlier v0.1.x contracts work together, but it must not
add resources, effects, routing, provider APIs, logging transports, or a render
command.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component body markup](../v0.1.5/component-body-markup)
- [Intrinsic interactive elements](../v0.1.6/intrinsic-elements)
- [Mounting and updates](../v0.1.7/mounting-updates)

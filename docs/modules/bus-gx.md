---
title: bus-gx — GX core render tree and source tools
description: End-user reference for the bus-gx module and the currently implemented v0.1.4 GX component patch.
---

## `bus-gx` — GX core render tree and source tools

Current implemented UI roadmap version: **v0.1.4 GX components**.

`bus-gx` is the low-level Go module for BusDK GX render-tree code and `.gx`
source tooling. Through `v0.1.4`, it provides the safe static HTML foundation
in `github.com/busdk/bus-gx/pkg/gx`, source-only formatting and linting
helpers in `github.com/busdk/bus-gx/pkg/gx/source`, and a static compiler that
lowers checked `.gx` entries into ordinary Go with package-scope function
component calls.

The module installs as the `bus gx` command family through the BusDK
dispatcher. It implements `fmt`, `fmt --check`, `lint`, `lint --format json`,
and `compile` for `.gx` files. Browser mounting, callbacks, bindings, events,
lifecycle hooks, hydration, data loading, and runtime resources belong to later
UI roadmap versions.

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
| `gx.Element` | Safe lowercase structural HTML element constructor. |
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

Text is escaped. Attributes are validated, sorted, and escaped. Element tags
are limited to the `v0.1.1` safe structural allowlist. Raw HTML, event-handler
attributes such as `onclick`, URL-bearing attributes such as `href` and `src`,
inline `style`, malformed names, unsupported scalar values, and non-finite
numbers fail validation.

Source tools keep the same closed boundary. Lowercase `.gx` tags are limited
to the safe structural element allowlist. Uppercase tags resolve to
package-scope Go functions or method values shaped as `func(P) gx.Node`, where
`P` is a struct props type. Raw text inside markup is rejected; authors must
use `Text` so formatting cannot silently discard content.

## Source Tools

Minimal `.gx` source:

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

type NoticeProps struct {
	Message string
	Tone    string `gx:",optional"`
}

func Notice(props NoticeProps) gx.Node {
	return gx.Element("p", gx.Props{"class": props.Tone}, gx.Text(props.Message))
}

var hello = <Notice message={"Hello Bus"} tone={"message"}></Notice>
```

With BusDK commands on `PATH`:

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
lowers the markup initializer to:

```go
var hello = Notice(NoticeProps{Message: "Hello Bus", Tone: "message"})
```

Direct `.gx` to HTML rendering is outside this version.

## Checks

From the `bus-gx` module root:

```sh
make fmt
make test
make lint
make build
make e2e
make check
```

`make check` is the default release gate for `v0.1.4`. It formats, vets,
lints, runs package tests, builds `./bin/bus-gx`, and runs the CLI e2e smoke.

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

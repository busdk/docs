---
title: bus-gx — GX core render tree library
description: End-user reference for the bus-gx module and the currently implemented v0.1.1 Core node foundation.
---

## `bus-gx` — GX core render tree library

Current implemented UI roadmap version: **v0.1.1 Core node foundation**.

`bus-gx` is the low-level Go library for BusDK GX render-tree code. In
`v0.1.1`, it provides only the safe static HTML foundation in
`github.com/busdk/bus-gx/pkg/gx`: nodes, props, validation, and deterministic
escaped HTML rendering.

There is no `bus gx` command in `v0.1.1`. `.gx` source files, GX formatting and
linting commands, compilation, custom tags, controllers, bindings, events,
lifecycle hooks, browser mounting, hydration, and generated Go belong to later
UI roadmap versions.

## Import

```go
import "github.com/busdk/bus-gx/pkg/gx"
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

## Checks

From the `bus-gx` module root:

```sh
make fmt
make test
make lint
make check
```

`make check` is the default release gate for `v0.1.1`. It formats, vets, lints,
runs package tests, performs the library-only build, and runs the e2e smoke.
The library-only build intentionally reports that no `cmd/bus-gx/main.go`
exists.

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

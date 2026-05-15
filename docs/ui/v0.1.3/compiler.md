---
title: Bus UI v0.1.3 GX compiler
description: Patch roadmap for compiling GX source packages to pure Go after source tools exist.
---

## Purpose

`v0.1.3` turns source-checked `.gx` packages into pure `.go` files and
deterministic Core render output. It depends on `bus gx fmt` and `bus gx lint`
from `v0.1.2`, so template fixtures can be formatted and linted before compile
and render tests are added.

## Deliverables

1. Provide `bus gx compile` to lower `.gx` source into generated `.go`.
2. Compile static GX nodes, attributes, text, and child structure into Go code
   that uses `github.com/busdk/bus-gx/pkg/gx`.
3. Provide `bus gx render` for a named template entry.
4. Reuse the `v0.1.2` parser and diagnostics instead of creating a second GX
   grammar.
5. Keep data, bindings, runtime config, events, and local component expansion
   outside this version.

## Compile Contract

The compiler lowers static nodes, static attributes, dynamic text slots, and
dynamic attribute slots into pure Go that calls the [v0.1.1 shared
interfaces](../v0.1.1/interfaces). The generated file is ordinary Go source
and should be testable with `go test` without requiring a browser, controller,
binding document, or fixture runtime file.

Template source and generated Go are separate artifacts. The `.gx` file is the
human-authored structure. The generated `.go` file contains constructors,
render helpers, source locations, and diagnostics metadata, and it depends on
Core render APIs rather than product services.

`bus gx render` is a static render check for a named template entry. It uses
the generated Go and the deterministic [v0.1.1 renderer](../v0.1.1/interfaces)
to produce escaped HTML.

## Minimal Render

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx

bus gx compile hello.gx --output hello_gx.go

bus gx render hello.gx --entry hello --format html
```

The render output is deterministic HTML equivalent to:

```html
<p>Hello Bus</p>
```

## Success Check

Compile tests compare generated Go against a stable golden file, run `go test`
on the generated file, and compare exact escaped render output with stable
attribute order. The compiler and renderer do not read data, binding, runtime,
or controller code in this version.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node concept](../v0.1.1/node)
- [v0.1.2 GX source tools](../v0.1.2/)

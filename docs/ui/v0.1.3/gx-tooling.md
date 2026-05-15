---
title: GX tooling
description: Formatting, linting, diagnostics, and validation tools for Bus UI GX files.
---

## Purpose

GX tooling makes `.gx` Go packages practical for humans and AI agents. A `.gx`
file is standard Go except for GX markup literals. The tools separate source
maintenance and compilation from full render validation so an agent can format,
inspect, and repair template source before it has complete data, binding, or
runtime fixtures.

`bus-gx` owns the `bus gx` command surface and the low-level GX libraries.
Concrete command behavior lives in the version page where the command first
appears.

## Versioned Commands

| Command | Input | Writes Files | Use |
| --- | --- | --- | --- |
| `bus gx fmt` | `.gx` source files or directories | Yes | [v0.1.2 GX source tools](../v0.1.2/) |
| `bus gx fmt --check` | `.gx` source files or directories | No | [v0.1.2 GX source tools](../v0.1.2/) |
| `bus gx lint` | `.gx` source files or directories | No | [v0.1.2 GX source tools](../v0.1.2/) |
| `bus gx lint --format json` | `.gx` source files or directories | No | [v0.1.2 GX source tools](../v0.1.2/) |
| `bus gx compile` | `.gx` source package | Yes | [v0.1.3 GX compiler](../v0.1.3/) |
| `bus gx render` | `.gx` source package and entry name | No | [v0.1.3 GX compiler](../v0.1.3/) |

## Agent Workflow

An AI agent editing GX source uses the checks available in the current version.

Run this sequence from the Go package that owns the `.gx` file:

Replace `notes.gx` with the real GX source file, `notes_gx.go` with the
generated Go output path for that package, and `notesReview` with a template
entry declared in the source file.

```sh
bus gx fmt --check notes.gx

bus gx lint --format json notes.gx

bus gx compile notes.gx --output notes_gx.go

bus gx render notes.gx --entry notesReview --format html

go test ./...
```

Success means each command exits `0`; `bus gx lint --format json` prints an
empty diagnostics array; `bus gx compile` writes the generated Go file; `bus gx
render` prints deterministic escaped HTML to stdout; and `go test ./...`
passes against the generated file. A failing command must be fixed before
running later commands.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [v0.1.2 GX source tools](../v0.1.2/)
- [v0.1.3 GX compiler](../v0.1.3/)

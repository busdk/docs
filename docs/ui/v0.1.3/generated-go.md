---
title: Generated Go
description: BusDK UI v0.1.3 generated Go artifact shape.
---

## Contract

The generated file is ordinary Go source in the same package as the `.gx`
file. It uses `github.com/busdk/bus-gx/pkg/gx` and the
[v0.1.1 shared interfaces](../v0.1.1/interfaces) to construct validated nodes.

Generated Go contains:

- the original top-level Go declarations with GX markup expressions lowered to
  ordinary `gx.Node` expressions
- source-location metadata needed for diagnostics
- deterministic code formatting suitable for `gofmt`

The generated file must be testable with `go test ./...` without a browser,
controller, fixture runtime, or provider service.

## Artifact Boundary

The `.gx` file remains the human-authored template source. The generated `.go`
file is a build artifact that can be regenerated from source and compared in
golden tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Compile command](./compile-command)
- [Node concept](../v0.1.1/node)

---
title: Shared interfaces
description: BusDK UI v0.1.1 shared Go interfaces.
---

## Purpose

The first `pkg/gx` API defines small Go interfaces so [Text](./text),
[Element](./element), [Fragment](./fragment), and [VNode](./v-node) can be used
through the same [Node](./node) boundary. These interfaces are library
contracts only; they do not introduce command-line tooling, custom components,
component composition, controllers, or events.

## Contracts

| Interface | Method | Behavior |
| --- | --- | --- |
| `Node` | `VNode() (VNode, error)` | Normalizes a concrete node value into a validated [VNode](./v-node). |
| `Renderer` | `RenderHTML(Node) (string, error)` | Renders a validated [Node](./node) to deterministic escaped HTML. |

`Text`, `Element`, `Fragment`, and `VNode` implement `Node`. `HTMLRenderer`
implements `Renderer`. The package exposes
`RenderHTML(Node) (string, error)` as the default deterministic renderer for
simple tests and call sites; it validates the node before returning escaped
HTML.

`RenderHTML` is the only renderer required in this version. Browser mounting,
incremental updates, keyed children, runtime hooks, and raw HTML trust
boundaries are not part of this interface set.

## Go Shape

```go
type Node interface {
	VNode() (VNode, error)
}

type Renderer interface {
	RenderHTML(Node) (string, error)
}
```

```go
var renderer gx.Renderer = gx.HTMLRenderer{}
html, err := renderer.RenderHTML(gx.Text("safe <text>"))
```

The interface boundary keeps `bus-ui` code independent from concrete
constructors. A higher-level component can return `gx.Node`, and tests can
compare the resulting [VNode](./v-node) or rendered HTML.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)
- [VNode](./v-node)
- [Core node acceptance](./acceptance)

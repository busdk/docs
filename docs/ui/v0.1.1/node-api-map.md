---
title: UI node API map
description: BusDK UI v0.1.1 Go API checklist for Node, Props, VNode, and rendering.
---

## Contract

Go callers use the `github.com/busdk/bus-gx/pkg/gx` package. This patch exposes
only the first render-tree API surface:

| API | Page | Purpose |
| --- | --- | --- |
| `Node` | [Shared interfaces](./interfaces) | Normalizes concrete values to validated virtual nodes. |
| `Renderer` and `RenderHTML` | [Shared interfaces](./interfaces) | Render validated nodes to deterministic escaped HTML. |
| `VNode` | [VNode](./v-node) | Stores the normalized immutable node shape used by renderers and tests. |
| `Text` | [Text](./text) | Creates escaped scalar text nodes. |
| `Element` | [Element](./element) | Creates safe lowercase structural HTML nodes. |
| `Fragment` | [Fragment](./fragment) | Groups ordered children without output wrappers. |
| `Props` | [Props](./props) | Stores deterministic validated attributes. |

## Consequence

The API is library-only. It has no `bus gx` CLI, source parser, custom
component registry, binding system, event dispatcher, lifecycle runtime, or
browser mount API in this patch.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node UI concept](./node)
- [Shared interfaces](./interfaces)
- [VNode](./v-node)

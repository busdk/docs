---
title: UI render tree contract
description: BusDK UI Node and VNode architecture contract.
---

## Contract

`bus-gx` owns the render tree. The first concrete contract is this Core
foundation: [Text](./text), [Element](./element), [Fragment](./fragment),
[Props](./props), [VNode](./v-node), and [shared interfaces](./interfaces).

This patch excludes raw content, keyed updates, browser mounting, browser
hydration, event handling, lifecycle hooks, and runtime hooks. Those features
are rejected during node validation in v0.1.1; the renderer must not ignore
them or silently pass them through.

Rendering is escaped and deterministic by default. Text content is escaped by
[Text](./text), attributes are validated and serialized in stable order by
[Props](./props), and [Element](./element) only accepts lowercase
HTML-compatible tags from the current allowlist. Raw HTML, inline JavaScript,
template execution, shell execution, and untrusted expressions have no node
shape in this patch.

Component authors build nodes with the concrete Core shapes:

| Shape | Implementation rule |
| --- | --- |
| [Text](./text) | Carries only escaped text content. |
| [Element](./element) | Uses a lowercase tag, [Props](./props), and ordered child nodes. |
| [Fragment](./fragment) | Groups ordered child nodes without adding a wrapper. |
| [VNode](./v-node) | Stores the normalized immutable node used by renderers and tests. |
| [Props](./props) | Uses `gx.Props` entries directly; omitted entries use their zero behavior, and required values must be validated before constructing the node. |

## Consequence

Components should return nodes that normalize to [VNode](./v-node) before
rendering. That keeps server rendering and unit-test inspection on the same
tree without adding browser behavior to this patch.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node UI concept](./node)
- [Shared interfaces](./interfaces)
- [Props reference](./props)

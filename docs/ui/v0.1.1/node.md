---
title: Node UI concept
description: Dedicated BusDK UI framework concept page for Node.
---

## Purpose

A node is the smallest renderable unit in the framework. The Go package exposes
nodes through [shared interfaces](./interfaces) so concrete values can normalize
to [VNode](./v-node). [Text](./text) renders literal escaped text.
[Element](./element) is an allowed HTML tag with validated attributes.
[Fragment](./fragment) groups children without adding a wrapper.
[VNode](./v-node) is the serialized node form used by the deterministic HTML
renderer and tests.

## Boundary

Use nodes to keep server-rendered HTML and unit-test inspection aligned. Prefer
[Text](./text) or [Element](./element) by default.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

node := gx.Element("p",
	gx.Props{"class": "message"},
	gx.Text("Hello <Bus>"),
)
```

The rendered output is equivalent to:

```html
<p class="message">Hello &lt;Bus&gt;</p>
```

## Contract

Nodes must render deterministically: [Text](./text) is escaped,
[Props](./props) are sorted, unsafe attribute names are rejected, and
[Fragment](./fragment) does not add wrapper output.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Core foundation](./)
- [Shared interfaces](./interfaces)

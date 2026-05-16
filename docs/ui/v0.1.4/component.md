---
title: Components
description: BusDK UI v0.1.4 reusable GX component concept.
---

## Purpose

A component defines a reusable Bus UI tag. `bus-gx` Core components are enough
to build safe HTML-compatible trees from completed node and GX compiler pieces.
[Uppercase tag names](./component-tags) resolve to
[Go component functions](./component-functions), so `<Notice>` is a component
call while lowercase `<section>` is a safe element name. Props are typed Go
struct fields, and nodes are the renderable output.

## Boundary

Use components when repeated structure can be expressed from existing Core
[nodes](../v0.1.1/node), [props](../v0.1.1/props),
[template entries](../v0.1.3/template-entries), and typed Go component
functions. A component owns presentation defaults, typed props, and emitted
child nodes. Product authority, provider response interpretation, host routing,
resources, effects, and callback behavior stay outside this patch.

## Example

```gx
package reviewui

import "github.com/busdk/bus-gx/pkg/gx"

type StatusSummaryProps struct {
	Label string
}

func StatusSummary(p StatusSummaryProps) gx.Node {
	return gx.Element("section", gx.Props{
		"class": "bus-status-summary",
	}, gx.Element("span", nil, gx.Text(p.Label)))
}
```

```gx
package reviewui

var reviewSummary = (
  <StatusSummary label={"Review status"}></StatusSummary>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Component calls](./)
- [Component functions](./component-functions)
- [Node concept](../v0.1.1/node)

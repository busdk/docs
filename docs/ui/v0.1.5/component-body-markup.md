---
title: Component body markup
description: BusDK UI v0.1.5 GX markup inside Go component functions.
---

## Purpose

`v0.1.5` lets component authors implement reusable components with GX markup
inside ordinary Go functions. This builds on [component calls](../v0.1.4/)
without adding a component registry or a separate template document format.

## Contract

Markup expressions are valid in Go function and method bodies that return
`gx.Node`. The compiler lowers only the markup expression and preserves the
surrounding Go function shape:

```gx
package notices

import "github.com/busdk/bus-gx/pkg/gx"

type NoticeProps struct {
	Message string
}

func Notice(p NoticeProps) gx.Node {
  return (
    <section class="bus-notice">
      <span>{p.Message}</span>
    </section>
  )
}
```

The generated Go keeps `Notice` as the component function:

```go
func Notice(p NoticeProps) gx.Node {
	return gx.Element("section", gx.Props{
		"class": "bus-notice",
	}, gx.Element("span", nil, gx.Text(p.Message)))
}
```

## Boundary

Data reaches markup through ordinary Go lexical scope, function arguments, and
typed props. The Go compiler checks those expressions after `bus gx compile`.
Functions that return `(gx.Node, error)` are outside the v0.1.x component
model; application code should handle errors before rendering.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [v0.1.4 component calls](../v0.1.4/component-reference)
- [Expression children](./expression-children)

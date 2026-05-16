---
title: Expression children
description: BusDK UI v0.1.5 Go expressions inside markup bodies.
---

## Contract

Braced values inside a markup body are ordinary Go expressions. A string
expression becomes escaped text. A `gx.Node` expression becomes one child node.
A `[]gx.Node` expression is spliced in source order:

```gx
package notices

import "github.com/busdk/bus-gx/pkg/gx"

func NoticeText(message string) gx.Node {
  return <span>{message}</span>
}
```

```gx
package notices

import "github.com/busdk/bus-gx/pkg/gx"

func Wrap(nodes []gx.Node) gx.Node {
  return <section>{nodes}</section>
}
```

The compiler does not evaluate these expressions. It lowers them into Go and
lets the Go compiler check names, field access, and types.

An expression whose type is not assignable to `string`, `gx.Node`, or
`[]gx.Node` is not a child expression. Values such as `int`, `bool`, `nil`,
`[]string`, and `fmt.Stringer` fail validation when type information is
available, or fail generated Go compilation otherwise. Authors must convert
those values to `string` or `gx.Node` explicitly.

## Boundary

This patch keeps expressions Go-only. The compiler lowers them into generated
Go without adding another expression language.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component body markup](./component-body-markup)
- [v0.1.3 generated Go](../v0.1.3/generated-go)

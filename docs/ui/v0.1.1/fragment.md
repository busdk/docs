---
title: Fragment node
description: BusDK UI v0.1.1 fragment node reference.
---

## Purpose

`Fragment` is a [Node](./node) group without a wrapper element.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `children` | yes | [Node](./node) list | Rendered in order. |

## Boundary

No extra wrapper appears in the rendered tree.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

node := gx.Fragment(
	gx.Text("First"),
	gx.Text("Second"),
)
```

The rendered output is:

```html
FirstSecond
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)

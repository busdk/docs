---
title: Text node
description: BusDK UI v0.1.1 escaped text node reference.
---

## Purpose

`Text` is an escaped scalar [Node](./node). Use for labels, messages, cells,
and captions. It never accepts trusted HTML.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `value` | yes | string, number, or boolean | Escaped before rendering. |

## Boundary

Rendered text is escaped and contains no raw markup.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

node := gx.Text("Hello <Bus>")
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)

---
title: Component calls
description: BusDK UI v0.1.4 lowered component call shape.
---

## Purpose

An uppercase GX tag lowers to a Go callable component call. The selected
[component function](./component-functions) owns the typed prop contract used
by the call. The callable may read provided props for rendering, but it must
not mutate product state, call providers, perform permission decisions, or
infer business policy.

## Inputs

| GX input | Go target | Behavior |
| --- | --- | --- |
| Uppercase tag name | Go callable | `<StatusSummary>` calls `StatusSummary`. Unknown functions or method values fail lint. |
| Attributes | exported props fields | `status="warning"` or `status={"warning"}` fills `Status`. Missing required fields and unknown fields fail lint. |

## Boundary

Business state is outside this patch. v0.1.4 accepts literal props, while body
children are outside this patch. The lowered call is not a persistent
`Component` node kind; it is a Go call that returns ordinary
[nodes](../v0.1.1/node).

## Generated Expression

```gx
package reviewui

var summary = <StatusSummary status={"warning"}></StatusSummary>
```

The compiler lowers the markup expression, not the surrounding Go declaration.
A variable initialized with markup remains a variable initialized with a
`gx.Node` expression:

```go
var summary = StatusSummary(StatusSummaryProps{
	Status: "warning",
})
```

The selected `StatusSummary` function's props type validates `Status`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component call patch](./custom-components)
- [Source-tool integration](../v0.1.3/source-tool-integration)

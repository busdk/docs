---
title: UI testkit renderer
description: BusDK UI v0.1.20 deterministic renderer helpers for GX and Bus UI components.
---

## Contract

`v0.1.20` adds deterministic renderer helpers for pure Go component tests.
The helpers render GX nodes, normalize attributes, compare trees, and produce
compact diffs that point to the failing element.

```go
func TestCounter(t *testing.T) {
	app := uikittest.Render(t, Counter())

	app.AssertHTML(`<button>Count 0</button>`)
	app.AssertElement("button", uikittest.HasText("Count 0"))
	app.AssertCallback("button", "onClick")
}
```

Renderer tests should assert semantic output before broad snapshots. Stable
snapshots are still useful for compact component states when they normalize
attribute order, callback tokens, whitespace, and escaped text.

## Requirements

- Render helpers use the same node contract as [v0.1.1](../v0.1.1/).
- Attribute ordering and callback-token assertions are deterministic.
- Tree comparison reports the node path, expected value, and actual value.
- Snapshot diffs are readable without a browser.
- Tests can assert state updates from [UseState](../v0.1.17/use-state) and
  event helpers from [v0.1.19](../v0.1.19/event-form-helpers).

## Boundary

This patch does not provide a browser fixture, fake browser globals, resource
clients, or e2e helpers. It only covers renderer and pure Go component tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core test helpers](../v0.1.10/test-helpers)
- [UseState](../v0.1.17/use-state)
- [Event and form helpers](../v0.1.19/event-form-helpers)

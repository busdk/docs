---
title: Component UI concept
description: Dedicated BusDK UI framework concept page for Component.
---

## Purpose

A component turns props, slots, and view-model data into nodes. Props are
validated named inputs, slots are caller-supplied child regions, view-model data
is product-shaped data already safe to render, and nodes are the renderable
output consumed by HTML, Go/WASM, and test renderers. A component owns generic
UI structure, not product authority.

## Boundary

Use components when two modules need the same control, surface, or layout. Keep
product-specific labels, permissions, data fetching, authorization decisions,
and provider response interpretation in the calling view model or handler.

## Example

```yaml
kind: Component
props:
  name: StatusSummary
  status: { bind: review.status }
  label: Review status
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./node">Node</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shell">Shell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)

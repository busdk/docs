---
title: Component UI concept
description: Dedicated BusDK UI framework concept page for Component.
---

## Purpose

A component defines a reusable Bus UI tag. `bus-gx` Core components are enough
to build safe HTML-compatible trees from completed node and GX compiler pieces.
Uppercase tag names resolve through the component registry, so `<Notice>` is a
component while lowercase `<section>` is a safe element name. Props are
validated named inputs, slots are caller-supplied child regions, and nodes are
the renderable output.

## Boundary

Use components when repeated structure can be expressed from existing Core
nodes, props, templates, and slots. A component owns presentation defaults,
validated props, slot placement, and emitted child nodes. Product authority,
provider response interpretation, host routing, resources, effects, and
controller handler selection stay outside the component definition.

## Example

```gx
package reviewui

component StatusSummary(label) = (
  <section class="bus-status-summary">
    <span>{label}</span>
  </section>
)

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
- [Custom components](./)
- [Node concept](../v0.1.1/node)

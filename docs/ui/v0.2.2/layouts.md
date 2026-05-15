---
title: Library layouts
description: BusDK UI library layout components for stable pane and navigation structure.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Layout components arrange existing content without owning product meaning.
[`SplitLayout`](./split-layout) is for list/detail, evidence, or
pane-based workflows that need stable pane sizing. [`SidebarNav`](./sidebar-nav)
renders stable navigation inside a shell slot.

Layouts should not fetch data, decide permissions, or create product routes.
They consume already-projected items, selected ids, slots, and event names.

## Consequence

Product modules keep workflow state in view models. Layouts keep screen
structure stable across render targets.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI layout](./layout)
- [SidebarNav](./sidebar-nav)
- [SplitLayout](./split-layout)

---
title: UI density and typography
description: BusDK UI design rule for compact operational typography.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)

## Rule

Use compact text inside operational surfaces. Hero-scale type belongs only to
true public entry pages, not forms, sidebars, dashboards, panels, or workbench
views.

Labels should be short and precise. Long explanations belong in documentation,
not inside the main app flow.

Letter spacing should be normal. Do not scale font size directly with viewport
width.

## Consequence

Use responsive layout changes, wrapping, and constrained containers. Text in
buttons and table cells must fit without overlapping adjacent controls.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI design system](../v0.2.0/design-system)

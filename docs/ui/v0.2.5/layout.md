---
title: UI layout
description: BusDK UI rule for common layout helpers and stable surfaces.
---

## Design References

- [UI design system](../v0.2.0/design-system)

## Rule

Use full-page shells for applications and reusable panels for bounded tools.
Panels organize work; they should not decorate it.

Do not nest UI cards inside other cards. Prefer full-width bands or split
panes for page sections. Reserve cards for repeated items, modals, summaries,
and genuinely framed tool surfaces.

Common layouts are split list/detail views, sidebar navigation, data tables
with filter toolbars, and bounded panels. Assistant shells, terminal panels,
and portal-host frames belong to later higher-level libraries.

## Consequence

Fixed-format elements such as toolbars, icon buttons, counters, table rows, and
tiles need stable dimensions or responsive constraints so dynamic labels,
icons, and loading states do not resize the surrounding layout.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference

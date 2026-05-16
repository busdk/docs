---
title: UI layout
description: BusDK UI rule for common layout helpers and stable surfaces.
---

## Design References

- [UI design system](../v0.2.0/design-system)

## Rule

Use a full-page shell when a view owns navigation, global actions, and the main
content region. Use a reusable panel when a view needs one bounded tool region,
such as a filter area, editor, preview, or settings group. Panels organize
work; they should not decorate it.

Do not nest UI cards inside other cards. Prefer full-width bands or split
panes for page sections. Reserve cards for repeated items, modals, summaries,
and genuinely framed tool surfaces.

Common layouts:

- Split list/detail views keep a selectable collection beside the selected
  record preview or editor.
- Sidebar navigation keeps primary destinations in a stable side region while
  the main content changes.
- Data tables with filter toolbars keep query controls directly above the
  rows they affect.
- Bounded panels group a single tool, form, preview, or status region without
  creating another page section.

Assistant shells, terminal panels, and portal-host frames belong to later
higher-level libraries.

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

- [Panel](../v0.2.4/panel)

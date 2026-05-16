---
title: Library navigation
description: BusDK UI library links, menus, tabs, and navigation controls.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Navigation controls move between views or select one view from a bounded set.
[`LinkButton`](../v0.2.2/link-button) is for safe navigation or artifact
open/download navigation. [`Menu`](./menu) is for bounded option
sets. [`Tabs`](./tabs) switches sibling views.

In `v0.2.3`, navigation targets are same-origin paths, relative paths,
fragments, or static `https:` URLs. Unsafe schemes fail validation before
render. Runtime URL resolution and origin allowlists are unavailable in
`v0.2.3`; pages that need dynamic resource URLs must pass already-validated
string targets into these components.

## Consequence

Navigation components render available movement. Product modules own route
meaning, permissions, and selected state.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [LinkButton](../v0.2.2/link-button)
- [Menu](./menu)
- [Tabs](./tabs)

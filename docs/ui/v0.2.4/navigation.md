---
title: Library navigation
description: BusDK UI library links, menus, tabs, and navigation controls.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Navigation controls move between views or select one view from a bounded set.
[`LinkButton`](./link-button) is for safe navigation or artifact
open/download navigation. [`Menu`](./menu) is for bounded option
sets. [`Tabs`](./tabs) switches sibling views.

Navigation targets must be same-origin paths, URLs produced by a named host
resolver from runtime config, or `https:` URLs whose exact
scheme, host, and port match an `allowedOrigins` entry in the host
API URL resolution config.
Invalid targets fail validation before render. When navigation is event-driven,
the control emits event identity and the controller decides the final
navigation request.

## Consequence

Navigation components render available movement. Product modules own route
meaning, permissions, and selected state.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [LinkButton](./link-button)
- [Menu](./menu)
- [Tabs](./tabs)

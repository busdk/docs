---
title: Library shells
description: BusDK UI library page and application shell components.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Shell components define durable application chrome and top-level slots. A
product module should not build full-page boilerplate by hand when a shared
shell fits the host.

[`AppShell`](./app-shell) is for standalone local apps.
[`PortalShell`](./portal-shell) is for portal-mounted feature
modules that receive host paths, assets, and runtime config from `bus-portal`.
[`SidebarShell`](./sidebar-shell) is for multi-view apps with
stable navigation slots. [`AssistantShell`](./assistant-shell) is
for a business surface paired with an assistant pane.

## Consequence

Feature modules provide product content. Hosts and shared shells provide
chrome, route context, asset links, and slot ownership.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Shell UI concept](./shell)
- UI component reference

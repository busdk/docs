---
title: Library shells
description: BusDK UI library page and common application shell components.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Shell components define durable application chrome and top-level slots. They
are still common components: they frame supplied content without owning
assistant behavior, portal hosting, terminal sessions, or product workflow
policy.

[`AppShell`](./app-shell) is for standalone local apps.
[`SidebarShell`](./sidebar-shell) is for multi-view apps with stable navigation
slots. Higher libraries can compose these shells with assistant, terminal, or
portal-specific surfaces after those libraries exist.

## Consequence

Feature modules provide product content. Hosts and shared shells provide
chrome and slot ownership.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Shell UI concept](./shell)
- UI component reference

---
title: SidebarShell UI component
description: Dedicated BusDK UI reference for SidebarShell.
---

## Purpose

`SidebarShell` is a shell/layout component. Collapsible multi-view shell. Use for dense tools with persistent navigation.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `header` | yes | slot node or escaped text | Top shell content. Usually contains title, account context, or compact controls. Empty header fails validation. |
| `nav` | yes | `SidebarNav` node | Navigation region. The node must be a valid `SidebarNav` component or compatible host-provided navigation node with accessible labels. |
| `body` | yes | slot node | Main content region. Must be a single node or fragment; missing body fails validation. |
| `collapsed` | no | boolean | Defaults false. When true, the sidebar renders compact navigation with icons and accessible labels while keeping the body region unchanged. Items without icons still expose labels to assistive technology and may show labels on focus/hover depending on host styling. |
| `icon` | no | icon name | App launcher icon from the shared [Icon](./icon) catalog or host-registered icon set. Omitted renders no launcher icon; unknown names render no icon and report a non-fatal validation warning. |

## Boundary

Collapsed mode keeps accessible labels.

## Example

```yaml
kind: SidebarShell
props:
  collapsed: false
slots:
  header:
    kind: Text
    props: { text: Notes }
  nav:
    kind: SidebarNav
    props:
      items: { bind: nav.items }
  body:
    kind: Panel
    props: { title: Current view }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./portal-shell">PortalShell</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./sidebar-nav">SidebarNav</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

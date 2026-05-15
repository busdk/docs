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
| `nav` | yes | `SidebarNav` node | Navigation region. The node must be a valid `SidebarNav` component or host-provided navigation node with accessible labels. |
| `body` | yes | slot node | Main content region. Must be a single node or fragment; missing body fails validation. |
| `collapsed` | no | boolean | Defaults false. When true, the sidebar renders compact navigation with icons and accessible labels while keeping the body region unchanged. Items without icons still expose labels to assistive technology and may show labels on focus/hover depending on host styling. |
| `icon` | no | icon name | App launcher icon from the shared Icon catalog or host-registered icon set. Omitted renders no launcher icon; unknown names render no icon and report a non-fatal validation warning. |

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
    props:
      text: Notes
  nav:
    kind: SidebarNav
    props:
      items:
        bind: nav.items
  body:
    kind: Panel
    props:
      title: Current view
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

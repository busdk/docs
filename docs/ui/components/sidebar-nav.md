---
title: SidebarNav UI component
description: Dedicated BusDK UI reference for SidebarNav.
---

## Purpose

`SidebarNav` is a shell/layout component. Sidebar navigation list. Use inside `SidebarShell` for stable modes or routes.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array | Each item has non-empty `label` plus exactly one of `href` or `action`. Items missing both or containing both fail validation. |
| `items[].label` | yes | string | Visible and accessible navigation label. Empty labels fail validation, including compact mode where an icon is shown. |
| `items[].href` | required when no action | path string or `{base,path}` route resolver | Navigates to a route. Strings may be same-origin absolute paths or relative module routes. Resolver objects use `base: portal`, `base: module`, or a named host route resolver plus `path` beginning with `/`. `javascript:`, `data:`, path traversal, and unallowlisted external origins fail validation. |
| `items[].action` | required when no href | action token | Dispatches a declared action token from the document `actions` map or registered Go/WASM handler map. Unknown tokens fail validation. |
| `items[].icon` | no | icon name | Shown in compact mode. Names must come from the shared [Icon](./icon) catalog or host-registered icon set. Unknown icons render the text label only and report a non-fatal validation warning. |
| `items[].active` | no | boolean | Marks active item. Omitted means false. At most one active item is allowed; multiple active items fail validation instead of being resolved implicitly. |

## Boundary

Every item has a visible or accessible label.

## Example

```yaml
kind: SidebarNav
props:
  items:
    - { label: Notes, href: ./, active: true }
    - { label: Review, href: ./review }
```

## Runtime Terms

Sidebar links accept relative module routes, same-origin absolute paths
beginning with `/`, or host route resolver objects supplied through the portal
context. External `https:` links are rejected unless the host explicitly enables
the origin in its navigation URL allowlist before rendering. `javascript:`,
`data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./sidebar-shell">SidebarShell</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./split-layout">SplitLayout</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

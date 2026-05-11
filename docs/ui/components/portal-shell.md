---
title: PortalShell UI component
description: Dedicated BusDK UI reference for PortalShell.
---

## Purpose

`PortalShell` is a shell/layout component. Portal-mounted feature frame. Use for feature modules mounted by `bus-portal`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or binding | Module page title. |
| `body` | yes | slot node | Feature content. |
| `hostContext` | yes | object from portal host | Supplies base paths and assets. In portal-mounted documents the host injects this prop before validation; standalone examples must bind or provide it explicitly. |
| `nav` | no | array of `{label,path,current}` | Module navigation. `label` is non-empty text, `path` is a same-origin path beginning with `/` or a host-resolved route from `hostContext`, and optional `current` marks the active item. Omitted `nav` renders no module nav. Unknown fields, empty labels, path traversal, and external URLs fail validation. |

## Boundary

Assets and deployment-specific base paths come from `hostContext`, not
hard-coded strings. Literal same-origin module routes such as `/notes` are valid
for stable portal paths owned by the mounted module; generated asset URLs,
tenant/account prefixes, and externally mounted base paths must be resolved
through the host context.

## Example

```yaml
kind: PortalShell
props:
  title: Notes
  hostContext: { bind: portal.hostContext }
  nav:
    - label: Notes
      path: /notes
      current: true
slots:
  body:
    kind: DataTable
    props:
      rows: { bind: notes }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./app-shell">AppShell</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./sidebar-shell">SidebarShell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

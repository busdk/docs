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
| `hostContext` | yes | object from portal host | Supplies base paths and assets. In portal-mounted documents the host injects this prop before validation; standalone examples must bind or provide it explicitly. The object requires `moduleBase` and `assetBase` same-origin path prefixes beginning and ending with `/`; optional `apiBase` must be a same-origin path prefix, and optional `externalNavOrigins` entries must be exact `https:` origins. Unknown sensitive-looking keys fail validation. |
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
  hostContext:
    bind: portal.hostContext
  nav:
    - label: Notes
      path: /notes
      current: true
slots:
  body:
    kind: DataTable
    props:
      rows:
        bind: notes
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

Resource defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

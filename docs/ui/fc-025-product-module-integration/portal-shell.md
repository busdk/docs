---
title: PortalShell UI component
description: Dedicated BusDK UI reference for PortalShell.
---

## Purpose

`PortalShell` is a shell/layout component. Portal-mounted feature frame. Use for feature modules mounted by `bus-portal`.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or Go value | Module page title. |
| `body` | yes | slot node | Feature content. In GX, child markup inside `<PortalShell>...</PortalShell>` fills this slot. |
| `hostContext` | yes | object from portal host | Supplies base paths and assets. In portal-mounted documents the host injects this prop before validation; standalone examples must bind or provide it explicitly. The object requires `moduleBase` and `assetBase` same-origin path prefixes beginning and ending with `/`; optional `apiBase` must be a same-origin path prefix, and optional `externalNavOrigins` entries must be exact `https:` origins. Unknown sensitive-looking keys fail validation. |
| `nav` | no | `[]NavItem` | Module navigation. `NavItem.Label` is non-empty text, `NavItem.Path` is a same-origin path beginning with `/` or a host-resolved route from `hostContext`, and `NavItem.Current` marks the active item. Omitted `nav` renders no module nav. Unknown fields, empty labels, path traversal, and external URLs fail validation. |

## Boundary

Assets and deployment-specific base paths come from `hostContext`, not
hard-coded strings. Literal same-origin module routes such as `/notes` are valid
for stable portal paths owned by the mounted module; generated asset URLs,
tenant/account prefixes, and externally mounted base paths must be resolved
through the host context.

## Example

```gx
package notesui

import (
  "github.com/busdk/bus-gx/pkg/gx"
  . "github.com/busdk/bus-ui/pkg/uiportal"
)

var notesNav = []NavItem{
  {Label: "Notes", Path: "/notes", Current: true},
}

func NotesShell(hostContext HostContext) gx.Node {
  return (
    <PortalShell
      title="Notes"
      hostContext={hostContext}
      nav={notesNav}
    >
      <p>Notes</p>
    </PortalShell>
  )
}
```

The portal host passes `hostContext` when it mounts the module.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[`Resource`](../fc-003-resources/resource) defines safe URL resolution,
external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

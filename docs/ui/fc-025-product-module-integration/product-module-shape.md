---
title: Product module shape
description: BusDK UI product module structure for Go contracts, view models, deterministic rendering, and event projection.
---

## Overview

A product module owns product-specific data projection and browser behavior. It
does not own the portal host, provider authorization, token handling, shared
assets, or security headers. The module exposes its UI through Go contracts so
the host can mount it, pass runtime context, publish metadata, and run
deterministic fixture tests.

## Contract

A compact module keeps three concerns separate. Provider adapters convert API
DTOs and provider errors into safe product facts. View-model builders derive
visible state from those facts, permissions, route input, and request context.
UI framework pages compose shared Bus UI primitives from the view model and
declare the browser hooks that may project events back into Go.

The module still implements the host-facing `portal.Module` interface from the
`bus-portal/pkg/portal` package. A GX-ready module also implements
`portal.FrameworkModule` when it can publish Go-first framework pages,
deterministic render roots, optional Go/WASM runtime metadata, public runtime
configuration, provider origins, same-origin assets, and browser event hooks
through the [`UIFramework`](./portal-modules) contract.

```go
// Excerpt from package portal.
type Module interface {
    ID() string
    Title() string
    State() ModuleState
    DefaultEnabled() bool
    NavItems() []NavItem
    Handler() http.Handler
}

type FrameworkModule interface {
    UIFramework() UIFramework
}
```

Use an HTTP handler when the page can render from request data and ordinary
form submissions. Add a Go WebAssembly runtime only when the page needs
browser-owned state, retained callbacks, streaming updates, drag-and-drop,
terminal input, or another live behavior that cannot be expressed as
deterministic server render plus projected events.

The module layout can be compact:

```text
internal/provideradapter/  provider DTO and public error projection
internal/viewmodel/        screen-ready state, permission display, and copy
internal/ui/               Go and GX framework pages, handlers, and event helpers
```

Framework pages should take ordinary Go inputs. Data reaches GX through Go
values, function arguments, typed props, and host context; it does not require a
YAML/JSON descriptor, binding map, or string selector grammar.

```gx
package notesui

import (
    "github.com/busdk/bus-gx/pkg/gx"
    . "github.com/busdk/bus-ui/pkg/uiportal"
)

type NotesPageProps struct {
    Host  HostContext
    Notes []NoteRow
}

func NotesPage(props NotesPageProps) gx.Node {
    return (
        <PortalShell title="Notes" hostContext={props.Host}>
            <NoteTable rows={props.Notes}></NoteTable>
        </PortalShell>
    )
}
```

## Consequence

Projection tests, component composition, and host routing can evolve in separate
layers. Product modules should not mix provider authority, rendering, and
browser runtime wiring in one package.

The separation is correct when provider authorization is asserted in provider
or API tests, view-model tests run without rendering HTML, `RenderFrameworkPage`
can compare stable server HTML from a fixed model, and `ProjectFrameworkEvent`
can prove that only declared event fields are projected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Portal modules](./portal-modules)
- [UI layer ownership](../v0.1.1/foundation)
- [bus-ui module reference](../../modules/bus-ui)
- [bus-portal module reference](../../modules/bus-portal)

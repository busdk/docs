---
title: UI product module shape
description: BusDK UI feature module structure for adapters, view models, and renderers.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Binding](../v0.1.5/binding)

## Contract

A portal feature module should have three small parts:

1. Data transfer object (DTO) adapters read provider responses and normalize
   error payloads.
2. View-model builders derive visible UI state from DTOs, permissions, request
   context, and route/query input.
3. Renderers compose `bus-ui` blocks from those view models and expose route
   handlers or Go WebAssembly mount functions.

Use route handlers when the screen can render from request data and ordinary
form/event submissions. Use a Go WebAssembly mount only when the screen needs
browser-owned state, retained callbacks, streaming updates, file drops,
terminal input, or other live behavior that cannot be expressed as a
server-rendered route plus events.

The module layout can be compact:

```text
internal/provideradapter/  provider DTO and error normalization
internal/viewmodel/        screen-ready state and permission display
internal/ui/               bus-ui component composition and handlers
```

## Consequence

Projection tests, component composition, and host routing can evolve in
separate layers. Product modules should not mix provider authority, rendering,
and browser runtime wiring in one layer.

The separation is correct when provider authorization is asserted in provider
or API tests, view-model tests can run without rendering HTML, and renderer
tests can run with a fixed view model and fake runtime handlers.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI layer ownership](../v0.1.1/foundation)
- [bus-ui module reference](../../modules/bus-ui)

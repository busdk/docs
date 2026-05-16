---
title: State runtime
description: BusDK UI v0.1.17 scoped Go state helpers for GX function components.
---

## Contract

`v0.1.17` starts the reusable GX framework/runtime packages inside the
`bus-ui` module. The package is built on the handle-scoped scheduling from
[v0.1.13](../v0.1.13/handle-render-scheduling) and gives Go function
components local state without package-global mutable variables.

The first state helpers are [UseState](./use-state), [UseRef](./use-ref), and
[UseMemo](./use-memo). They are available only while a mounted root is
rendering. State is scoped to the mount handle and component position.

## Requirements

- State belongs to one mount handle and one component position.
- Renders remain deterministic when several state updates are queued.
- Unmounted handles release state and callback references.
- Server-side rendering can render the initial state without browser APIs.

## Boundary

This patch does not add effects, resource clients, browser storage policy,
event helper objects, streaming, or terminal behavior. It only defines the
state layer used by later reusable `bus-ui` runtime packages and higher-level
libraries.

`UseCallback` is not part of this patch. Add it only if later incremental
rendering needs stable listener identity or memoized child props.

The `bus-ui` Bus module may host this runtime package and separate higher-level
libraries such as terminal UI. The state package is not the whole `bus-ui`
module, and it should not absorb product workflow state or provider policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core node foundation](../v0.1.1/)
- [Go WASM frontend runtime](../v0.1.7/)
- [Handle render scheduling](../v0.1.13/handle-render-scheduling)

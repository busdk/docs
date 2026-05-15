---
title: UI renderer targets
description: BusDK UI rendering targets for server HTML, Go WebAssembly mounting, and tests.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Reusable view models declare their supported target set from this matrix:

| Target | Required for | Output |
| --- | --- | --- |
| `server-html` | route handlers, static previews, email-like read views | escaped deterministic HTML |
| `go-wasm` | browser-mounted local apps and portal surfaces | Go WebAssembly DOM mount with state updates |
| `test` | unit, fixture, and snapshot checks | deterministic tree and HTML artifacts |

Product modules that use only structural components support all three targets.
Modules that depend on browser-only APIs may document a narrower target set only
when each excluded target has an explicit fallback component or host behavior.

Deterministic server rendering returns HTML strings for route handlers,
snapshots, and simple local portals. Server-rendered output must escape text,
order attributes deterministically, use stable class names, and avoid hidden
browser state.

Go WebAssembly (`go-wasm`) mounting runs the same component functions in the
browser and updates the mounted DOM after state changes. It fits rich local apps
that need event dispatch, polling, file drops, terminal input, assistant
workbench state, or live provider interaction.

The test renderer exposes deterministic artifacts for unit tests. Tests should
assert semantic output, stable event names, important attributes, rendered
states, and view-model projection.

## Consequence

Snapshot tests are useful when they cover one compact fixture state instead of
freezing a whole product page for every change.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- Testing UI apps
- [bus-ui module reference](../../modules/bus-ui)

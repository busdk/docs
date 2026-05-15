---
title: Core lifecycle
description: BusDK UI core mounting and disposal contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Contract

`v0.1.7` lifecycle owns work that starts after mount and must stop
deterministically.

`github.com/busdk/bus-gx/pkg/gx` exposes `type Disposer func()`,
`OnceDispose(disposer Disposer) Disposer`, and
`ChainDisposers(disposers ...Disposer) Disposer`. The creator of a listener,
timer, retained callback, or mounted resource owns its disposer.

Individual `Disposer` implementations own only resource release and should be
safe to call more than once. `OnceDispose` owns idempotence for a single
disposer. `ChainDisposers` owns reverse acquisition order. The mounted runtime
wrapper owns panic recovery and cleanup failure reporting through
`gx.ClientLog`. In v0.1.7, `ClientLog` is the runtime logger interface:

```go
type ClientLog interface {
	Error(event string, fields map[string]string)
}
```

For disposer panics or cleanup failures, the runtime logs event
`ui.disposer.failed`. `ownerID` comes from the mount scope that registered the
disposer. `label` comes from the disposer registration label or defaults to the
callback name. `error` holds cleanup failure text when available, and `panic`
holds recovered panic text when available. Chained disposal continues after a
failure and attempts every remaining disposer. Because `Disposer` has no return
value, failures are reported only through `ClientLog`; panic values are
recovered and converted to the same log event.

`WASMAppScaffold` constructs a Go WebAssembly app from a mount element, runtime
config, session provider, error reporter, logger, and root component. It owns
retained JavaScript callbacks until unmount, registers their disposers, wraps
async callbacks with panic recovery, and fails before mounted state when the
mount element, session provider, or callback registration is missing.

Updates replace the mounted root with a new deterministic node tree and reuse
stable keys where the renderer supports incremental updates. Unmount calls the
root disposer once. Repeated unmounts are no-ops except for safe diagnostics.

## Consequence

Product modules and Go controllers configure resources and application
behavior. Core owns repeatable mount, update, and cleanup behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Effect concept](./effect)

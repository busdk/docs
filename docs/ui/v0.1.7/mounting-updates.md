---
title: UI mounting and updates
description: BusDK UI Go WebAssembly mount ownership and update lifecycle.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Contract

A mounted Go WebAssembly app owns the root element selector, current product view
model or app state, render function, event handler registration, resource
clients, API URL resolution, lifecycle disposers, error reporting, and logging.

The default update behavior is a render from the current view model. In
v0.1.7, state is preserved only for a registered mount scope owned by
`gx.MountRuntime`. The scope key is the component `id` when present; otherwise
it is the deterministic render tree path for that node. If a node has no stable
`id` and its tree path changes, its listeners, callbacks, and local runtime
state are disposed and recreated. Server-rendered fragments do not preserve
state.

Every listener, timer, retained JavaScript callback, and browser subscription
registers a disposer with the mounted app runtime when it is created. The
registration call is:

```go
mountRuntime.RegisterDisposer(ownerID, gx.Disposer(func() {
	// release listener, timer, callback, or subscription
}))
```

`mountRuntime` is the `gx.MountRuntime` passed to the component effect or mount
hook. `ownerID` is a non-empty stable owner key from the component `id` or from
the runtime-provided deterministic tree path. Implementers must call
`RegisterDisposer` immediately after acquiring the resource and before
returning from the effect, mount hook, or callback setup that created it.
Disposers run before the owning effect is replaced, during remount, and during
final unmount.

## Consequence

The disposer chain must be safe to call more than once. A successful update or
remount leaves no retained callbacks for effects that are no longer present in
the rendered tree.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Disposer runtime block](./disposer)
- [Core lifecycle](./)

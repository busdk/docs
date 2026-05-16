---
title: Handle render scheduling
description: BusDK UI v0.1.13 explicit GX mount handles and update scheduling.
---

## Contract

`v0.1.13` makes [Go WebAssembly mounting](../v0.1.7/mounting-updates)
handle-scoped. A mounted root returns a handle that owns update requests for
that root. Application code should prefer the handle over the package-global
`gxwasm.Update()` call.

```go
func main() {
	handle, err := gxwasm.Mount("#app", App)
	if err != nil {
		panic(err)
	}
	defer handle.Unmount()

	save := func() {
		count++
		handle.RequestUpdate()
	}

	_ = save
	select {}
}
```

Each mounted root is independent. Calling `RequestUpdate` on one handle reruns
only that handle's root function. Multiple update requests for the same handle
may be coalesced, but the resulting render order must be deterministic.

The package-global `gxwasm.Update()` remains only as compatibility for the
single-root runtime already documented in [v0.1.7](../v0.1.7/). New code should
pass handles to stateful application code directly.

## Requirements

- `Mount` returns a handle that can request updates and unmount the same root.
- Multiple handles can be mounted at the same time.
- Each handle retains and releases only its own callbacks.
- `RequestUpdate` rerenders from the current Go state by calling the root
  function again.
- Update scheduling is deterministic and testable without product-specific
  state management.
- Failed post-mount renders keep using the redacted diagnostics from
  [v0.1.8](../v0.1.8/diagnostics).

## Boundary

This patch does not add state hooks, effect hooks, resources, event payload
structs, browser storage, or new intrinsic elements. It only gives higher-level
Go runtimes a precise way to request rerenders for the root they own.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go WASM frontend runtime](../v0.1.7/)
- [Runtime diagnostics](../v0.1.8/diagnostics)

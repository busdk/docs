---
title: Effect runtime
description: BusDK UI v0.1.18 Go effect helpers with dependency comparison and cleanup.
---

## Contract

`v0.1.18` adds a small effect runtime to the reusable GX framework/runtime
packages inside `bus-ui`. Effects run after render, compare dependency values,
and call their cleanup function before the effect reruns or the mount handle
unmounts.

```gx
func LiveStatus(client StatusClient) gx.Node {
	status, setStatus := uiruntime.UseState("loading")

	uiruntime.UseEffect(func(ctx context.Context) func() {
		ticker := time.NewTicker(5 * time.Second)
		go func() {
			for {
				select {
				case <-ctx.Done():
					return
				case <-ticker.C:
					setStatus(client.Status(ctx))
				}
			}
		}()
		return ticker.Stop
	}, uiruntime.Deps(client.ID()))

	return <p><Text value={status}></Text></p>
}
```

Effects are ordinary Go functions. Browser-specific work, such as window
listeners, hash listeners, drop handlers, stream readers, timers, close guards,
and storage events, stays behind narrow adapters from the browser boundary
documented in [v0.1.9](../v0.1.9/browser-api-boundaries).

## Requirements

- Effects run after a successful render.
- Dependency comparison is deterministic and documented for comparable scalar
  values, stable ids, and explicit dependency tokens.
- Cleanup runs before a dependency-changing rerun and during unmount.
- Cleanup is idempotent and safe after a failed callback or render diagnostic.
- Server-side rendering records no browser effects.
- Tests can assert effect start, rerun, cleanup, and unmount behavior without a
  real browser.

## Boundary

This patch does not define resource clients, fetch streaming, action dispatch,
terminal protocols, route ownership, or product logging. Effects provide the
lifecycle slot those later helpers use.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Runtime diagnostics](../v0.1.8/diagnostics)
- [Browser API boundaries](../v0.1.9/browser-api-boundaries)
- [Minimal browser adapters](../v0.1.16/minimal-browser-adapters)
- [UseState](../v0.1.17/use-state)

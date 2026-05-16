---
title: Mounting and updates
description: BusDK UI Go WebAssembly mount, callback, and rerender contract.
---

## Contract

A mounted app has one root function and one update queue. The root function
reads ordinary Go state and returns a fresh `gx.Node` tree on each render.
The host page provides the mount element, and application startup registers
the root function with `gxwasm.Mount`:

```go
func run(done <-chan struct{}) error {
	state := &App{}
	mount, err := gxwasm.Mount("#app", state.View)
	if err != nil {
		return err
	}
	defer mount.Unmount()

	<-done
	return nil
}
```

The selector must match an existing browser element before mounting starts.
The Go WebAssembly program must keep running for callbacks to fire; unmount
only during application shutdown.
After mount succeeds, callbacks can update Go state and request a rerender.

```go
type App struct {
	Count int
}

func (a *App) View() gx.Node {
	return Counter(CounterProps{
		Value: a.Count,
		OnClick: func() {
			a.Count++
			gxwasm.Update()
		},
	})
}
```

`gxwasm.Update` schedules one rerender for the current mount. Multiple update
requests in the same browser turn may coalesce into one render. A callback may
also return without updating; in that case no rerender is required.

Callback props are ordinary Go function values from
[v0.1.6](../v0.1.6/callback-props). The runtime wraps function properties on
lowercase rendered elements in JavaScript callbacks when the property maps to
a browser event. For this patch, the browser event surface is intentionally
small:

| GX element/property | Browser event | Callback |
| --- | --- | --- |
| `button onClick` | `click` | `func()` |
| `form onSubmit` | `submit` with default submission prevented | `func()` |
| `input onInput` | `input` | `func(string)` with the current input value |
| `input onChange` | `change` | `func(string)` with the current input value |

The wrapper calls the Go function. Callback functions do not receive framework
event payload structs in this patch.

On rerender, the runtime replaces browser event wrappers for changed nodes and
releases wrappers that are no longer present. It may replace DOM subtrees
instead of diffing them. Incremental reconciliation can be added later without
changing the component authoring model.

## Consequence

The first frontend runtime is enough to build React-like interactive
components in Go: state lives in Go, component functions return nodes, callback
props mutate Go state, and updates rerender the root.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core lifecycle](./lifecycle)
- [Callback props](../v0.1.6/callback-props)

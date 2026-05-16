---
title: Core lifecycle
description: BusDK UI Go WebAssembly mount lifecycle.
---

## Contract

`v0.1.7` adds the first Go WebAssembly frontend runtime for GX. It mounts a
root Go function component into a browser element, renders its `gx.Node` tree,
wires callback props to browser events, and rerenders after Go state changes.

The runtime stays small. It does not define effects, resources, polling,
streaming, close guards, logging transports, or host configuration files.
Application code owns state, side effects, API calls, and logging in ordinary
Go.

The runtime owns only:

1. locating one mount element;
2. calling the root Go function component;
3. rendering the returned node tree into the DOM;
4. retaining JavaScript callback wrappers for function props;
5. rerendering when application code requests an update;
6. releasing retained callback wrappers on unmount.

The root component is an ordinary Go function:

```go
func App() gx.Node
```

Mounting uses a small Go API:

```go
app, err := gxwasm.Mount("#app", App)
if err != nil {
	return err
}
defer app.Unmount()
```

The host page must contain an element matching the selector before `Mount`
runs, for example `<div id="app"></div>`. If the selector matches no element,
`Mount` returns an error and does not retain callbacks or mounted state.

`Unmount` is idempotent. After unmount, callback wrappers created by that mount
must no longer call application code.

## Consequence

Product modules can build browser UI mostly in Go. Core owns only predictable
mount, callback, update, and unmount behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Mounting and updates](./mounting-updates)
- [Callback props](../v0.1.6/callback-props)

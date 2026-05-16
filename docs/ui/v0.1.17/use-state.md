---
title: UseState
description: BusDK UI v0.1.17 component-local state helper.
---

## Contract

`UseState` stores one component-local value under the current
[state runtime](./state-runtime). The value belongs to the current mount handle
and component position. Calling the setter replaces the value and requests a
rerender through that same handle.

`UseState` must be called while a mounted GX component is rendering. Calling it
outside an active render is a programmer error and panics with
`uiruntime.ErrNoActiveRender`.

```go
func UseState[T any](initial T) (T, func(T))
```

```gx
import (
	"fmt"

	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/uiruntime"
)

func Counter() gx.Node {
	count, setCount := uiruntime.UseState(0)

	increment := func() {
		setCount(count + 1)
	}

	return <button onClick={increment}>
		{fmt.Sprintf("Count %d", count)}
	</button>
}
```

## Requirements

- The initial value is used only for the first render at that component
  position.
- The setter can be called from GX callback props such as `onClick`.
- The setter accepts the next value directly. This patch does not define
  updater functions that receive the previous value.
- Several queued setter calls are applied in call order before the next
  rendered result is observed. When several calls close over the same rendered
  value, the last supplied value wins.
- Updating an unmounted handle is a no-op and records the deterministic runtime
  diagnostic `bus-ui.state.update-after-unmount`; it must not resurrect
  released state.
- Tests can mount a component, dispatch callbacks, and observe the rendered
  state after updates.

## Boundary

`UseState` does not run asynchronous work, perform cleanup, read browser
storage, or fetch resources. Those behaviors belong to later runtime and
library patches.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core node foundation](../v0.1.1/)
- [Handle render scheduling](../v0.1.13/handle-render-scheduling)
- [State runtime](./state-runtime)

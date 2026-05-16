---
title: UseRef
description: BusDK UI v0.1.17 stable mutable reference helper.
---

## Contract

`UseRef` returns a stable mutable reference under the current
[state runtime](./state-runtime). The reference belongs to the current mount
handle and component position. Mutating the referenced value does not request a
rerender, so refs are for values that must persist across rerenders but do not
drive visible output. Use [UseState](./use-state) when a mutation must update
rendered UI.

```go
type Ref[T any] struct {
	Value T
}

func UseRef[T any](initial T) *Ref[T]
```

```gx
import (
	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/uiruntime"
)

func FocusableInput() gx.Node {
	inputID := uiruntime.UseRef("note-title")

	return <input id={inputID.Value}></input>
}

func DraftInput() gx.Node {
	lastTyped := uiruntime.UseRef("")

	remember := func(value string) {
		lastTyped.Value = value
	}

	return <input onInput={remember}></input>
}
```

## Requirements

- The returned reference identity is stable across rerenders at the same
  component position.
- Mutating the reference does not schedule render work.
- The initial value is used only when the reference is first created.
- Unmounted handles release references with the rest of the runtime state.
- Tests can assert that the same reference survives rerendering.

## Boundary

`UseRef` does not own browser DOM nodes directly in this patch. Browser element
handles and focus helpers can build on refs later, but this page only defines
the stable Go value container.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core node foundation](../v0.1.1/)
- [State runtime](./state-runtime)

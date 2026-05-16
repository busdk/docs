---
title: UseMemo
description: BusDK UI v0.1.17 deterministic derived-value cache helper.
---

## Contract

`UseMemo` caches a derived value under the current
[state runtime](./state-runtime). The runtime reuses the cached value while the
dependency list is unchanged and recomputes it when a dependency changes.

```go
type DependencyList []any

func Deps(values ...any) DependencyList
func UseMemo[T any](compute func() T, deps DependencyList) T
```

`Deps` accepts comparable scalar values, stable ids, and explicit version
tokens. Application slices, maps, and structs should be represented by a stable
id, length plus version, or another deterministic token chosen by the caller.
Every value read by `compute` that can change between renders must be
represented in `deps`; otherwise the runtime may reuse a stale cached value.
Passing slices, maps, funcs, or other non-comparable values directly to `Deps`
panics with `uiruntime.ErrInvalidDependency`.

```gx
import (
	"fmt"

	"github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/uiruntime"
)

func TotalView(lines []string, version int) gx.Node {
	total := uiruntime.UseMemo(func() int {
		count := 0
		for _, line := range lines {
			count += len(line)
		}
		return count
	}, uiruntime.Deps(len(lines), version))

	return <span>{fmt.Sprintf("%d", total)}</span>
}
```

## Requirements

- Dependency comparison is deterministic for comparable scalar values, stable
  ids, and explicit dependency tokens.
- The memo function runs during render and must be pure from the renderer's
  point of view.
- Cached values are released when the owning mount handle unmounts.
- Tests can verify recompute and reuse behavior without a browser.

## Boundary

`UseMemo` is for derived render values. It does not start goroutines, cache
provider responses, persist to storage, or replace explicit application data
models.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core node foundation](../v0.1.1/)
- [State runtime](./state-runtime)

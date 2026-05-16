---
title: Core test helpers
description: BusDK UI core test helpers for nodes, generated templates, and WASM callbacks.
---

## Contract

Import shared helpers from `github.com/busdk/bus-gx/pkg/gxtest`. The
signatures below use `gx` for `github.com/busdk/bus-gx/pkg/gx` and `testing`
for the Go standard library `testing` package.

| Helper | Signature | Use |
| --- | --- | --- |
| `RenderHTML` | `func RenderHTML(t testing.TB, node gx.Node) string` | Deterministic escaped HTML fixture rendering. |
| `VNode` | `func VNode(t testing.TB, node gx.Node) gx.VNode` | Render-tree assertions without string parsing. |
| `RequireProp` | `func RequireProp[T any](t testing.TB, vnode gx.VNode, name string) T` | Typed scalar and callback prop assertions. |
| `CompileGX` | `func CompileGX(t testing.TB, filename string, src string) string` | Generated Go golden tests. |
| `MountWASM` | `func MountWASM(t testing.TB, selector string, root func() gx.Node) *WASMHarness` | Browser-backed runtime tests. |
| `WASMHarness.Click` | `func (h *WASMHarness) Click(selector string)` | Button callback tests. |
| `WASMHarness.Input` | `func (h *WASMHarness) Input(selector string, value string)` | Input and change callback tests. |
| `WASMHarness.Submit` | `func (h *WASMHarness) Submit(selector string)` | Form submit callback tests. |
| `WASMHarness.HTML` | `func (h *WASMHarness) HTML() string` | Post-update DOM assertions. |
| `WASMHarness.Diagnostics` | `func (h *WASMHarness) Diagnostics() []error` | Redacted runtime diagnostic assertions. |

Helpers must not make network calls, read host credentials, or register global
browser functions outside the mounted test scope.

`MountWASM` runs under the module's browser-backed Go WebAssembly test target:

```sh
make test-wasm
```

Host-only `go test ./...` may build packages that import `gxtest`, but it must
not try to run browser callbacks. When the browser runtime is unavailable,
WASM helper tests must skip with a clear message instead of passing silently or
failing with an unrelated JavaScript error.

## Consequence

Product modules can test generated templates, component functions, and browser
callback behavior without hand-writing local harnesses. `MountWASM` supports
tag selectors, `#id`, and simple `tag[attr=value]` selectors such as
`input[name=title]` and `button[type=submit]`.

## Example

```go
h := gxtest.MountWASM(t, "#app", app.View)
h.Input("input[name=title]", "Draft")
h.Submit("form")
if app.SavedTitle != "Draft" {
	t.Fatalf("SavedTitle = %q", app.SavedTitle)
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Mounting and updates](../v0.1.7/mounting-updates)
- [Intrinsic interactive elements](../v0.1.6/intrinsic-elements)

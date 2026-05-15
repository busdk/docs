---
title: Core test helpers
description: BusDK UI core test helpers for fake resources, fixtures, and renderer assertions.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Core foundation](../v0.1.1/foundation)

## Contract

Import shared helpers from `github.com/busdk/bus-gx/pkg/gxtest`. The
signatures below use `gx` for `github.com/busdk/bus-gx/pkg/gx`, `testing` for
the Go standard library `testing` package, and `js` for `syscall/js`.

| Helper | Signature | Use |
| --- | --- | --- |
| `NewRenderHarness` | `func NewRenderHarness(t testing.TB) *RenderHarness` | Component and template tests. |
| `RenderHarness.FakeResource` | `func (h *RenderHarness) FakeResource(name string, response gx.ResourceResponse)` | Resource/effect tests without network calls. |
| `RenderHarness.FakeEvent` | `func (h *RenderHarness) FakeEvent(name string, handler gx.EventHandler[any])` | Button, form, approval, and terminal event tests. |
| `RenderHarness.RenderNode` | `func (h *RenderHarness) RenderNode(node gx.Node) string` | Deterministic HTML fixture rendering. |
| `AssertHTMLContains` | `func AssertHTMLContains(t testing.TB, html string, selector string)` | Stable labels, roles, classes, and attributes. |
| `AssertNoUnsafeHTML` | `func AssertNoUnsafeHTML(t testing.TB, html string)` | Safety regression coverage. |
| `NewWASMValue` | `func NewWASMValue(t testing.TB, value any) js.Value` | Callback and retained-value tests. |

Tests create a harness, register fake events/resources, render one focused
fixture, then assert semantic output and diagnostics. Helpers must not make
network calls or read host credentials.

`NewWASMValue` is only for Go WebAssembly tests that run under the module's
browser-backed test target, such as `make test-e2e` or a documented
`GOOS=js GOARCH=wasm` harness. Ordinary host `go test` suites use render
harness helpers and avoid `js.Value`.

Renderer tests should verify semantic states: escaped output, stable event
names, visible labels, accessibility attributes, expected classes, safe links,
and absence of inline scripts or unsafe HTML where the product contract forbids
them.

## Consequence

Product modules should depend on shared fakes instead of hand-writing local
copies for every event flow.

## Example

```go
h := gxtest.NewRenderHarness(t)
h.FakeEvent("save-note", saveHandler)
html := h.RenderNode(buttonNode)
gxtest.AssertHTMLContains(t, html, `button[data-ui-event="save-note"]`)
gxtest.AssertNoUnsafeHTML(t, html)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- Testing UI apps
- UI component reference

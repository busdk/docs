---
title: UI testkit browser parity
description: BusDK UI v0.1.21 fixture mounting and fake browser helpers for Go WASM parity tests.
---

## Contract

`v0.1.21` extends the deterministic UI test helpers with browser-parity
fixtures. Product modules can mount a fixture, dispatch typed callbacks, and
compare server, WASM, and pure-renderer behavior without making every state
transition an e2e test.

```go
func TestMountedCounter(t *testing.T) {
	fixture := uikittest.Mount(t, Counter)
	fixture.Click("button")
	fixture.AssertText("button", "Count 1")
	fixture.AssertNoLeakedCallbacks()
}
```

The browser fixture provides fake browser-global accessors for form values,
files, storage, timers, and location/hash values. Tests that need the real
browser runtime can still use e2e coverage, but ordinary component behavior
should stay in fast Go tests.

## Requirements

- Fixture mounting uses the [Go WASM frontend runtime](../v0.1.7/).
- Fake browser globals match the public adapters from
  [v0.1.16](../v0.1.16/minimal-browser-adapters).
- Parity assertions compare server HTML, mounted output, callback behavior,
  and cleanup.
- Failure output names the selector, event, expected state, and observed state.
- Callback and effect leaks are observable after unmount.

## Boundary

This patch does not replace product e2e tests, portal host checks, or provider
API tests. It keeps generic browser-bound component behavior unit-testable.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go WASM frontend runtime](../v0.1.7/)
- [Minimal browser adapters](../v0.1.16/minimal-browser-adapters)
- [Form value adapter](../v0.1.16/form-values)
- [File adapter](../v0.1.16/files)
- [Browser storage adapter](../v0.1.16/browser-storage)
- [UI testkit renderer](../v0.1.20/uikittest-renderer)

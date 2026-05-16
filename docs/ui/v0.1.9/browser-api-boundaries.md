---
title: UI browser API boundaries
description: BusDK UI browser API isolation and JavaScript boundary rules.
---

## Contract

Browser-only behavior stays behind the Go-facing runtime helper introduced in
[Mounting and updates](../v0.1.7/mounting-updates). Product modules mount a
root Go function with `gxwasm.Mount`, request rerenders with `gxwasm.Update`,
and express browser interactions through the intrinsic callback properties from
[v0.1.6](../v0.1.6/intrinsic-elements).

The v0.1.x browser helper owns only DOM selection, DOM rendering, update
scheduling, unmount cleanup, and callback wiring for `button click`,
`form submit`, `input input`, and `input change`.

Product modules must not expose global `window.<Module>` facades, inline
event-handler attributes, inline scripts, or secret-bearing DOM attributes.
The allowed script loading pattern is a framework-owned external WebAssembly
bootstrap plus its generated support files. CSP verification checks that the
host page can run without inline script approval and without inline event
handlers.

Any additional browser API requires a new versioned page and implementation
patch before product code depends on it.

## Consequence

Local hand-written JavaScript in a product module usually means a reusable
Go-facing helper is missing.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Mounting and updates](../v0.1.7/mounting-updates)
- [Intrinsic interactive elements](../v0.1.6/intrinsic-elements)

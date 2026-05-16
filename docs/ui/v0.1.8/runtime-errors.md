---
title: Runtime errors
description: BusDK UI runtime error reporting boundary.
---

## Contract

Runtime errors are framework errors that happen after a successful mount:
callback panic recovery, render failure, missing mount state during update, or
browser bridge failure.

The runtime reports these errors to `Options.OnError` when supplied. It does
not render an error component, retry callbacks, or own provider error
projection. User code decides whether to log, set app state, or rerender an
error view.

Provider errors are application data. Product modules project provider errors
into their own Go state before rendering.

## Consequence

Runtime diagnostics stay small and framework-owned. Product error handling
stays in product Go code.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Runtime diagnostics](./diagnostics)
- [Mounting and updates](../v0.1.7/mounting-updates)

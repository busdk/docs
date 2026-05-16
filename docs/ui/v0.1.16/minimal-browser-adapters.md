---
title: Minimal browser adapters
description: BusDK UI v0.1.16 narrow Go WebAssembly adapters for browser APIs.
---

## Contract

`v0.1.16` adds narrow Go APIs for browser features that cannot be represented
as plain GX nodes. The adapters live behind the Go WebAssembly browser
boundary from [v0.1.9](../v0.1.9/browser-api-boundaries), and higher-level UI
libraries call them from ordinary Go.

The minimal adapter set is:

- [form value extraction](./form-values)
- [file input access](./files)
- [browser key-value storage](./browser-storage)

## Shared Requirements

- Adapters are Go APIs, not DOM attributes.
- Browser-only implementations stay behind build tags.
- Host builds remain importable with clear unavailable errors.
- Form values preserve repeated fields.
- File adapters expose metadata and readers, not raw JavaScript objects.
- Storage adapters are explicit and testable with fakes.

## Boundary

This patch does not add resource clients, session policy, bearer headers,
redirect helpers, fetch streaming, abort controllers, terminal protocols,
window listeners, hash routing, or effect hooks. Those libraries can build on
these adapters without expanding the GX core node model.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Browser API boundaries](../v0.1.9/browser-api-boundaries)
- [Typed event payloads](../v0.1.15/typed-event-payloads)

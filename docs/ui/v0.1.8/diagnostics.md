---
title: Runtime diagnostics
description: BusDK UI Go WebAssembly runtime diagnostic contract.
---

## Contract

`v0.1.8` adds diagnostics for the small Go WebAssembly frontend runtime from
[v0.1.7](../v0.1.7/). Diagnostics report framework failures without defining a
logging transport.

The runtime returns mount errors directly from `Mount`. After mount, callback
panics and render failures are reported through an optional Go function:

```go
type Options struct {
	OnError func(error)
}
```

If `OnError` is nil, the runtime writes a redacted message to the browser
console. Application code may call its own logger from `OnError`.

Framework diagnostics must not contain tokens, cookies, raw provider payloads,
stack traces with customer data, SQL, private customer data, or credential
headers. Product modules own product error copy and product logging.

## Consequence

Core reports mount, render, and callback-wrapper failures consistently without
owning application logging.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core lifecycle](../v0.1.7/)
- [Runtime errors](./runtime-errors)

---
title: Resource primitives
description: BusDK UI v0.1.23 Go resource clients for API calls, uploads, streaming, and provider errors.
---

## Contract

`v0.1.23` adds Go/WASM-first resource primitives to the reusable runtime
packages inside `bus-ui`. A resource client resolves safe host paths, attaches
approved request helpers, executes requests, decodes responses, and maps
provider failures into public UI result values.

```go
client := uiresource.Client{
	Base:    uiresource.ModuleAPI,
	Path:    "/v1/drafts",
	Session: session,
}

result := uiresource.UseResource(client).PostJSON(ctx, draft)
```

Resource requests support `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, multipart
upload, redirect requests, abort signals, and provider-error mapping. Fetch
streaming is represented as a reader interface with cancellation; it does not
make the minimal runtime a terminal protocol or general networking library.

## Requirements

- Paths are same-origin or host-resolved and reject unsafe schemes.
- Bearer and CSRF handling comes from injected session/request helpers.
- Multipart upload uses file handles from
  [v0.1.16](../v0.1.16/minimal-browser-adapters) and product-owned validation.
- Abort signals cancel requests and close stream readers.
- Provider errors redact secrets and expose public title, summary, status,
  request id, and field errors where available.
- Tests can use fake clients, fake streams, and deterministic provider errors.

## Boundary

Resources do not own product endpoints, authorization policy, provider DTOs, or
terminal protocols. They give actions and effects a safe transport primitive
that can run in Go/WASM, server-side tests, and pure unit tests.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Minimal browser adapters](../v0.1.16/minimal-browser-adapters)
- [Effect runtime](../v0.1.18/effect-runtime)
- [Action primitives](../v0.1.22/action-primitives)

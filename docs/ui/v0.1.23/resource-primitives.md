---
title: Resource primitives
description: BusDK UI v0.1.23 Go resource clients for API calls, uploads, streaming, and provider errors.
---

## Contract

`v0.1.23` adds Go/WASM-first resource primitives to the reusable runtime
packages inside `bus-ui`. A resource client resolves safe host paths, attaches
approved request helpers, executes requests, decodes responses, and maps
provider failures into public UI result values. The public `pkg/ui` facade
composes higher-level surfaces through `ui.RenderHTML`; these lower-level
transport helpers sit underneath that boundary.

```go
import (
	"context"

	uiresource "github.com/busdk/bus-ui/pkg/uikit/uiresource"
	uisession "github.com/busdk/bus-ui/pkg/uikit/uisession"
)

ctx := context.Background()
session := uisession.FromHost(hostSession)
draft := Draft{Title: "Release notes"}

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

Valid resource paths are same-origin absolute paths such as `/v1/drafts`, or
host-resolved paths such as `{Base: uiresource.PortalAPI, Path: "/v1/session"}`.
Rejected paths include `javascript:alert(1)`, `data:text/html,...`,
`https://example.test/v1/drafts` without an explicit host allowlist, empty
paths, and paths containing `..`.

Authentication comes from `uisession.RequestAuthorizer`. `Client.Session`
implements that interface. Before dispatch, the resource client calls
`Authorize(req uiresource.Request) (uiresource.Request, error)`, which attaches
bearer behavior for approved API requests and CSRF behavior for same-origin
unsafe methods.

Provider failures return `uiresource.Result{State: uiresource.ProviderError}`.
The public error fields are `Title`, `Summary`, `Status`, `RequestID`, and
`Fields []uiresource.FieldError`. Field errors use `Path`, `Code`, and
optional `Message`. Raw response bodies, tokens, stack traces, SQL, and
credentials are never copied into the result.

## Requirements

- Paths are same-origin or host-resolved and reject unsafe schemes, external
  origins without allowlist, empty paths, and `..`.
- Bearer and CSRF handling comes from `uisession.RequestAuthorizer`.
- Multipart upload uses file handles from
  [v0.1.16](../v0.1.16/files) and product-owned validation.
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

- [File adapter](../v0.1.16/files)
- [Effect runtime](../v0.1.18/effect-runtime)
- [Action primitives](../v0.1.22/action-primitives)

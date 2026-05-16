---
title: EvidenceURLResolver UI component
description: Dedicated BusDK UI reference for EvidenceURLResolver.
---

## Purpose

`EvidenceURLResolver` is an evidence/media component. It returns a resolved
URL string for safe evidence links and previews; it does not fetch or render
the evidence by itself.

## Inputs

| GX attribute / Go field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `endpoint` / `Endpoint` | yes | same-origin path | Evidence API endpoint beginning with `/` and without the artifact path; query strings are not allowed here. The resolver combines it with the raw `path` after escaping path segments. |
| `path` / `Path` | yes | raw artifact path | Caller passes the raw provider artifact path; the resolver escapes each segment exactly once. |
| `api-resolver` / `APIResolver` | no | module, portal, or named resolver | Default `module`. `module` resolves against the current module base path; `portal` resolves against the portal host base; a named resolver resolves through host runtime config and is required for allowlisted external HTTPS evidence origins. |

## Boundary

Provider APIs authorize the resolved URL. Missing credentials or insufficient
scope produce an authorization error state; unknown artifacts produce a
not-found state. Callers render those through `ProviderError`, `ErrorBanner`,
or disabled evidence controls rather than exposing a raw path.

The resolver returns `(string, error)`. A nil error means the string is a safe URL
for a link or preview. Failures return an empty URL plus one of these typed error
codes for the caller to project into UI state: `unauthorized` for missing or
insufficient credentials, `not_found` for unknown artifacts, `unsafe_path` for
path traversal or rejected schemes, and `unregistered_resolver` for unknown
named resolvers.

## Example

```go
var previewURL, err = EvidenceURLResolver(EvidenceURLResolverProps{
	Endpoint: "/api/evidence",
	Path:     "invoice.pdf",
})
```

## Runtime Terms

Same-origin evidence endpoints begin with `/`. External evidence URLs are never
accepted directly; they must be resolved by a named `apiResolver` registered by
the host with an `externalEvidenceOrigins` allowlist. `javascript:`, `data:`,
path traversal, and unresolved authorization failures are rejected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

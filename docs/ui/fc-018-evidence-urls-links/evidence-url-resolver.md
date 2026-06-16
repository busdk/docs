---
title: EvidenceURLResolver UI component
description: Dedicated BusDK UI reference for EvidenceURLResolver.
---

## Purpose

`EvidenceURLResolver` is a Go helper for building safe evidence URLs.
It joins a same-origin evidence endpoint with an escaped artifact path, or
delegates to a host-named resolver. It does not fetch evidence, authorize a
document, inspect the filesystem, or render UI. This page documents the public
`pkg/ui` evidence URL facade.

## Inputs

| Go field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `Endpoint` | yes for built-in resolvers | string | Same-origin endpoint beginning with `/`. Query strings, fragments, schemes, traversal, and protocol-relative paths are rejected. |
| `Path` | yes | string | Raw relative artifact path. Each segment is unescaped and escaped exactly once; empty segments, traversal, schemes, absolute paths, backslashes, and control characters are rejected. |
| `Operation` | no | `EvidenceOperation` | `open`, `download`, or `preview`; defaults to `open`. |
| `ContentType` | no | string | Optional MIME hint normalized to lower case. It is metadata only and does not authorize preview rendering. |
| `ExpiresAt` | no | string | Optional RFC 3339 expiry metadata. |
| `APIResolver` | no | string | Built-in values are `module`, `portal`, and `same-origin`; other names dispatch to `NamedResolver`. Default is `module`. |
| `SameOriginBasePath`, `ModuleBasePath`, `PortalBasePath` | no | string | Runtime API base paths consumed by built-in resolution. |
| `NamedResolver` | required for named resolvers | `EvidenceNamedURLResolver` | Host-owned adapter for external evidence origins or provider-specific URL policies. |
| `SourcePath` | no | string | Optional source path passed to runtime URL resolution or a named resolver. |
| `Log` | no | `ControlLogSink` | Receives validation and resolution events. |

## Boundary

Provider APIs authorize the resolved URL. Missing credentials, insufficient
scope, unknown artifacts, external-origin allowlists, provider transport, and
filesystem access stay in the host or product module. A named resolver may
return a public denial reason instead of a URL; `bus-ui` validates and renders
that result but does not decide provider policy.

`ResolveEvidenceURL` returns `EvidenceURLResult` with `URL`, optional
`ExpiresAt`, optional `ContentType`, and optional `Reason`. `EvidenceURLResolver`
is the convenience form that returns only `(string, error)` and converts a
denial reason into a typed validation error.

```go
previewURL, err := ui.EvidenceURLResolver(ui.EvidenceURLResolverProps{
	Endpoint:    "/api/evidence",
	Path:        "invoices/2026 04.pdf",
	Operation:   ui.EvidenceOperationPreview,
	ContentType: "application/pdf",
})
if err != nil {
	return "", err
}
```

## Runtime Terms

Built-in resolver output goes through the runtime API URL resolver for the
selected base. Named resolver output goes through `ValidateEvidenceHref` before
use. Callers pass the returned URL to `EvidenceLink`, `EvidencePreview`, or a
product view model after host authorization has already succeeded.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

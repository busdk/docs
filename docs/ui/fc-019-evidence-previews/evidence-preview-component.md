---
title: EvidencePreview UI component
description: Dedicated BusDK UI reference for EvidencePreview.
---

## Purpose

`EvidencePreview` renders one inline evidence preview or a public-safe
fallback. It consumes an already-authorized preview URL, optional open/download
URLs, provider-verified metadata, and a public title.
Render the returned node with `ui.RenderHTML` at the page boundary.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `PreviewURL` | yes for inline preview | string | Same-origin or host-resolved HTTPS preview URL. Empty or unsafe URLs render fallback. |
| `OpenURL` | no | string | Optional checked URL for the Open control. Defaults to `PreviewURL`. |
| `DownloadURL` | no | string | Optional checked URL for the Download control. Defaults to `PreviewURL`. |
| `Title` | yes | string | Public-safe accessible title. |
| `ContentType` | yes for inline preview | string | Provider-verified MIME type. Inline types are `image/png`, `image/jpeg`, `image/webp`, `application/pdf`, and `text/plain`. |
| `ContentDisposition` | no | string | `attachment` or filenames containing path separators block inline preview. |
| `Fallback` | no | string | Public-safe fallback copy. |
| `Reason` | no | `EvidenceDenialReason` | Resolver denial reason. Any reason renders fallback. |
| `Attrs` | no | `map[string]string` | Root attributes limited to safe identity, class, role, `data-*`, and `aria-*` keys. |
| `Log` | no | `ControlLogSink` | Receives preview policy and render events. |

## Boundary

Active HTML and SVG previews are rejected by default and render fallback. A
host may proxy them from a sandboxed evidence origin, but they never execute in
the portal origin. Authorization, provider fetches, content-type verification,
content-disposition policy at the storage boundary, and filesystem access stay
outside `bus-ui`.

## Example

```go
package evidenceui

import "github.com/busdk/bus-ui/pkg/ui"

func InvoicePreview(previewURL string) (string, error) {
	return ui.RenderHTML(ui.EvidencePreview(ui.EvidencePreviewProps{
		PreviewURL:  previewURL,
		Title:       "Invoice 2026-04",
		ContentType: "application/pdf",
	}))
}
```

## Legacy compatibility

The compatibility helper remains available for callers that still need the
historical checked helper.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

`EvaluateEvidencePreviewPolicy` exposes the inline-or-fallback decision without
rendering HTML. `IsEmbeddableEvidenceContentType` lets hosts preflight whether a
provider-verified MIME type can be offered for inline preview.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

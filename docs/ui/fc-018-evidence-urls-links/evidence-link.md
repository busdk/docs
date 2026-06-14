---
title: EvidenceLink UI component
description: Dedicated BusDK UI reference for EvidenceLink.
---

## Purpose

`EvidenceLink` renders one node-first evidence open or download control. It
accepts an already-authorized href from the product view model, validates that
the href is safe to place in an anchor, and renders disabled public text when
the href is missing or the resolver supplied a denial reason. Render the node
with `ui.RenderHTML` at the page boundary.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `Href` | conditional | string | Enabled links require a non-empty safe href and empty `Reason`. Disabled links render when `Href` is empty or `Reason` is set; an empty href without `Reason` is treated as `missing`. |
| `Label` | yes | string | Public-safe visible text. Empty or unsafe text is a render error. |
| `Operation` | no | `EvidenceOperation` | `EvidenceOperationOpen` or `EvidenceOperationDownload`; empty defaults to `open`, or to `download` when `Download` is true. Preview rendering belongs to `EvidencePreview`. |
| `Reason` | no | `EvidenceDenialReason` | Public denial reason such as `unauthorized`, `expired`, `missing`, `not_found`, `unsafe_path`, `unsupported`, or `unregistered_resolver`. A reason disables the link and omits `href`. |
| `Target` | no | string | `_self` by default; `_blank` is allowed and receives `rel="noopener noreferrer"`. |
| `Download` | no | bool | Adds the boolean `download` attribute. If `Operation` is empty, `Download: true` also selects the download operation; if `Operation` is already set, the operation is preserved. |
| `Attrs` | no | `map[string]string` | Caller attributes limited to `id`, `class`, `role`, `title`, `data-*`, and `aria-*`. |
| `Log` | no | `ControlLogSink` | Receives render and validation events. |

## Boundary

`EvidenceLink` validates link shape and disabled rendering only. Provider
authorization, signed URL creation, exact external-origin allowlists, download
permission, and filesystem access stay in the product module or host resolver.
The component treats an external `https:` href as host-resolved input and adds
`rel="noopener noreferrer"`; it does not decide whether that origin is allowed.

## Example

```go
package evidenceui

import (
	"github.com/busdk/bus-ui/pkg/ui"
)

func InvoiceDownload(invoiceDownloadURL string) (string, error) {
	return ui.RenderHTML(ui.EvidenceLink(ui.EvidenceLinkProps{
		Href:      invoiceDownloadURL,
		Label:     "Download invoice 2026-04",
		Operation: ui.EvidenceOperationDownload,
		Download:  true,
		Attrs:     map[string]string{"id": "invoice-2026-04-download"},
	}))
}
```

`invoiceDownloadURL` is produced by `EvidenceURLResolver`, `ResolveEvidenceURL`,
or a host-owned evidence adapter before the link renders.

## Legacy compatibility

`EvidenceLinkChecked` remains available for callers that still need the
historical string-returning helper.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

`ValidateEvidenceHref` rejects empty hrefs, fragments, query-only hrefs,
protocol-relative URLs, `javascript:`, `data:`, whitespace, backslashes,
credentials, non-HTTPS absolute URLs, and traversal segments. Relative
same-origin paths and host-resolved HTTPS URLs are accepted after the caller has
performed authorization.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

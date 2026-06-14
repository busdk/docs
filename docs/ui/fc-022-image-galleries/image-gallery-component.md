---
title: ImageGallery UI component
description: Dedicated BusDK UI reference for ImageGallery.
---

## Purpose

`ui.ImageGallery` is the preferred linked image gallery API for actual visual
content that users inspect. `ImageGalleryChecked` remains available as a
compatibility wrapper for callers that still need diagnostics.

When every item passes validation, `ImageGalleryChecked` returns
`ImageGalleryResult` with rendered `HTML`, the accepted `Items`, no diagnostics,
and a nil error. When one or more items fail item validation, it returns partial
safe gallery HTML for the accepted items, includes diagnostic entries for the
omitted items, and returns `ErrImageGalleryItemRejected`. Invalid allowlist
origins or unsafe root attributes fail before rendering and return an empty
result with the corresponding error.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `Items` | yes | `[]ImageGalleryItem` | `Src` and `Alt` required; `Caption` optional text; `Href` optional safe URL for opening the source; item `Attrs` must be inert attributes. |
| `ImageOrigins` | no | `[]string` | Exact external `https:` origins accepted for `Src` and `Href`, such as `https://media.example.com`. Entries must be origins only, with no path, query, or fragment. |
| `Attrs` | no | `map[string]string` | Inert root attributes. Event handlers, `data-ai-*`, and active browser attributes are rejected. |
| `Log` | no | `ControlLogSink` | Receives public render and validation diagnostics. |

## Boundary

Every image has useful alt text. The component validates URL shape, origin
allowlists, and inert attributes before rendering, but provider authorization
and path resolution remain host-owned boundaries.

## Example

```go
package mediaui

import "github.com/busdk/bus-ui/pkg/ui"

var invoicePages = []ui.ImageItem{
	{Src: "/preview/a.png", Alt: "Invoice page 1", Caption: "Page 1"},
	{
		Src:     "https://media.example.com/invoices/2026-05/a.png",
		Href:    "https://media.example.com/invoices/2026-05/a.png",
		Alt:     "Invoice page 2",
		Caption: "Page 2",
	},
}

func renderInvoiceGallery() (string, error) {
	return ui.RenderHTML(ui.ImageGallery(ui.ImageGalleryProps{
		Items:        invoicePages,
		ImageOrigins: []string{"https://media.example.com"},
	}))
}
```

`ImageItem` is an alias for `ImageGalleryItem` from the public `ui` facade.

## Runtime Terms

`Src` and `Href` values must be root-relative same-origin paths such as
`/preview/a.png`, with no `..` segments, or external `https:` URLs whose exact
origin appears in `ImageGalleryProps.ImageOrigins`. External image links are
rejected by default. Rejected links fail validation and produce
`ImageGalleryDiagnostic` values.

`Code` is `image_alt_required` for missing alt text and `image_url_rejected`
for unsafe `Src` or `Href`. Rejected item attributes use the machine-readable
code `unsafe image gallery attribute`, set `Field` to `attrs`, and set
`PathClass` to `attribute`. Unsafe root `Attrs` are different: they fail the
whole render before item diagnostics are built and return
`ErrImageGalleryUnsafeAttrs`. `Index` is the zero-based item index, `Field` is
`alt`, `src`, `href`, or `attrs`, `Origin` is populated only for rejected
external URLs, and `PathClass` names the rejected URL class such as `missing`,
`relative`, `traversal`, `external-scheme`, `credentials`, or
`unlisted-origin`.

`ImageGalleryChecked` does not name or call a resolver. The host or controller
resolves provider paths first, then passes only resolved safe URLs in
`ImageGalleryItem.Src` and `ImageGalleryItem.Href`.

Accepted examples: `/preview/a.png` and
`https://media.example.com/invoices/a.png` when that exact origin is allowlisted.
Rejected examples: `https://cdn.example.net/a.png` without an allowlist entry,
`javascript:alert(1)`, and `../private/a.png`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

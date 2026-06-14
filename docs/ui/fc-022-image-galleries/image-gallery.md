---
title: Library image gallery
description: BusDK UI library linked image gallery contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [UI layout](../v0.2.5/layout)

## Contract

[`ImageGallery`](./image-gallery-component) renders linked image items with
safe URLs and explicit alt labels. Unsafe URLs and unsafe root or item
attributes are rejected before render.

| Field | Required | Behavior |
| --- | --- | --- |
| `Src` | yes | Root-relative same-origin path or external `https:` URL whose exact origin appears in `ImageGalleryProps.ImageOrigins`. Unlisted external origins fail validation. |
| `Alt` | yes | Public-safe accessible label. |
| `Caption` | no | Public-safe title/caption shown with the image. |
| `Href` | no | Optional URL for opening the source item. Validation matches `Src`: root-relative same-origin path with no `..`, or external `https:` URL whose origin appears in `ImageGalleryProps.ImageOrigins`. |
| `Attrs` | no | Root or item attributes limited to inert `id`, `class`, `role`, `title`, `aria-*`, and non-`data-ai-*` `data-*` attributes. |

Public-safe labels and captions are escaped strings with no secrets, credential
headers, raw provider payloads, stack traces, SQL, or private customer data.
`Alt` is required; missing alt text is a validation error. Unsafe `Src` or
`Href` values reject the item and report diagnostics instead of rendering a
broken image. Rejected URLs emit `image_url_rejected` with the item index,
field, and rejected origin or path class. Missing alt text emits
`image_alt_required` with the item index. Attribute rejection emits an unsafe
attribute diagnostic without rendering the item.

```go
package mediaui

import "github.com/busdk/bus-ui/pkg/ui"

var pages = []ui.ImageGalleryItem{
	{Src: "/preview/a.png", Alt: "Invoice page 1", Caption: "Page 1"},
}

func renderInvoicePages() (string, error) {
	return ui.RenderHTML(ui.ImageGallery(ui.ImageGalleryProps{
		Items:        pages,
		ImageOrigins: []string{"https://media.example.com"},
		Attrs:        map[string]string{"aria-label": "Invoice page previews"},
	}))
}
```

Image galleries are visual repeated media. They do not own evidence
authorization, upload policy, runtime config sourcing, or provider path
resolution. The host or product controller resolves provider paths first, then
passes only root-relative URLs or allowlisted external `https:` URLs to the
gallery.

## Consequence

Image display stays focused on safe media presentation.

## Legacy compatibility

`ImageGalleryChecked` remains available for callers that still need the
historical checked helper and diagnostics.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ImageGallery](./image-gallery-component)
- [Evidence](../fc-018-evidence-urls-links/evidence)

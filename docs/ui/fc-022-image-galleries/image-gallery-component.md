---
title: ImageGallery UI component
description: Dedicated BusDK UI reference for ImageGallery.
---

## Purpose

`ImageGallery` is an evidence/media component. Linked image gallery. Use for actual visual content that users inspect.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | `[]ImageItem` | `Src` and `Alt` required; `Caption` optional text; `Href` optional safe URL for opening the source. |

## Boundary

Every image has useful alt text.

## Example

```gx
package mediaui

import . "github.com/busdk/bus-ui/pkg/uimedia"

var invoicePages = []ImageItem{
  {Src: "/preview/a.png", Alt: "Invoice page 1", Caption: "Page 1"},
}

var invoiceGallery = (
  <ImageGallery items={invoicePages}></ImageGallery>
)
```

`ImageItem` is the exported item type from `github.com/busdk/bus-ui/pkg/uimedia`.

## Runtime Terms

`Src` and `Href` values must be root-relative same-origin paths such as
`/preview/a.png`, with no `..` segments, or provider media URLs already returned
by a named resolver registered by the portal host in
[`RuntimeConfig`](../fc-004-runtime-config-api-urls/runtime-config). External `https:` image links are rejected
by default unless the host runtime config sets `mediaAllowedOrigins` to exact
allowed origins such as `https://media.example.com`; rejected links fail
validation.

`ImageGallery` does not name or call a resolver. The controller resolves provider
paths first, then passes only resolved safe URLs in `ImageItem.Src` and
`ImageItem.Href`.

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

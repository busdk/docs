---
title: ImageGallery UI component
description: Dedicated BusDK UI reference for ImageGallery.
---

## Purpose

`ImageGallery` is an evidence/media component. Linked image gallery. Use for actual visual content that users inspect.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array of `{src,alt,caption,href}` | `src` and `alt` required; `caption` optional text; `href` optional safe URL for opening the source. |

## Boundary

Every image has useful alt text.

## Example

```yaml
kind: ImageGallery
props:
  items:
    - src: /preview/a.png
      alt: Invoice page 1
      caption: Page 1
```

## Runtime Terms

`src` and `href` values must be same-origin paths or provider media URLs
returned by a named resolver registered by the portal host in
[`RuntimeConfig`](../v0.4.2/runtime-config). External `https:` image links are rejected
by default unless the host runtime config sets `mediaAllowedOrigins` to exact
allowed origins such as `https://media.example.com`; rejected links fail
validation.

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

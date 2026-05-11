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
    - { src: /preview/a.png, alt: Invoice page 1, caption: Page 1 }
```

## Runtime Terms

`src` and `href` values must be same-origin paths or provider media URLs
returned by a declared provider media resolver. External `https:` image links
are rejected by default unless `mediaAllowedOrigins` in host config allowlists
the origin; rejected links fail validation.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./drop-zone">DropZone</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./css-bundle">CSSBundle</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

---
title: Library evidence preview
description: BusDK UI library evidence preview contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`EvidencePreview`](./evidence-preview-component) renders safe inline preview
when content type and authorization allow it. Supported inline types are
`image/png`, `image/jpeg`, `image/webp`, `application/pdf`, and `text/plain`.
Other content types, attachments, unauthorized URLs, and active content render
fallback.

An authorized preview URL is a same-origin URL or host-resolved URL returned by
[evidence URL resolution](../v0.7.1/evidence-urls). Non-HTTPS external URLs, unlisted
origins, expired URLs, and resolver denials render fallback instead of inline
content. Fallback renders public-safe title plus reason copy and never embeds
the blocked URL as active content.

| Prop | Required | Behavior |
| --- | --- | --- |
| `preview-url` | yes for inline preview | Authorized URL string; omitted renders fallback. |
| `title` | yes | Public-safe preview title. |
| `content-type` | no | MIME hint; unknown values render fallback until verified by resolver. |
| `reason` | no | Public-safe resolver denial reason. |

```html
<EvidencePreview preview-url={previewURL} title={documentTitle}></EvidencePreview>
```

## Consequence

Evidence preview makes authorized content inspectable without trusting arbitrary
remote content.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidencePreview](./evidence-preview-component)
- [Render tree contract](../v0.1.1/render-tree-contract)

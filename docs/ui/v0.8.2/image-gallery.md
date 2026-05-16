---
title: Library image gallery
description: BusDK UI library linked image gallery contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [UI layout](../v0.2.5/layout)

## Contract

[`ImageGallery`](./image-gallery-component) renders linked image items with
safe URLs and labels. Missing labels use item title or filename. Unsafe URLs
are rejected before render.

| Field | Required | Behavior |
| --- | --- | --- |
| `url` | yes | Same-origin path or external `https:` URL whose origin appears in `RuntimeConfig.config.imageOrigins`. Unlisted external origins fail validation. |
| `label` | no | Public-safe accessible label. |
| `title` | no | Public-safe title used when `label` is omitted. |
| `filename` | no | Public-safe filename used when `label` and `title` are omitted. |

Public-safe labels, titles, and filenames are escaped strings with no secrets,
credential headers, raw provider payloads, stack traces, SQL, or private
customer data. Label fallback order is `label`, then `title`, then `filename`,
then a validation error. Unsafe URLs reject the item and report diagnostics
instead of rendering a broken image.

```yaml
kind: RuntimeConfig
props:
  config:
    moduleBase: /modules/notes/
    apiBase: /modules/notes/api
    imageOrigins:
      - https://images.example.com
```

Image galleries are visual repeated media. They do not own evidence
authorization, upload policy, or provider path resolution.

## Consequence

Image display stays focused on safe media presentation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ImageGallery](./image-gallery-component)
- [Evidence](../v0.7.1/evidence)

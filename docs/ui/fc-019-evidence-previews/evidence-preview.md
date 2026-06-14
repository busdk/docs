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
[evidence URL resolution](../fc-018-evidence-urls-links/evidence-urls).
Non-HTTPS external URLs, expired URLs, resolver denials, missing content type,
and unsupported media render fallback instead of inline content. Fallback
renders public-safe title plus reason copy and never embeds the blocked URL as
active content.

| Prop | Required | Behavior |
| --- | --- | --- |
| `PreviewURL` | yes for inline preview | Authorized URL string; omitted renders fallback. |
| `OpenURL` | no | Safe URL for the Open control. Omitted defaults to `PreviewURL`; missing, denied, or unsafe URLs render the control disabled. |
| `DownloadURL` | no | Safe URL for the Download control. Omitted defaults to `PreviewURL`; missing, denied, or unsafe URLs render the control disabled. |
| `Title` | yes | Public-safe preview title. |
| `ContentType` | yes for inline preview | Provider-verified MIME type. |
| `ContentDisposition` | no | `attachment` and unsafe filenames block inline preview. |
| `Reason` | no | Public-safe resolver denial reason. |

```go
html, err := ui.RenderHTML(ui.EvidencePreview(ui.EvidencePreviewProps{
	PreviewURL:  resolved.URL,
	OpenURL:     resolved.URL,
	DownloadURL: resolved.URL,
	Title:       "Receipt 2026-04-18",
	ContentType: resolved.ContentType,
}))
if err != nil {
	return "", err
}
```

The preview component calls the checked evidence-link helper for its open and
download controls. Hosts still own authorization, provider transport, exact
external-origin allowlists, and storage policy before URLs reach the props.

## Consequence

Evidence preview makes authorized content inspectable without trusting arbitrary
remote content.

## Legacy compatibility

The compatibility helper remains available for callers that still need the
historical checked helper.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidencePreview](./evidence-preview-component)
- [Render tree contract](../v0.1.1/render-tree-contract)

---
title: Library evidence links
description: BusDK UI library evidence open and download link contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`EvidenceLink`](./evidence-link) renders authorized open or
download links. Missing URLs and resolver denial reasons render disabled text
without an active `href`. External HTTPS URLs are accepted only as already
resolved host input; host runtime configuration and named resolvers own exact
origin policy before the URL reaches this component.

Link labels are public-safe text supplied by the product view model.

| Field | Required | Behavior |
| --- | --- | --- |
| `Href` | yes for enabled links | Authorized URL from [evidence URLs](./evidence-urls). |
| `Label` | yes | Public-safe link text. |
| `Operation` | yes | `open` or `download`. |
| `Reason` | no | Denial reason from evidence URL resolution. |
| `Target` | no | `_self` or `_blank`. |
| `Download` | no | Adds the boolean download attribute. |

Open links navigate or open a preview target. Download links set download
intent. Missing, expired, unauthorized, unsupported, or disallowed external
URLs render disabled text with public-safe reason copy. The provider/controller
supplies `href`; the component does not authorize documents.

```go
html, err := uikit.EvidenceLinkChecked(uikit.EvidenceLinkProps{
	Href:      resolved.URL,
	Label:     "Open receipt 2026-04-18",
	Operation: uikit.EvidenceOperationOpen,
	Target:    "_blank",
})
if err != nil {
	return "", err
}
```

## Consequence

Evidence links expose authorized movement without exposing storage paths.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidenceLink](./evidence-link)
- [Evidence URLs](./evidence-urls)

---
title: Library evidence links
description: BusDK UI library evidence open and download link contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`EvidenceLink`](./evidence-link) renders authorized open or
download links. Missing or expired URLs render disabled text. External URLs
must come from a named host resolver configured in [runtime config](../fc-004-runtime-config-api-urls/runtime-config)
or from an origin accepted by [API URL resolution](../fc-004-runtime-config-api-urls/api-urls).

Link labels are public-safe text supplied by the product view model.

| Field | Required | Behavior |
| --- | --- | --- |
| `href` | yes for enabled links | Authorized URL from [evidence URLs](./evidence-urls). |
| `label` | yes | Public-safe link text. |
| `operation` | yes | `open` or `download`. |
| `reason` | no | Denial reason from evidence URL resolution. |

Open links navigate or open a preview target. Download links set download
intent. Missing, expired, unauthorized, unsupported, or disallowed external
URLs render disabled text with public-safe reason copy. The provider/controller
supplies `href`; the component does not authorize documents.

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

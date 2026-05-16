---
title: EvidencePreview UI component
description: Dedicated BusDK UI reference for EvidencePreview.
---

## Purpose

`EvidencePreview` is an evidence/media component. Safe evidence preview. Use for inline approved preview types.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `previewURL` | yes | same-origin evidence API URL, `EvidenceURLResolver` result, or Go expression | Authorized preview URL. Embeds `image/png`, `image/jpeg`, `image/webp`, `application/pdf`, and `text/plain` responses when the provider returns an approved content type and either no `Content-Disposition` or `inline`; `attachment` or filename values with path separators render fallback. |
| `title` | yes | string | Accessible title. |
| `fallback` | no | string | Shown when type, policy, or authorization prevents embedding. Default is a generic unavailable preview message. |

## Boundary

Active HTML and SVG previews are rejected by default and render fallback. A
host may proxy them from a sandboxed evidence origin, but they never execute in
the portal origin.

## Example

```gx
package evidenceui

var invoicePreview = (
  <EvidencePreview
    previewURL={document.Preview}
    title="Invoice 2026-04"
  ></EvidencePreview>
)
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution and evidence
preview URL policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

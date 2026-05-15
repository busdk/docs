---
title: EvidencePreview UI component
description: Dedicated BusDK UI reference for EvidencePreview.
---

## Purpose

`EvidencePreview` is an evidence/media component. Safe evidence preview. Use for inline approved preview types.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `previewURL` | yes | same-origin evidence API URL, `EvidenceURLResolver` result, or `{ bind: path }` | Authorized preview URL. Embeds `image/png`, `image/jpeg`, `image/webp`, `application/pdf`, and `text/plain` responses when the provider returns an approved content type and either no `Content-Disposition` or `inline`; `attachment` or filename values with path separators render fallback. |
| `title` | yes | string | Accessible title. |
| `fallback` | no | string | Shown when type, policy, or authorization prevents embedding. Default is a generic unavailable preview message. |

## Boundary

Active HTML and SVG previews are rejected by default and render fallback. A
host may proxy them from a sandboxed evidence origin, but they never execute in
the portal origin.

## Example

```yaml
kind: EvidencePreview
props:
  previewURL:
    bind: document.preview
  title: Invoice 2026-04
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope
resolution, and missing-value behavior.

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

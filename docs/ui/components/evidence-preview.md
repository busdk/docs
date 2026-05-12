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
  previewURL: { bind: document.preview }
  title: Invoice 2026-04
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings
render the component default when the prop is optional and fail validation when
the prop is required.

Preview URLs must come from `EvidenceURLResolver` or an authorized provider API
path. External HTTPS previews are rejected unless a named evidence resolver
explicitly authorizes and proxies them.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evidence-link">EvidenceLink</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./projection-detail">ProjectionDetail</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

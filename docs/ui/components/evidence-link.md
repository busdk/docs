---
title: EvidenceLink UI component
description: Dedicated BusDK UI reference for EvidenceLink.
---

## Purpose

`EvidenceLink` is an evidence/media component. Evidence open/download link. Use for artifact open and download actions.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `href` | yes | safe URL or `{ bind: path }` | Authorized URL produced by the evidence API or resolver; missing authorization renders disabled text instead of a link. |
| `label` | yes | string | Visible link. |
| `target` | no | _self/_blank | Default _self. |
| `download` | no | boolean or filename string | Omitted or `false` renders a normal link; `true` keeps the server filename; a string sets the suggested filename. |

## Boundary

External or `_blank` targets render with `rel="noopener noreferrer"`. Downloads
still require provider authorization; the browser hint does not grant access.

## Example

```yaml
kind: EvidenceLink
props:
  label: Download invoice
  href: { bind: document.download }
  download: true
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

Evidence links use same-origin evidence API URLs or URLs produced by
`EvidenceURLResolver`. External `https:` evidence links are rejected unless a
named evidence resolver explicitly authorizes and proxies them.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evidence-url-resolver">EvidenceURLResolver</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evidence-preview">EvidencePreview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

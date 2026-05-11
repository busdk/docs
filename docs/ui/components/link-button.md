---
title: LinkButton UI component
description: Dedicated BusDK UI reference for LinkButton.
---

## Purpose

`LinkButton` is a navigation/action/form component. Safe link with button styling. Use for navigation and artifact open/download links.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `href` | yes | same-origin path, authorized resource URL, or binding | Navigation target. External `https:` links are allowed only when the host external-link policy allowlists the origin; invalid targets fail validation. |
| `label` | yes | string | Visible label. |
| `target` | no | _self or _blank | Default _self. |
| `rel` | for _blank | string | Use `noopener noreferrer`. |
| `variant` | no | primary, secondary, danger, ghost | Default secondary. |

## Boundary

External links use safe target and rel attributes.

## Example

```yaml
kind: LinkButton
props:
  label: Open evidence
  href: { bind: document.preview }
  target: _blank
  rel: noopener noreferrer
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./icon-button">IconButton</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./action-bar">ActionBar</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

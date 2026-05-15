---
title: LinkButton UI component
description: Dedicated BusDK UI reference for LinkButton.
---

## Purpose

`LinkButton` is a navigation component. Safe link with button styling. Use for
navigation and artifact open/download links.

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
  href:
    bind: document.preview
  target: _blank
  rel: noopener noreferrer
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

Resource defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

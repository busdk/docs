---
title: LinkButton UI component
description: Dedicated BusDK UI reference for LinkButton.
---

## Purpose

`LinkButton` is a safe link with button styling. Use it for same-origin
navigation and static external links that are known at render time.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `href` | yes | string | Same-origin path, relative path, fragment, or `https:` URL. Unsafe schemes such as `javascript:` fail validation. |
| body | yes | text or nodes | Visible label content. |
| `target` | no | _self or _blank | Default _self. |
| `rel` | for _blank | string | Use `noopener noreferrer`. |
| `variant` | no | primary, secondary, danger, ghost | Default secondary. |

## Boundary

External links use safe target and rel attributes. Resource URL resolution,
download authorization, and dynamic URL construction are runtime-helper work and
are not part of this component patch.

## Example

```gx
var evidenceLink = (
  <LinkButton href="/evidence/current" target="_blank" rel="noopener noreferrer">
    Open evidence
  </LinkButton>
)
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go
expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

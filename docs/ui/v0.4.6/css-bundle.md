---
title: CSSBundle UI runtime block
description: Dedicated BusDK UI reference for CSSBundle.
---

## Purpose

`CSSBundle` is a CLI/tooling runtime block. Shared CSS token bundle. Use to serve framework styles consistently.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `theme` | no | `default`, `compact`, or token object | Default `default`. Token objects may set `colorPrimary`, `colorText`, `colorSurface`, `spaceUnit`, and `radius`; colors use CSS color strings, spacing/radius use CSS lengths. |

## Boundary

Shared design classes are emitted once per page render or build output. Duplicate
`CSSBundle` declarations with the same theme are ignored; conflicting themes
fail validation so a page cannot silently mix token sets.

## Example

```yaml
kind: CSSBundle
props:
  theme: default
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: CSSBundle
description: Shared Bus UI CSS bundle inclusion for GX pages.
---

## Purpose

`CSSBundle` lets a GX page include the shared Bus UI CSS once for the rendered
page or generated asset bundle. It belongs near the page shell or build
entrypoint, not inside each repeated component.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `theme` | no | `default`, `compact`, or `ThemeTokens` | Default `default`. `ThemeTokens` may set `ColorPrimary`, `ColorText`, `ColorSurface`, `SpaceUnit`, and `Radius`; omitted fields inherit from `default`. Colors use CSS color strings, spacing/radius use CSS lengths, and invalid CSS values fail validation. |

## Boundary

Shared design classes are emitted once per page render or build output.
Duplicate `CSSBundle` declarations with the same theme are ignored. Conflicting
themes fail `bus gx validate` with a theme-conflict diagnostic so a page cannot
silently mix token sets.

## Example

```gx
package localui

import . "github.com/busdk/bus-ui/pkg/uistyle"

var rootView = (
  <main>
    <CSSBundle theme={ThemeTokens{
      ColorPrimary: "#0057d8",
      SpaceUnit: "0.25rem",
    }}></CSSBundle>
    <section class="bus-panel">Ready</section>
  </main>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)

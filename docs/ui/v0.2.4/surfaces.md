---
title: Library surfaces
description: BusDK UI library panel, card, metric, and summary surfaces.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Surface components frame or summarize already-projected content.
[`Panel`](./panel) frames bounded tool regions.
[`SurfaceCard`](./surface-card) is for repeated records or grouped
summaries, not page sections. [`MetricCard`](./metric-card) is for
compact dashboard numbers.

Surfaces may own spacing, title placement, density, and collapse behavior. They
must not own provider semantics, authorization, or product status meaning.

## Consequence

Product modules choose content and state labels. Library surfaces make the
content scannable without becoming another domain layer.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Panel](./panel)
- [SurfaceCard](./surface-card)
- [MetricCard](./metric-card)

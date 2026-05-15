---
title: UI design system
description: BusDK UI visual, interaction, and content design rules.
---

## Design Layers

The design system turns BusDK's operational product character into layout,
control, content, and safety rules for reusable UI components and product
screens.

This is the first `bus-ui` library patch. `bus-ui` owns reusable product-facing
components that are composed from the completed `bus-gx` Core patches. It
should not take provider authority, product-specific workflows, portal hosting,
or low-level source/compiler/runtime primitives from their owning layers.

1. [Product character](./product-character) defines the operational tone.
2. Layout defines shells, panels, cards, and fixed-format surfaces.
3. Density and typography defines text scale and fit.
4. Color and status defines semantic status meaning.
5. Controls defines control choice and event-name behavior.
6. [Content style](./content-style) defines app copy and error wording.
7. [Accessibility and safety](./accessibility-safety) defines accessible names,
   safe links, and raw-content boundaries.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)
- [bus-portal module reference](../../modules/bus-portal)

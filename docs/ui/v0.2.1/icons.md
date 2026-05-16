---
title: Library icons
description: BusDK UI library icon rendering contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`Icon`](./icon) renders shared SVG icon paths by names registered
in the `bus-ui` icon registry. Authors discover valid names with
`bus ui inspect icons --format json` or from the generated icon registry
published by the host. Unknown icon names fail validation before render,
including when a later control component passes through an icon name. Components
that use an icon must still provide visible text or an accessible label when
the control has meaning beyond decoration.

Icons are presentational. They do not define events, status meaning, provider
state, permissions, or navigation.

## Consequence

Icon selection improves scannability without becoming a product-state contract.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Icon](./icon)

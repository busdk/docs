---
title: UI rendering model
description: BusDK UI rendering targets, node APIs, templates, mounting, runtime errors, and browser boundaries.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Rendering Layers

The rendering model starts with output targets, then narrows into render-tree
API maps, template ownership, mounted app ownership, error handling, and
browser API boundaries. Concrete APIs and commands live in the
[version page](../) where the capability first appears.

1. Renderer targets
2. [Node APIs](../v0.1.1/node-api-map)
3. [Templates](../v0.1.4/templates)
4. [Mounting and updates](../v0.1.7/mounting-updates)
5. [Runtime errors](../v0.1.8/runtime-errors)
6. [Browser API boundaries](../v0.1.9/browser-api-boundaries)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)
- Testing

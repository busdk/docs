---
title: Library evidence
description: BusDK UI library evidence component map.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Evidence Pages

1. [Evidence URLs](./evidence-urls)
2. [Evidence links](./evidence-links)
3. [Evidence preview](../fc-019-evidence-previews/evidence-preview)
4. [Projection detail](../fc-020-projection-details/projection-detail)

The evidence helpers share one boundary: `bus-ui` validates public render input
and checked href shape, while providers and hosts own authorization, transport,
storage paths, external-origin policy, and filesystem access.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidencePreview](../fc-019-evidence-previews/evidence-preview-component)
- [Resource UI concept](../v0.4.1/resource)

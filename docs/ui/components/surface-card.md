---
title: SurfaceCard UI component
description: Dedicated BusDK UI reference for SurfaceCard.
---

## Purpose

`SurfaceCard` is a card surface component for repeated records or compact
grouped facts. It is not a page, portal, or app shell.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `children` | yes | node list | Card body. |
| `header` | no | slot node | Optional header. |
| `footer` | no | slot node | Optional footer. |

## Boundary

`SurfaceCard` may contain compact content such as `SummaryItem`, `MetricCard`,
`StatusPill`, text, form fields, and small action rows. Do not nest page or app
shells inside it, including `AppShell`, `PortalShell`, `SidebarShell`,
`SplitLayout`, or another `SurfaceCard`; use those as surrounding layout
instead.

## Example

```yaml
kind: SurfaceCard
children:
  - kind: SummaryItem
    props:
      title: Evidence note
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./panel">Panel</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./metric-card">MetricCard</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

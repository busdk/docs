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
`StatusPill`, text, form fields, and small event rows. Do not nest page or app
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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

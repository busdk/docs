---
title: MetricCard UI component
description: Dedicated BusDK UI reference for MetricCard.
---

## Purpose

`MetricCard` is a shell/layout component. Compact dashboard metric. Use for small numeric or status summaries.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string | Metric label. |
| `value` | yes | string or number | Primary value. |
| `detail` | no | string | Secondary text. |
| `status` | no | neutral, working, success, warning, danger, muted | Default `neutral`; changes color/icon semantics only, not the metric value. |

## Boundary

Title, value, and detail are escaped text. `MetricCard` does not render markup
from these fields, so user-provided labels and values can be passed after the
product layer has applied its normal authorization and data-shaping rules.

## Example

```yaml
kind: MetricCard
props:
  title: Open tasks
  value: 12
  detail: 3 blocked
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./surface-card">SurfaceCard</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./button">Button</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

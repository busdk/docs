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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

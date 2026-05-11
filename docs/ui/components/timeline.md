---
title: Timeline UI component
description: Dedicated BusDK UI reference for Timeline.
---

## Purpose

`Timeline` is a data display component. Ordered event history. Use for audit history, task progress, and assistant events.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array of `{body,status,meta,time}` | Ordered timeline entries. `body` is required escaped text or a safe node from the normal UI node/component set; raw HTML is not allowed here. `status` is optional and uses `neutral`, `working`, `success`, `warning`, `danger`, or `muted`, `meta` is optional escaped text or `{label,value}` pairs, and `time` is an optional RFC 3339 timestamp. Missing status defaults to `neutral`; empty body fails validation. |

## Boundary

Caller controls event order. `Timeline` does not sort by `time`; product view
models must supply the intended order.

## Example

```yaml
kind: Timeline
props:
  items:
    - { status: success, body: Tests passed }
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./summary-item">SummaryItem</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./empty-state">EmptyState</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

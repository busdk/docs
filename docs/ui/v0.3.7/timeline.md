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

```gx
package notesui

var taskTimeline = []TimelineItem{
  {Status: "success", Body: "Tests passed"},
}

var taskHistory = (
  <Timeline items={taskTimeline}></Timeline>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

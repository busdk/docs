---
title: EventBar UI component
description: Dedicated BusDK UI reference for EventBar.
---

## Purpose

`EventBar` is a navigation/event/form component. Ordered event group. Use for
related operations on rows, details, or results.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `events` | yes | array | Ordered items. Each item requires `label` and exactly one of `onClick` or `href`. |
| `events[].label` | yes | string | Visible control text; must be non-empty. |
| `events[].onClick` | for emitted events | function | Go callback invoked when the item is activated. |
| `events[].href` | for links | safe URL/path | Same-origin paths, host-resolved resource URLs, or `https:` links allowed by the host external-link allowlist; invalid URLs fail validation. Mutually exclusive with `onClick`. |
| `events[].variant` | no | primary, secondary, danger, ghost | Default secondary; destructive uses danger. |
| `events[].disabled` | no | boolean | Default false; disabled items render but do not emit events. |
| `alignment` | no | start, end, between | Default `start`; `start` aligns the flat event list to inline start, `end` aligns it to inline end, and `between` spaces the flat list evenly across the row. |
| `density` | no | compact, normal | Default `normal`; `compact` reduces button gap and vertical padding for table rows or dense toolbars. |

## Boundary

Destructive events use the danger variant and must be backed by product-owned
permission state. If confirmation is required, the product action carries
that confirmation policy; if the user lacks permission, set
`events[].disabled: true` or omit the entire event item instead of rendering an
enabled control that will fail late.

## Example

```gx
package reviewui

import (
  "github.com/busdk/bus-gx/pkg/gx"
  "github.com/busdk/bus-ui/pkg/ui"
)

func ReviewActions(approve func(), requestReview func()) gx.Node {
  return <EventBar events={[]ui.EventItem{
    {Label: "Approve", OnClick: approve, Variant: "primary"},
    {Label: "Request review", OnClick: requestReview},
  }}></EventBar>
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

Link targets must be same-origin paths or host-allowlisted `https:` URLs.
Reject `javascript:`, `data:`, path traversal, and credential-bearing URLs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

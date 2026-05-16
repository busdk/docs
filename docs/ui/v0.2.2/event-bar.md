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
| `events[].onClick` | for emitted events | event name | Must match a key in document `events`; the emitted source includes the `EventBar` id or tree path plus the item index so handlers can distinguish items. |
| `events[].href` | for links | safe URL/path | Same-origin paths, host-resolved resource URLs, or `https:` links allowed by the host external-link allowlist; invalid URLs fail validation. Mutually exclusive with `onClick`. |
| `events[].variant` | no | primary, secondary, danger, ghost | Default secondary; destructive uses danger. |
| `events[].disabled` | no | boolean | Default false; disabled items render but do not emit events. |
| `alignment` | no | start, end, between | Default `start`; `start` aligns the flat event list to inline start, `end` aligns it to inline end, and `between` spaces the flat list evenly across the row. |
| `density` | no | compact, normal | Default `normal`; `compact` reduces button gap and vertical padding for table rows or dense toolbars. |

## Boundary

Destructive events use the danger variant and must be backed by product-owned
permission state. If confirmation is required, the referenced event carries
that confirmation policy; if the user lacks permission, set
`events[].disabled: true` or omit the entire event item instead of emitting an
event that will fail late.

## Example

This component-only example assumes `approve` and `review` are already declared
in the runtime `events` map or registered by Go code.

```yaml
kind: EventBar
props:
  events:
    - label: Approve
      onClick: approve
      variant: primary
    - label: Request review
      onClick: review
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

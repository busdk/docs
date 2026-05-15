---
title: EmptyState UI component
description: Dedicated BusDK UI reference for EmptyState.
---

## Purpose

`EmptyState` is a data display component. Visible absence state. Use for empty filters or unavailable data.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `message` | yes | non-empty string | Visible explanation; empty or missing messages fail validation. |
| `click` | no | event name | Optional recovery event such as `clear-filters`; omitted renders text-only absence, and unresolved supplied names fail validation. |

## Boundary

Absence is visible in text.

## Example

```yaml
events:
  clear-filters:
    resource: clear-filters
resources:
  clear-filters:
    base: module
    method: GET
    path: /
view:
  kind: EmptyState
  props:
    message: No notes match the current filters
    click: clear-filters
```

Props-only text absence omits `click`:

```yaml
kind: EmptyState
props:
  message: No notes match the current filters
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

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
| `action` | no | action token | Optional recovery command such as `clear-filters`; omitted renders text-only absence, and unresolved supplied tokens fail validation. |

## Boundary

Absence is visible in text.

## Example

```yaml
actions:
  clear-filters:
    method: GET
    target: { base: module, path: / }
view:
  kind: EmptyState
  props:
    message: No notes match the current filters
    action: clear-filters
```

Text-only absence omits `action`:

```yaml
kind: EmptyState
props:
  message: No notes match the current filters
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./timeline">Timeline</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./loading-state">LoadingState</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

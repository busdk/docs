---
title: FilterToolbar UI component
description: Dedicated BusDK UI reference for FilterToolbar.
---

## Purpose

`FilterToolbar` is a navigation/action/form component. Compact filter surface. Use above tables and lists.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `action` | yes | submit action token | Filter submit. |
| `children` | yes | Field nodes | Filter controls. |
| `resetAction` | no | action token | Omitted hides reset. When present, emits the reset token; the handler should clear filter state, and the UI may also clear local draft inputs after success. |

## Boundary

Toolbar wraps without changing field names.

## Example

This component-only example assumes `search` is already declared in the
document `actions` map or registered by Go code.

```yaml
kind: FilterToolbar
props:
  action: search
children:
  - kind: Field
    props: { name: query, label: Search }
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./select">Select</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./submit-state">SubmitState</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

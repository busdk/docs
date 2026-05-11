---
title: Button UI component
description: Dedicated BusDK UI reference for Button.
---

## Purpose

`Button` is a navigation/action/form component. Native command button. Use for commands in the current workflow.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `label` | yes | string | Visible label. Use [`IconButton`](./icon-button) for icon-only controls. |
| `ariaLabel` | no | string | Optional accessible override when visible label needs clarification. |
| `action` | no | token | Emits `data-ui-action`; may be omitted only for submit/reset buttons or disabled display buttons. |
| `type` | no | button, submit, reset | Default `button`; `submit` and `reset` may omit `action` because native form behavior handles them. |
| `variant` | no | primary, secondary, danger, ghost | Default `secondary`; `primary` is the main safe action, `danger` is destructive, and `ghost` is low-emphasis chrome. |
| `size` | no | small, medium, large | Default medium. |
| `disabled` | no | boolean | Suppresses command. |

## Boundary

Button has a visible label. Interactive command buttons use a stable action
token; submit/reset or disabled display buttons may omit `action`.

## Example

```yaml
kind: Button
props:
  label: Save
  action: save-draft
  variant: primary
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./metric-card">MetricCard</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./icon-button">IconButton</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

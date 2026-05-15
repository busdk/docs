---
title: AIApprovals UI component
description: Dedicated BusDK UI reference for AIApprovals.
---

## Purpose

`AIApprovals` is an assistant component. Pending approval list. Use before applying generated work or executing protected commands.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array of `{requestID,title,summary}` | `requestID` and `title` are required strings; `requestID` values must be unique, and duplicates fail validation. `summary` is optional display text. |
| `approve` | yes | event name | Runs when an approve control is activated. Source id format is `<component-id>/<requestID>/approve`; decision value is `approve`. |
| `reject` | yes | event name | Runs when a reject control is activated. Source id format is `<component-id>/<requestID>/reject`; decision value is `reject`. |

## Boundary

If the provider/controller rejects the decision before it is applied, render
`ProviderError` with the provider-safe error. If the decision is accepted but
produces a normal workflow result, render `ResultPanel` with that result state.
The event itself does not carry the request payload; the controller resolves
the approval request from the activated source id.

## Example

```yaml
kind: AIApprovals
props:
  items:
    bind: ai.approvals
  approve: approve
  reject: reject
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

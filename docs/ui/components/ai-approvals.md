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
| `approveAction` | yes | action token | Emits `{requestID, decision:"approve"}` and `requestID` must match an item. |
| `rejectAction` | yes | action token | Emits `{requestID, decision:"reject"}` and `requestID` must match an item. |

## Boundary

If the provider/controller rejects the decision before it is applied, render
`ProviderError` with the provider-safe error. If the decision is accepted but
produces a normal workflow result, render `ResultPanel` with that result state.

## Example

```yaml
kind: AIApprovals
props:
  items: { bind: ai.approvals }
  approveAction: approve
  rejectAction: reject
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-composer">AIComposer</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-review-status">AIReviewStatus</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

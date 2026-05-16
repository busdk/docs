---
title: AIApprovals UI component
description: Dedicated BusDK UI reference for AIApprovals.
---

## Purpose

`AIApprovals` is an assistant component. Pending approval list. Use before applying generated work or executing protected commands.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | yes | string | Stable component id used in diagnostics and control ids. |
| `items` | yes | `[]AIApprovalItem` | `RequestID` and `Title` are required strings; `RequestID` values must be unique, and duplicates fail validation. `Summary` is optional display text. |
| `onApprove` | yes | `func(AIApprovalEvent) gx.Result` | Runs when an approve control is activated. Event `Decision` is `"approve"`. |
| `onReject` | yes | `func(AIApprovalEvent) gx.Result` | Runs when a reject control is activated. Event `Decision` is `"reject"`. |

## Boundary

If product callback code rejects the decision before it is applied, the parent
view should render [`ProviderError`](../fc-007-provider-errors/provider-error-component) with the
provider-safe error. If the decision is accepted and produces normal workflow
state, the parent view renders its own result component. The callback event does
not carry the request payload; the controller resolves the approval request from
`RequestID`.

## Example

```gx
var approvals = <AIApprovals
  id="approval-list"
  items={ai.Approvals}
  onApprove={approveWork}
  onReject={rejectWork}>
</AIApprovals>
```

```go
type AIApprovalItem struct {
	RequestID string
	Title string
	Summary string
}

type AIApprovalEvent struct {
	SourceID string
	RequestID string
	Decision string
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

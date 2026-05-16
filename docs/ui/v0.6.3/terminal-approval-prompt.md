---
title: TerminalApprovalPrompt UI component
description: Dedicated BusDK UI reference for TerminalApprovalPrompt.
---

## Purpose

`TerminalApprovalPrompt` is a terminal component. Command approval prompt. Use when a command waits for explicit approval.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string | Prompt title. |
| `decisions` | yes | `[]TerminalApprovalDecision` | Approval decisions for one pending request. `Label` is public-safe text, `Decision` is `approve` or `deny`, `RequestID` is the stable pending request id, and `OnClick` is `func(TerminalApprovalEvent) gx.Result`. Duplicate `(RequestID, Decision)` pairs fail validation. |
| `summary` | yes | string | Public-safe command context shown before decisions. It must identify the requested command or operation, relevant working directory or target, and why approval is needed without including secrets, tokens, or private file contents. Empty or omitted summaries fail validation so hosts do not render decisions without user-visible detail. |

## Boundary

Decision controls use stable source ids derived from the pending request and
decision so the host can submit exactly one decision for the pending request.
The component renders decisions only; command authorization policy stays in the
host runtime.

Selecting a decision calls `OnClick` with `RequestID`, `Decision`, and
`SourceID`. The component disables all decisions for that request immediately
after the first click. A [runtime result](../v0.4.1/runtime-contract) with kind
`success` keeps decisions disabled and the parent removes the prompt on the next
render. Result kind `provider-error` keeps the prompt visible and re-enables
decisions only when the parent supplies a refreshed approval state with the same
`RequestID`. Repeated clicks for the same `(RequestID, Decision)` are ignored
while pending.

## Example

```gx
var approvalDecisions = []TerminalApprovalDecision{
  {
    Label: "Approve",
    Decision: "approve",
    RequestID: "req-123",
    OnClick: approveCommand,
  },
  {
    Label: "Deny",
    Decision: "deny",
    RequestID: "req-123",
    OnClick: denyCommand,
  },
}

var approvalPrompt = <TerminalApprovalPrompt
    title="Approve command?"
    summary="Run `make test` in `/workspace/bus-ui` with network disabled."
    decisions={approvalDecisions}>
</TerminalApprovalPrompt>
```

```go
type TerminalApprovalDecision struct {
	Label string
	Decision string
	RequestID string
	OnClick func(TerminalApprovalEvent) gx.Result
}

type TerminalApprovalEvent struct {
	SourceID string
	RequestID string
	Decision string
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

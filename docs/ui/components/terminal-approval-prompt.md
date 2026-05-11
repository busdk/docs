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
| `actions` | yes | array of `{label,action,requestID}` | Approval decisions for one pending request. `label` is public-safe text, `action` is one of the declared decision tokens such as `approve-command`, `deny-command`, or a host-registered equivalent, and `requestID` is the stable string or number of the pending request. Multiple decisions for the same request share the same `requestID`; duplicate `(requestID, action)` pairs fail validation. Unknown action tokens fail validation. |
| `summary` | no | string | Command details. |

## Boundary

Decision actions include stable request IDs so the host can submit exactly one
decision for the pending request. The component renders decisions only; command
authorization policy stays in the host/runtime.

Selecting a decision emits the chosen action token with payload
`{requestID, action}`. The component disables all decisions for that request
after the first click until the host confirms, rejects, or refreshes the pending
approval state; repeated clicks for the same `(requestID, action)` are ignored.

## Example

```yaml
kind: TerminalApprovalPrompt
props:
  title: Approve command?
  actions:
    - { label: Allow, action: approve-command, requestID: 17 }
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./terminal-input-box">TerminalInputBox</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./terminal-session-adapter">TerminalSessionAdapter</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

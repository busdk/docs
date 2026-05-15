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
| `events` | yes | array of `{label,click,requestID}` | Approval decisions for one pending request. `label` is public-safe text, `click` is one of the declared decision tokens such as `approve-command`, `deny-command`, or a host-registered equivalent, and `requestID` is the stable string or number of the pending request. Multiple decisions for the same request share the same `requestID`; duplicate `(requestID, click)` pairs fail validation. Unknown event names fail validation. |
| `summary` | yes | string | Public-safe command context shown before decisions. It must identify the requested command or operation, relevant working directory or target, and why approval is needed without including secrets, tokens, or private file contents. Empty or omitted summaries fail validation so hosts do not render decisions without user-visible detail. |

## Boundary

Decision controls use stable source ids derived from the pending request and
decision so the host can submit exactly one decision for the pending request.
The component renders decisions only; command authorization policy stays in the
host/runtime.

Selecting a decision runs the chosen event name with source identity. The
component disables all decisions for that request
after the first click until the host confirms, rejects, or refreshes the pending
approval state; repeated clicks for the same `(requestID, click)` are ignored.

## Example

```yaml
kind: TerminalApprovalPrompt
props:
  title: Approve command?
  summary: Run `make test` in `/workspace/bus-ui` with network disabled.
  events:
    - label: Allow
      click: approve-command
      requestID: 17
    - label: Deny
      click: deny-command
      requestID: 17
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

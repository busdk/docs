---
title: Library terminal approvals
description: BusDK UI library terminal command approval prompt contract.
---

## Design References

- [Binding](../v0.1.5/binding)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TerminalApprovalPrompt`](./terminal-approval-prompt) renders
allow and deny decisions for one pending command request. Decision events
identify the decision source and disable repeated decisions until state
refresh.

| Field | Required | Behavior |
| --- | --- | --- |
| `requestID` | yes | Stable non-empty public id for one pending command decision. |
| `title` | yes | Public-safe non-empty decision title. |
| `summary` | yes | Public-safe command summary; no raw secrets or tokens. |
| `allow` | no | Runtime event name for allowing the command; omitted hides allow. |
| `deny` | no | Runtime event name for denying the command; omitted hides deny. |

Decision events emit source identity plus request id and decision:

```yaml
event: allow-command
source:
  id: terminal-approval
  path: /TerminalSessionPanel[0]/TerminalApprovalPrompt[0]
item:
  requestID: approve-123
decision: allow
```

The emitted `event` value is the configured `allow` value for allow decisions
and the configured `deny` value for deny decisions. Deny uses the same shape
with `decision: deny`.

The controller records the decision, updates terminal state, and triggers or
blocks command execution. Controls stay disabled until the refreshed state
removes or resolves the pending request.

## Consequence

Approval UI is reusable because decision effects are controller-owned.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalApprovalPrompt](./terminal-approval-prompt)
- [Event UI concept](../v0.1.6/event)

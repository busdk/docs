---
title: Library assistant approvals
description: BusDK UI library assistant approval and review state contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIApprovals`](./ai-approvals) renders pending approval items.
Approval items require stable request ids and public titles. Decision events
identify the decision source and disable repeated decisions until state refresh.

| Field | Required | Behavior |
| --- | --- | --- |
| `requestID` | yes | Stable public id for one pending decision; no secrets or provider payload. |
| `title` | yes | Public-safe summary of the requested action. |
| `summary` | no | Public-safe detail text. |
| `state` | no | `pending`, `approved`, `rejected`, or `expired`; defaults to `pending`. |
| `approve` | no | Runtime event name for approving a pending item; omitted hides approve. |
| `reject` | no | Runtime event name for rejecting a pending item; omitted hides reject. |

Decision events emit source identity plus request id:

```yaml
event: approve-request
source:
  id: approvals
  path: /AIPanel[0]/AIApprovals[0]
item:
  requestID: req-123
decision: approve
```

[browser API boundaries](../v0.1.9/browser-api-boundaries) cover browser close protection when the product
view model reports pending approvals. The controller clears the guard after all
items become approved, rejected, expired, or removed. The user-facing result is
a browser close warning plus visible pending approval state.

## Consequence

Approval rendering is generic. The controller owns what an approval means and
what happens after a decision.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIApprovals](./ai-approvals)
- [Browser API boundaries](../v0.1.9/browser-api-boundaries)

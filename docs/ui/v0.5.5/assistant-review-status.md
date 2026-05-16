---
title: Library assistant review status
description: BusDK UI library assistant review-before-apply status contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIReviewStatus`](./ai-review-status) renders review-before-apply
state for assistant changes.

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `state` | yes | enum string | `waiting` means review has not started, `reviewing` means checks are running, `approved` means apply may proceed, `rejected` means apply is blocked by decision, and `error` means review failed. |
| `title` | yes | string | Public-safe review summary. |
| `summary` | no | string | Public-safe detail text. |
| `requestID` | no | string | Public support/review id. |

Public-safe text may name the review stage, changed file, status, or request
id. It must not include tokens, secrets, raw provider payloads, stack traces,
SQL, private customer data, or credential headers.

The component renders status only. Approval or rejection events belong to
[assistant approvals](./assistant-approvals).

## Consequence

Review status is visible state. Decision behavior stays in approval controls
and controller handlers.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIReviewStatus](./ai-review-status)
- [State UI concept](../v0.3.8/state)

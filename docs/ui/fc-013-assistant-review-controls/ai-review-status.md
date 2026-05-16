---
title: AIReviewStatus UI component
description: Dedicated BusDK UI reference for AIReviewStatus.
---

## Purpose

`AIReviewStatus` is an assistant component. Review-before-apply status. Use to summarize diffs and verification before apply.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `files` | yes | array of `{path,status,summary}` | `path` and `status` are required; `status` is `added`, `modified`, `deleted`, or `unchanged`; `summary` optional. |
| `status` | yes | pending, passed, failed, blocked | `pending` before checks, `passed` when review and tests pass, `failed` on failed verification, `blocked` when review cannot continue. |
| `verification` | no | `{name,status,summary}` array or string | For object arrays, `name` and `status` are required, `summary` is optional, and status is `passed`, `failed`, or `skipped`; a string renders as a compact summary. |

## Boundary

Actual apply/approval uses [`AIApprovals`](./ai-approvals) with `onApprove` and
`onReject` callback props. Provider callbacks return the
[runtime result](../fc-003-resources/runtime-contract) that the parent view projects into
review state or a safe provider error.

## Example

```gx
var reviewFiles = []AIReviewFile{
  {Path: "notes.gx", Status: "modified", Summary: "Updates composer state."},
}

var review = <AIReviewStatus files={reviewFiles} status="pending"></AIReviewStatus>
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../fc-003-resources/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

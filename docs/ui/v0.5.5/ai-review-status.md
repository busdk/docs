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

Actual apply/approval uses `AIApprovals` or provider events.

## Example

```yaml
kind: AIReviewStatus
props:
  files:
    bind: review.files
  status: pending
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

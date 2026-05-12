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

Actual apply/approval uses `AIApprovals` or provider actions.

## Example

```yaml
kind: AIReviewStatus
props:
  files: { bind: review.files }
  status: pending
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-approvals">AIApprovals</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-thread-isolation">AIThreadIsolation</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

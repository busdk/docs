---
title: Library assistant work isolation
description: BusDK UI library assistant work ownership and drop intake contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)

## Contract

[`AIThreadIsolation`](./ai-thread-isolation) renders work ownership,
branch, worktree, conflict, and active-work state supplied by the controller.
[`AIDropController`](../v0.5.3/ai-drop-controller) renders assistant drop
intake state and emits accepted drop identity.

`AIThreadIsolation` receives these controller-owned fields:

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `threadID` | yes | string | Stable assistant thread id. |
| `owner` | no | string | Public owner label for the active work context. |
| `branch` | no | string | Public branch label. |
| `worktree` | no | string | Public worktree label or relative path. |
| `active` | no | boolean | Defaults false; true marks the work context busy. |
| `conflict` | no | enum string | `none`, `dirty`, `claimed`, `missing`, or `error`; omitted equals `none`. |
| `detail` | no | string | Public-safe conflict detail. |

`AIDropController` accepts a drop only after host policy has identified the
object.

| Prop | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | yes | string | Stable source id used in emitted events. |
| `accept` | no | string array | Accepted public object kinds such as `file`, `url`, or `evidence`; omitted accepts the host default set. |
| `disabled` | no | boolean | Defaults false; true rejects new drops visually and does not emit events. |
| `drop` | no | event name string | Runtime event emitted after a drop is accepted; omitted renders drop state without emitting. |

The emitted `drop` object has string `id`, enum string `kind`, and string
`name`. It emits the configured drop event with this identity:

```yaml
event: attach-drop
source:
  id: assistant-drop
  path: /AIPanel[0]/AIDropController[0]
drop:
  id: drop-123
  kind: file
  name: notes.txt
```

Conflict states other than `none` render blocking: submit/apply controls inside
the same assistant surface are disabled and the status is exposed to assistive
technology. The controller clears `dirty` after the user chooses a clean
worktree, `claimed` after ownership changes, `missing` after the work context is
recreated, and `error` after retry or dismissal. Drop policy, filesystem access,
and worktree mutation stay outside the component.

## Consequence

Assistant work boundaries are visible without giving UI components ownership of
workspace operations.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIThreadIsolation](./ai-thread-isolation)
- [AIDropController](../v0.5.3/ai-drop-controller)

---
title: AIThreadIsolation UI component
description: Dedicated BusDK UI reference for AIThreadIsolation.
---

## Purpose

`AIThreadIsolation` is an assistant component. Assistant work isolation display. Use to show work ownership and conflicts.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `owner` | yes | string | Display owner such as a module id or agent id; rendered as text only and not used for authorization. |
| `worktree` | yes | path string | Display path to the isolated worktree; absolute paths are allowed for diagnostics and are never used for filesystem access. |
| `branch` | yes | string | Git branch name shown for coordination; must be display text, not a command argument. |
| `conflict` | no | false, true, worktree, branch, dirty | Default `false`. `true` renders a generic conflict; string values show the specific conflict source. |

## Boundary

Infrastructure enforces isolation; this component displays it.

## Example

```yaml
kind: AIThreadIsolation
props:
  owner: bus-ui
  branch: ui-framework
  worktree: /workspace/bus-ui
```

## Runtime Terms

Isolation fields are display diagnostics only. The component must never use
`owner`, `worktree`, `branch`, or `conflict` values to run commands, grant
permissions, or access the filesystem.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-review-status">AIReviewStatus</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-drop-controller">AIDropController</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

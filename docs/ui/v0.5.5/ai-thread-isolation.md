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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

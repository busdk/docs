---
title: Library assistant threads
description: BusDK UI library assistant thread list contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIThreadList`](./ai-thread-list) renders assistant threads with
stable `ID` and `Title` fields. `Working` defaults false. Selection calls the
configured `onSelect` callback with the selected `ThreadID`.

| Thread field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `ID` | yes | string | Stable controller-owned thread id. |
| `Title` | yes | string | Escaped display title. |
| `Working` | no | bool | Item field, not a component prop. Defaults false; true marks that row as busy and exposes the busy state to assistive technology. |

The `onSelect` prop is required when rows are selectable. Omit it only for a
read-only thread list; rows then render as inert list items. The callback shape
is:

```go
func selectThread(event AIThreadEvent) gx.Result {
	return openThread(event.ThreadID)
}

type AIThreadEvent struct {
	ThreadID string
}
```

Thread ownership, branch/worktree details, and provider run state stay in the
product view model.

## Consequence

Thread selection is reusable without moving assistant workflow ownership into
the component.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIThreadList](./ai-thread-list)
- [Callback props](../v0.1.6/callback-props)

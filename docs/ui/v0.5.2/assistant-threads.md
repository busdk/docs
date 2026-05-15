---
title: Library assistant threads
description: BusDK UI library assistant thread list contract.
---

## Design References

- [Binding](../v0.1.5/binding)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIThreadList`](./ai-thread-list) renders assistant threads with
stable `id` and `title` fields. `working` defaults false. Selection emits the
configured event with source identity for the selected row.

| Thread field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | yes | string | Stable controller-owned thread id. |
| `title` | yes | string | Escaped display title. |
| `working` | no | boolean | Item field, not a component prop. Defaults false; true marks that row as busy and exposes the busy state to assistive technology. |

The selection event name comes from the component `select` prop and must exist
in the runtime `events` map or Go event router. The emitted event shape is:

```yaml
event: select-thread
source:
  id: thread-list
  path: /AIPanel[0]/AIThreadList[0]
item:
  id: thread-123
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
- [Event UI concept](../v0.1.6/event)

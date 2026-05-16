---
title: AIThreadList UI component
description: Dedicated BusDK UI reference for AIThreadList.
---

## Purpose

`AIThreadList` renders selectable assistant thread summaries when a product
view shows more than one assistant conversation.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `threads` | yes | `[]AIThreadSummary` | `ID` and `Title` are required strings; `Working` defaults false and shows active-work state. |
| `onSelect` | no | `func(AIThreadEvent) gx.Result` | Runs when a thread row is selected. Omit for a read-only list with inert rows. `ThreadID` identifies the selected thread. |
| `onArchive` | no | `func(AIThreadEvent) gx.Result` | Runs when an archive control is activated. `ThreadID` identifies the archived thread; omit to hide archive. |

## Boundary

Selecting or archiving identifies the activated `ThreadID`. Product views must
resolve that id against the current thread list and reject missing or stale
items before changing conversation state.

## Example

```gx
var threadList = <AIThreadList
  threads={ai.Threads}
  onSelect={selectThread}
  onArchive={archiveThread}>
</AIThreadList>
```

```go
type AIThreadEvent struct {
	ThreadID string
}

type AIThreadSummary struct {
	ID      string
	Title   string
	Working bool
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: Library assistant panel
description: BusDK UI library assistant panel composition contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)

## Contract

[`AIPanel`](./ai-panel) is the combined assistant surface. It receives active
thread, thread list, messages, model state, and callback props for assistant
actions. Omitted optional lists default empty. Omitted callbacks hide matching
interactive controls.

| Prop | Required | Behavior |
| --- | --- | --- |
| `activeThread` | no | Selected thread id; omitted renders no active thread selection. |
| `threads` | no | `[]AIThreadSummary`; newest or controller-sorted order is preserved; defaults empty and renders the empty thread state. |
| `messages` | no | `[]AIMessage`; oldest-to-newest order is preserved; defaults empty and renders the empty transcript state. |
| `model` | no | Selected model id or label supplied by the controller. |
| `onSend` | no | `func(AISendEvent) gx.Result`; omitted hides send. |
| `onInterrupt` | no | `func(AIInterruptEvent) gx.Result`; omitted hides interrupt. |

The prop structures are:

```go
type AIThreadSummary struct {
	ID      string
	Title   string
	Working bool
}

type AIMessage struct {
	Role string
	Text string
	HTML string
	Trusted string
}
```

`ID` and `Title` are required for each thread. `Role` is `user`, `assistant`, or
`system`; each message has exactly one of `Text` or sanitized `HTML`. `Trusted`
must be `ai-markdown` when `HTML` is set.

`AISendEvent` and `AIInterruptEvent` carry `ThreadID string` only. The
controller reads current draft text, selected model, and attachment ids from
owned view state at handling time.

`AIPanel` should be used inside [`AssistantShell`](../v0.5.1/assistant-shell)
when the product screen pairs business content with assistant work.

## Example

```gx
var panel = <AssistantShell>
  <Panel slot="business" title="Work item">
    <Text value={workSummary}></Text>
  </Panel>
  <AIPanel
    slot="assistant"
    activeThread={activeThread}
    model={model}
    threads={threads}
    messages={messages}
    onSend={sendMessage}
    onInterrupt={interruptRun}>
  </AIPanel>
</AssistantShell>
```

## Consequence

The panel composes assistant state. Product modules own task meaning,
permissions, model availability, and provider policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIPanel](./ai-panel)
- [AssistantShell](../v0.5.1/assistant-shell)

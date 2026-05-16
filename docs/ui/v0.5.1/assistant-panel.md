---
title: Library assistant panel
description: BusDK UI library assistant panel composition contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Expression children](../v0.1.5/expression-children)

## Contract

[`AIPanel`](./ai-panel) is the combined assistant surface. It
receives active thread, thread list, messages, model state, and event names for
assistant actions. Omitted optional lists default empty. Omitted event names
hide matching interactive controls.

| Prop | Required | Behavior |
| --- | --- | --- |
| `activeThread` | no | Selected thread id; omitted renders no active thread selection. |
| `threads` | no | Array of thread summaries; newest or controller-sorted order is preserved; defaults empty and renders the empty thread state. |
| `messages` | no | Array of assistant messages; oldest-to-newest order is preserved; defaults empty and renders the empty transcript state. |
| `model` | no | Selected model id or label supplied by the controller. |
| `send` | no | Runtime event name for submitting the draft; omitted hides send. |
| `interrupt` | no | Runtime event name for stopping active work; omitted hides interrupt. |

The `send` event emits source identity only:

```yaml
event: send-message
source:
  id: assistant-panel
  path: /AssistantShell[0]/AIPanel[0]
```

The `interrupt` event uses the same source shape with its configured event
name. The controller reads current draft text, active thread id, selected model,
and attachment ids from owned view state at handling time.

`AIPanel` should be used inside [`AssistantShell`](../v0.5.1/assistant-shell)
when the product screen pairs business content with assistant work.

## Example

```html
<AssistantShell>
  <Panel slot="business" title="Work item">
    <Text value={workSummary}></Text>
  </Panel>
  <AIPanel
    slot="assistant"
    active-thread={activeThread}
    model={model}
    threads={threads}
    messages={messages}
    send="send-message"
    interrupt="interrupt-run">
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

---
title: Library assistant panel
description: BusDK UI library assistant panel composition contract.
---

## Contract

[`AIPanel`](./ai-panel) is the assistant pane surface used inside
[`AssistantShell`](./assistant-shell). It gives product screens a consistent
assistant region while leaving thread lists, transcripts, composers, model
controls, approvals, and attachments to focused child components.

| Prop | Required | Behavior |
| --- | --- | --- |
| `title` | no | Short pane label; default is `Assistant`. |
| `children` | yes | `gx.Node` content rendered in the assistant surface. |
| `status` | no | Compact busy, idle, or error label supplied by the product view model. |
| `onClose` | no | `func(AIPanelCloseEvent) gx.Result`; omitted hides the close control. |

The close callback is ordinary Go:

```go
type AIPanelCloseEvent struct {
	Reason string
}
```

Product screens own conversation state and pass focused child components as
children when those features are available.

## Example

```gx
var panel = <AssistantShell>
  <Panel slot="business" title="Work item">
    <Text value={workSummary}></Text>
  </Panel>
  <AIPanel slot="assistant" title="Assistant" status={assistantStatus}>
    <Text value={assistantSummary}></Text>
  </AIPanel>
</AssistantShell>
```

## Consequence

The panel owns assistant-pane framing. Product modules own task meaning,
conversation state, permissions, model availability, and provider policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIPanel](./ai-panel)
- [AssistantShell](./assistant-shell)
- [Expression children](../v0.1.5/expression-children)

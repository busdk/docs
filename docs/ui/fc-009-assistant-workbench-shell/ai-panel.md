---
title: AIPanel UI component
description: Dedicated BusDK UI reference for AIPanel.
---

## Purpose

`AIPanel` is the assistant-pane frame for a workbench. Use it inside
`AssistantShell` when a product screen needs a consistent assistant surface for
child components.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | no | string | Pane title; default `Assistant`. |
| `status` | no | string | Short status text, such as `Idle`, `Working`, or a product error label. |
| `children` | yes | `gx.Node` | Assistant content composed from focused Bus UI components. |
| `onClose` | no | `func(AIPanelCloseEvent) gx.Result` | Enables the close control. Omit when the pane is controlled only by the surrounding shell. |

## Boundary

`AIPanel` does not own conversation records, provider runs, file writes, command
execution, or approval decisions. It renders the child nodes it receives and
emits only the close callback when that prop is supplied.

```go
type AIPanelCloseEvent struct {
	Reason string
}
```

`Reason` is `button` when the panel close button is activated and `keyboard`
when the host maps an accepted keyboard close gesture to the panel callback.
The component emits no other reason values in this candidate.

## Example

```gx
var panel = <AIPanel
  title="Assistant"
  status={assistantStatus}
  onClose={closeAssistant}>
  <Text value={assistantSummary}></Text>
</AIPanel>
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props,
validation, and confirmation policy. When `onClose` is omitted, the local close
control is hidden.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

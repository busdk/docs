---
title: Library terminal input
description: BusDK UI library terminal stdin control contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TerminalInputBox`](./terminal-input-box) renders terminal stdin
controls. Send and stop events identify the terminal input and session source.
The controller owns draft input text and session state.

| Prop | Required | Behavior |
| --- | --- | --- |
| `sessionID` | yes | Public terminal session id included in emitted item identity. |
| `value` | no | Draft stdin text; defaults empty. |
| `onChange` | no | Runtime event name for draft text changes. Omitted makes the input display-only. |
| `onSubmit` | no | Runtime event name for stdin submit. Omitted disables send. |
| `stop` | no | Runtime event name for stopping active work. Omitted hides stop. |
| `state` | yes | Terminal session state: `idle`, `running`, `waiting`, `exited`, or `error`. |
| `disabled` | no | Boolean; defaults false. |

Text edits emit the `onChange` prop value with source identity, session id, and
the current draft text. Submit payloads intentionally omit text; the controller
uses the latest draft in its model when handling submit.

```go
draftEvent := TerminalInputEvent{
    Event: "terminal-draft",
    Source: EventSource{
        ID:   "terminal-input",
        Path: "/TerminalSessionPanel[0]/TerminalInputBox[0]",
    },
    Item:  TerminalInputItem{SessionID: "session-123"},
    Draft: "echo hello",
}
```

Send emits the `onSubmit` prop value. In this example, `onSubmit` is
`terminal-stdin`:

```go
submitEvent := TerminalInputEvent{
    Event: "terminal-stdin",
    Source: EventSource{
        ID:   "terminal-input",
        Path: "/TerminalSessionPanel[0]/TerminalInputBox[0]",
    },
    Item: TerminalInputItem{SessionID: "session-123"},
}
```

The controller writes process stdin from its current draft model. The `event`
value is the `onSubmit` prop value.

Stop emits the `stop` prop value with the same source and session identity:

```go
stopEvent := TerminalInputEvent{
    Event: "stop-terminal",
    Source: EventSource{
        ID:   "terminal-input",
        Path: "/TerminalSessionPanel[0]/TerminalInputBox[0]",
    },
    Item: TerminalInputItem{SessionID: "session-123"},
}
```

Input is disabled when `state` is not `running`, when `disabled` is true, or
when `onSubmit` is omitted. Stop is enabled only during `running` state when
`stop` is present.

## Consequence

Terminal input emits interaction identity. The product controller or terminal
adapter owns process IO, stdin writes, stop requests, and resulting output
events.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalInputBox](./terminal-input-box)
- [Callback props](../v0.1.6/callback-props)

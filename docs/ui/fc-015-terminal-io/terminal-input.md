---
title: Library terminal input
description: BusDK UI library terminal stdin control contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TerminalInputBox`](./terminal-input-box) renders terminal stdin
controls. Send and exit callbacks identify the terminal input and session source.
The controller owns draft input text and session state.

| Prop | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | no | string | Stable source id copied to callback events. When omitted, the generated tree path is used. |
| `sessionID` | yes | string | Public terminal session id included in emitted item identity. |
| `value` | no | string | Draft stdin text; defaults empty. |
| `onChange` | no | `func(TerminalInputChangeEvent) gx.Result` | Receives draft text changes. Omit for a display-only input. |
| `onSend` | no | `func(TerminalInputEvent) gx.Result` | Receives stdin submit with the current text. Omitted disables send. |
| `onExit` | no | `func(TerminalExitEvent) gx.Result` | Requests external process termination. Omitted hides the exit control. |
| `state` | yes | string | Terminal session state: `idle`, `running`, `waiting`, `exited`, or `error`. |
| `disabled` | no | boolean | Defaults false. |

Text edits call `onChange` with source identity, session id, and the current
draft text. Send calls `onSend` with the same identity plus the submitted text.

```go
type TerminalInputChangeEvent struct {
	SessionID string
	SourceID  string
	Text      string
}

type TerminalInputEvent struct {
	SessionID string
	SourceID  string
	Text      string
}

type TerminalExitEvent struct {
	SessionID string
	SourceID  string
}
```

Input is disabled when `state` is not `running`, when `disabled` is true, or
when `onSend` is omitted. Exit is enabled only during `running` or `waiting`
state when `onExit` is present.

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

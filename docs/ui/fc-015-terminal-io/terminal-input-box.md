---
title: TerminalInputBox UI component
description: Dedicated BusDK UI reference for TerminalInputBox.
---

## Purpose

`TerminalInputBox` is a terminal component. Terminal stdin controls. Use when a running session accepts input.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | no | string | Stable source id copied into callback events. When omitted, the renderer-generated tree path is used. |
| `sessionID` | yes | string | Host session identifier targeted by stdin and exit callbacks. Empty string suppresses controls. |
| `value` | yes | string | Current controlled input value. The parent updates this value through normal Go state after `onSend` succeeds or clears the draft. |
| `onChange` | no | `func(TerminalInputChangeEvent) gx.Result` | Runs when typed text changes. Omit only when the input is read-only or the host owns an internal draft buffer. |
| `onSend` | yes | `func(TerminalInputEvent) gx.Result` | Runs when the user submits input. Event includes `SessionID`, `SourceID`, and `Text`. Empty values are ignored by default; a host may enable empty stdin through terminal runtime config. |
| `onExit` | no | `func(TerminalExitEvent) gx.Result` | Runs when the user requests process termination. Omitted `onExit` removes the stop/exit control; it does not close the panel locally. |
| `disabled` | no | boolean | Disables controls. |

## Boundary

Parents disable input for closed sessions by setting `disabled={true}` or
clearing `sessionID`. `TerminalInputBox` calls interaction callbacks only; the
host runtime decides whether stdin is accepted, which session is targeted, and
whether process termination is authorized.

## Example

```gx
var inputBox = <TerminalInputBox
    id="terminal-input"
    sessionID="test-17"
    value={terminalInput}
    onChange={setTerminalInput}
    onSend={sendInput}
    onExit={stopSession}>
</TerminalInputBox>
```

```go
type TerminalInputEvent struct {
	SessionID string
	SourceID string
	Text string
}

type TerminalInputChangeEvent struct {
	SessionID string
	SourceID string
	Text string
}

type TerminalExitEvent struct {
	SessionID string
	SourceID string
}

func setTerminalInput(event TerminalInputChangeEvent) gx.Result {
	terminalInput = event.Text
	return gx.Noop()
}

func sendInput(event TerminalInputEvent) gx.Result {
	return terminal.Send(event.SessionID, event.Text)
}

func stopSession(event TerminalExitEvent) gx.Result {
	return terminal.Stop(event.SessionID)
}
```

`SourceID` comes from `id` or the generated tree path. Handlers use it only to
distinguish multiple input boxes; `SessionID` remains the process target.

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

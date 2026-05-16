---
title: TerminalSessionPanel UI component
description: Dedicated BusDK UI reference for TerminalSessionPanel.
---

## Purpose

`TerminalSessionPanel` is a terminal component. Complete terminal surface. Use for command sessions with output and input.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `state` | yes | idle, running, waiting, exited, error | Session state. `idle` shows no active process, `running` shows output plus stdin controls when `onSubmit` exists, `waiting` shows output plus approval/input waiting state, `exited` shows final output plus the latest `system` output chunk as the exit summary, and `error` shows terminal error state. |
| `sessionID` | no | string | Stable host session identifier. When omitted, handlers must identify the active session from route or host context. |
| `command` | yes | string | Displayed command. |
| `output` | yes | `[]TerminalChunk` | Ordered chunks with required `Stream` and `Text`, plus optional non-negative integer `Sequence`. `Stream` is one of `stdout`, `stderr`, `stdin`, or `system`. Chunks render in supplied order unless every chunk has `Sequence`, in which case ascending `Sequence` order is used. Missing `Sequence` is treated as unset, not zero. |
| `onSubmit` | no | `func(TerminalSubmitEvent) gx.Result` | Sends stdin when state is `running` or `waiting`. The input control appears only in those two states and only when this callback is present. |
| `onExit` | no | `func(TerminalExitEvent) gx.Result` | Requests external process termination through the host runtime. It does not close the panel by itself. The host runtime reads session identity and applies confirmation/authorization before terminating. |

## Boundary

The component only renders terminal state and calls callbacks. The host runtime
must authorize command start, stdin submission, and exit requests before callback
handlers run.

## Example

```gx
var sessionPanel = <TerminalSessionPanel
    state="running"
    sessionID="test-17"
    command="make test"
    onSubmit={terminalStdin}
    onExit={terminalExit}
    output={terminalOutput}>
</TerminalSessionPanel>
```

```go
type TerminalChunk struct {
	Stream string
	Text string
	Sequence *int
}

type TerminalSubmitEvent struct {
	SessionID string
	SourceID string
	Text string
}

type TerminalExitEvent struct {
	SessionID string
	SourceID string
}
```

`SourceID` is the component id or generated tree path. `SessionID` is copied
from the `sessionID` prop when present; otherwise the host runtime resolves the
active session from route or host context before calling the callback. `Text` is
the submitted stdin value for `TerminalSubmitEvent`.

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

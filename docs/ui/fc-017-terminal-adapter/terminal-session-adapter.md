---
title: TerminalSessionAdapter UI helper
description: Dedicated BusDK UI reference for TerminalSessionAdapter.
---

## Purpose

`TerminalSessionAdapter` is a terminal helper function. Use it before rendering
terminal event streams.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `events` | yes | `[]TerminalEvent` | Raw or normalized terminal events ordered by source time. Supported types are `session.started`, `stream.stdout`, `stream.stderr`, `stream.stdin`, `approval.requested`, `session.exited`, and `session.error`. |
| `approvals` | no | `[]TerminalApprovalDecision` | Pending approvals keyed by `RequestID`. Approvals match events by the same stable `RequestID`; approvals with no matching event are still rendered as pending host requests. |
| `metadata` | no | `TerminalSessionMetadata` | Optional session metadata: `SessionID`, `Command`, `CWD`, `ProcessID`, and `StartedAt` as `time.Time`. Omitted fields render as unknown/blank display values and do not fail validation. |

## Boundary

Renderer receives normalized terminal props, not raw event parsing rules.
`TerminalSessionAdapter` returns `TerminalSessionProps` with `SessionID`, `State`,
`Command`, `CWD`, `Output`, `Approvals`, and `Exit`. `Output` uses the same chunk
schema as [TerminalOutputView](../fc-015-terminal-io/terminal-output-view), `Approvals` use
[TerminalApprovalPrompt](../fc-016-terminal-approvals/terminal-approval-prompt) decisions, and
`Exit` is present when exit state is known.

Output `state` is `idle` before a start event, `running` after
`session.started`, `waiting` while approvals are pending, `exited` after
`session.exited`, and `error` after `session.error`. Stream events append output
chunks; approval events append or update pending approvals; exit/error events
set `exit` and stop accepting stdin in downstream panels.

## Example

```gx
var terminal = func() gx.Node {
  props := TerminalSessionAdapter(terminalEvents, terminalApprovals, TerminalSessionMetadata{
    SessionID: "test-17",
    Command: "make test",
  })

  return (
    <TerminalSessionPanel
      state={props.State}
      sessionID={props.SessionID}
      command={props.Command}
      output={props.Output}
      onSubmit={sendInput}
      onExit={stopSession}>
    </TerminalSessionPanel>
  )
}
```

```go
type TerminalEvent struct {
	Type string
	Time time.Time
	Payload TerminalEventPayload
}

type TerminalEventPayload struct {
	Text string
	Command string
	CWD string
	ProcessID string
	RequestID string
	Title string
	Summary string
	Code int
}

type TerminalSessionMetadata struct {
	SessionID string
	Command string
	CWD string
	ProcessID string
	StartedAt time.Time
}

var terminalEvents = []TerminalEvent{
	{
		Type: "stream.stdout",
		Payload: TerminalEventPayload{Text: "ok\n"},
	},
}
```

Stream events require `Payload.Text`. `session.started` may set `Command`,
`CWD`, and `ProcessID`. `approval.requested` requires `RequestID` and `Title`
and may set `Summary`. `session.exited` may set `Code` and `Summary`.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

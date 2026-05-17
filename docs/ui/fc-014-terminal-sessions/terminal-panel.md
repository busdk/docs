---
title: Library terminal panel
description: BusDK UI library terminal session panel contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

This feature-candidate contract depends on GX [callback props](../v0.1.6/callback-props)
and becomes usable when `bus-ui` implements `TerminalSessionPanel`.

[`TerminalSessionPanel`](./terminal-session-panel) renders the
complete terminal surface for one session. It accepts `idle`, `running`,
`waiting`, `exited`, and `error` states. `running` and `waiting` show stdin
controls only when the `onSubmit` callback prop exists. `exited` and `error`
disable process controls.

| Prop | Required | Behavior |
| --- | --- | --- |
| `state` | yes | `idle`, `running`, `waiting`, `exited`, or `error`. |
| `sessionID` | no | Stable host session identifier copied into callback payloads when present. |
| `command` | yes | Already-redacted command display string; callers remove secrets before passing this prop. |
| `output` | yes | Ordered, already-redacted `TerminalChunk` values rendered as escaped terminal text. |
| `workingDirectory` | no | Public-safe string shown as session metadata; hidden when omitted. |
| `processID` | no | Public-safe string shown as session metadata; hidden when omitted. |
| `elapsed` | no | Public-safe string shown as session metadata; hidden when omitted. |
| `exitCode` | no | Integer shown as session metadata; hidden when omitted. |
| `onSubmit` | no | `func(TerminalSubmitEvent) gx.Result` callback prop for stdin submit; omitted disables stdin controls. |
| `onExit` | no | `func(TerminalExitEvent) gx.Result` callback prop for requesting external process termination; omitted hides the exit control. |
| `error` | no | Public-safe error title rendered only in `error` state. |

State behavior is deterministic: `idle` renders no process controls, `running`
enables stdin when `onSubmit` exists, `waiting` shows the fixed `Waiting`
status label and enables stdin only when `onSubmit` exists, and `exited` or
`error` disables process controls. The exit control appears only in `running` and
`waiting` states when `onExit` exists, so a waiting session can still request
external termination.

`TerminalChunk` has required `Stream` and `Text` fields plus optional
non-negative integer `Sequence`. `Stream` is `stdout`, `stderr`, `stdin`, or
`system`. Chunks render in supplied order unless every chunk has `Sequence`, in
which case ascending `Sequence` order is used with supplied order as the stable
tie-breaker.

```go
type TerminalChunk struct {
	Stream   string
	Text     string
	Sequence *int
}
```

Callback payloads are typed Go values. `onSubmit` receives a
`TerminalSubmitEvent` with the resolved session identifier, component source,
and submitted text. `onExit` receives a `TerminalExitEvent` with the resolved
session identifier and component source. When `sessionID` is omitted, the host
runtime resolves the active session from route or host context before calling
the callback. If no active session can be resolved, the host does not call the
callback. `SourceID` is the component id when present, otherwise the generated
tree path for this component instance.

```go
type TerminalSubmitEvent struct {
	SessionID string
	SourceID  string
	Text      string
}

type TerminalExitEvent struct {
	SessionID string
	SourceID  string
}
```

## Consequence

The terminal panel renders session status, layout, controls, and deterministic
output ordering. Process ownership, command execution, transport protocols,
retry policy, and termination authorization stay outside the component.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalSessionPanel](./terminal-session-panel)
- [State UI concept](../v0.3.8/state)

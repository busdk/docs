---
title: TerminalSessionPanel UI component
description: Dedicated BusDK UI reference for TerminalSessionPanel.
---

## Purpose

`TerminalSessionPanel` is a terminal component. Complete terminal surface. Use for command sessions with output and input.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `state` | yes | idle, running, waiting, exited, error | Session state. `idle` shows no active process, `running` shows output plus stdin controls when `submit` exists, `waiting` shows output plus approval/input waiting state, `exited` shows final output plus the latest `system` output chunk as the exit summary, and `error` shows terminal error state. |
| `sessionID` | no | string | Stable host session identifier. When omitted, handlers must identify the active session from route or host context. |
| `command` | yes | string | Displayed command. |
| `output` | yes | terminal chunk array | stdout/stderr/stdin/system chunks using the same `{stream,text,sequence}` schema as TerminalOutputView. Chunks render in supplied order unless `sequence` is present, in which case sequence order is used. |
| `submit` | no | event name | Sends stdin when state is `running` or `waiting`. The input control appears only in those two states and only when this event is present. The emitted event has no data payload beyond interaction identity: event name, trigger `submit`, source id, and optional submitter id. The controller reads stdin text and session identity from terminal state. |
| `exit` | no | event name | Requests external process termination through the host runtime. It does not close the panel by itself. The emitted event has no data payload beyond event name, trigger `exit`, and source id; the controller reads session identity and applies host confirmation/authorization before terminating. |

## Boundary

The component only renders terminal state and emits events. The host runtime
must authorize command start, stdin submission, and exit requests before event
handlers run.

## Example

```yaml
kind: TerminalSessionPanel
props:
  state: running
  sessionID: test-17
  command: make test
  submit: terminal-stdin
  output:
    bind: terminal.output
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

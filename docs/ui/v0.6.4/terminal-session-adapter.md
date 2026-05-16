---
title: TerminalSessionAdapter UI component
description: Dedicated BusDK UI reference for TerminalSessionAdapter.
---

## Purpose

`TerminalSessionAdapter` is a terminal component. Event-to-terminal adapter. Use before rendering terminal event streams.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `events` | yes | provider event array | Raw or normalized terminal events ordered by source time. Each event has `type`, optional `time`, and `payload` object. Supported types are `session.started`, `stream.stdout`, `stream.stderr`, `stream.stdin`, `approval.requested`, `session.exited`, and `session.error`. Stream payloads require `text`; started payloads may include `command`, `cwd`, and `processID`; `approval.requested` payloads require `requestID` and `title` and may include `summary` and decision labels; exit payloads may include `code` and `summary`. |
| `approvals` | no | map or array of approval items | Pending approvals keyed by or containing `requestID`. Each item has `requestID`, `title`, optional `summary`, and decisions `approve`, `deny`, or host-declared equivalents. Approvals match events by the same stable `requestID`; approvals with no matching event are still rendered as pending host requests. |
| `metadata` | no | object | Optional session metadata: `sessionID`, `command`, `cwd`, `processID`, and `startedAt` as RFC 3339 time. Omitted fields render as unknown/blank display values and do not fail validation. |

## Boundary

Renderer receives normalized terminal props, not raw event parsing rules. The
adapter outputs `{state, command, cwd, output, approvals, exit}` where `output`
uses the same chunk schema as [TerminalOutputView](../v0.6.2/terminal-output-view),
`approvals` use [TerminalApprovalPrompt](../v0.6.3/terminal-approval-prompt) events,
and `exit` is `{code, summary}` when known.

Output `state` is `idle` before a start event, `running` after
`session.started`, `waiting` while approvals are pending, `exited` after
`session.exited`, and `error` after `session.error`. Stream events append output
chunks; approval events append or update pending approvals; exit/error events
set `exit` and stop accepting stdin in downstream panels.

## Example

```yaml
kind: TerminalSessionAdapter
props:
  events:
    bind: terminal.events
  approvals:
    bind: terminal.approvals
```

```yaml
events:
  - type: stream.stdout
    payload:
      text: "ok\n"
```

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

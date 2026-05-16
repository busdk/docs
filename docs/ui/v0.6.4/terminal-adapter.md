---
title: Library terminal adapter
description: BusDK UI library terminal event adapter contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TerminalSessionAdapter`](./terminal-session-adapter) accepts raw
assistant terminal events and emits a stable view model for
[`TerminalSessionPanel`](../v0.6.1/terminal-session-panel). It sorts events
by sequence, normalizes streams to stdout/stderr/stdin/system, merges pending
approvals by `requestID`, and projects unknown event types to diagnostics.

Adapter input may include `terminal.opened`, `terminal.output`,
`terminal.input`, `terminal.approval.requested`,
`terminal.approval.resolved`, `terminal.exited`, and `terminal.error`.

| Input Type | Required Fields | Optional Fields |
| --- | --- | --- |
| `terminal.opened` | `sessionID`, public `command` | `workingDirectory` |
| `terminal.output` | `sessionID`, `text` | `stream`, numeric `sequence` |
| `terminal.input` | `sessionID`, `text` | numeric `sequence` |
| `terminal.approval.requested` | `sessionID`, `requestID`, public `title`, public `summary` | none |
| `terminal.approval.resolved` | `sessionID`, `requestID`, `decision` as `allow` or `deny` | none |
| `terminal.exited` | `sessionID` | integer `code`, public `summary` |
| `terminal.error` | `sessionID`, public `title` or public `summary` | none |

Invalid decisions become diagnostics. Duplicate resolutions keep the first
decision and report diagnostics.

The adapter output view model contains:

| Field | Required | Behavior |
| --- | --- | --- |
| `sessionID` | yes | Session id from the terminal event group. An event before `terminal.opened` may establish a diagnostic placeholder, but valid running output requires `terminal.opened`. |
| `state` | yes | `idle`, `running`, `waiting`, `exited`, or `error`; `terminal.error` wins, then unresolved approval gives `waiting`, then `terminal.exited` gives `exited`, then opened/running events give `running`, otherwise `idle`. |
| `command` | no | Public command display string. |
| `chunks` | no | Output chunks sorted by numeric `sequence`; unsequenced chunks sort after sequenced chunks by arrival order. |
| `approval` | no | One pending approval by `requestID`; omitted when none is pending. |
| `exitCode` | no | Integer exit code from `terminal.exited`. |
| `error` | no | Public error object from `terminal.error`. |
| `diagnostics` | no | Public-safe diagnostics for unknown or invalid events. |

## Consequence

The adapter isolates terminal event normalization from terminal presentation.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalSessionAdapter](./terminal-session-adapter)
- [Terminal panel](../v0.6.1/terminal-panel)

---
title: Library terminal panel
description: BusDK UI library terminal session panel contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`TerminalSessionPanel`](./terminal-session-panel) renders the
complete terminal surface for one session. It accepts `idle`, `running`,
`waiting`, `exited`, and `error` states. `running` enables stdin when `onSubmit`
exists. `waiting` disables stdin when approval is pending. `exited` and
`error` disable all process controls.

| Prop | Required | Behavior |
| --- | --- | --- |
| `state` | yes | `idle`, `running`, `waiting`, `exited`, or `error`. |
| `command` | yes | Public-safe command display string. |
| `onSubmit` | no | Runtime event name for stdin submit; omitted disables stdin. |
| `stop` | no | Runtime event name for stopping active work; omitted hides stop. |
| `error` | no | Public-safe error title or object rendered only in `error` state. |

State behavior is deterministic: `idle` renders no process controls, `running`
enables stdin when `onSubmit` exists, `waiting` disables stdin while approval is
pending, and `exited` or `error` disables process controls.

Optional metadata fields are public-safe strings except `exitCode`, which is an
integer. `workingDirectory`, `sessionID`, `processID`, `elapsed`, and
`exitCode` are hidden when omitted.

## Consequence

The terminal panel renders session state. Process ownership and command
execution stay outside the component.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalSessionPanel](./terminal-session-panel)
- [State UI concept](../v0.3.8/state)

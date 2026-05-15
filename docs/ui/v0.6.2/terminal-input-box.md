---
title: TerminalInputBox UI component
description: Dedicated BusDK UI reference for TerminalInputBox.
---

## Purpose

`TerminalInputBox` is a terminal component. Terminal stdin controls. Use when a running session accepts input.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `value` | yes | string/binding | Current input. |
| `send` | yes | event name | Runs when the user submits input. Source identity selects this terminal input; the controller reads current input and session state. Empty values are ignored unless the controller allows empty input. |
| `exit` | no | event name | Runs when the user requests process termination. Source identity selects the terminal session; without session metadata the control is suppressed because the host cannot safely target a process. Omitted `exit` removes the stop/exit control; it does not close the panel locally. |
| `disabled` | no | boolean | Disables controls. |

## Boundary

Closed sessions disable input. `TerminalInputBox` emits interaction events only;
the host runtime decides whether stdin is accepted, which session is targeted,
and whether process termination is authorized.

## Example

```yaml
kind: TerminalInputBox
props:
  value:
    bind: terminal.input
  send: send-input
  exit: stop
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

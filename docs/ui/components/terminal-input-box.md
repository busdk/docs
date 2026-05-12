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
| `sendAction` | yes | action token | Runs when the user submits the input. `sessionID` comes from the surrounding `TerminalSessionPanel` or host terminal context. Payload is `{value, sessionID}` when available, otherwise `{value}`. Empty values are ignored unless the action declaration sets `allowEmptyInput: true`. |
| `exitAction` | no | action token | Runs when the user requests process termination. `sessionID` comes from the surrounding `TerminalSessionPanel` or host terminal context. Payload is `{sessionID}` when available; without session metadata the control is suppressed because the host cannot safely target a process. Omitted `exitAction` removes the stop/exit control; it does not close the panel locally. |
| `disabled` | no | boolean | Disables controls. |

## Boundary

Closed sessions disable input. `TerminalInputBox` emits actions only; the host
runtime decides whether stdin is accepted or process termination is authorized.

## Example

```yaml
kind: TerminalInputBox
props:
  value: { bind: terminal.input }
  sendAction: send-input
  exitAction: stop
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./terminal-output-view">TerminalOutputView</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./terminal-approval-prompt">TerminalApprovalPrompt</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

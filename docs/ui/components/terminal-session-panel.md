---
title: TerminalSessionPanel UI component
description: Dedicated BusDK UI reference for TerminalSessionPanel.
---

## Purpose

`TerminalSessionPanel` is a terminal component. Complete terminal surface. Use for command sessions with output and input.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `state` | yes | idle, running, waiting, exited, error | Session state. `idle` shows no active process, `running` shows output plus stdin controls when `submitAction` exists, `waiting` shows output plus approval/input waiting state, `exited` shows final output and exit summary, and `error` shows terminal error state. |
| `command` | yes | string | Displayed command. |
| `output` | yes | terminal chunk array | stdout/stderr/stdin/system chunks using the same `{stream,text,sequence}` schema as [TerminalOutputView](./terminal-output-view). Chunks render in supplied order unless `sequence` is present, in which case sequence order is used. |
| `submitAction` | no | action token | Sends stdin when state is `running` or `waiting`. The input control appears only when this token is present and the session is not `exited` or `error`; payload is `{value, sessionID}` when known. |
| `exitAction` | no | action token | Requests external process termination through the host runtime. It does not close the panel by itself; payload is `{sessionID}` when known. |

## Boundary

Execution authorization remains external.

## Example

```yaml
kind: TerminalSessionPanel
props:
  state: running
  command: make test
  output: { bind: terminal.output }
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-drop-controller">AIDropController</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./terminal-output-view">TerminalOutputView</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

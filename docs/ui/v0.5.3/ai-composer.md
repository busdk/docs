---
title: AIComposer UI component
description: Dedicated BusDK UI reference for AIComposer.
---

## Purpose

`AIComposer` is an assistant component. Assistant draft input. Use for prompt entry and turn controls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `value` | no | string or `{ bind: path }` | Draft text; omitted values render as an empty draft. Non-string resolved values fail validation. |
| `send` | yes | event name | Must reference document `events`; identifies the composer source. The controller reads the current draft text. |
| `interrupt` | no | event name | Identifies the composer source for stopping the active turn; omitted hides the stop control. |
| `disabled` | no | boolean | Default `false`; disables input and send. |

## Boundary

Send and interrupt events are names in the runtime `events` map. The component
does not call a model directly or send draft text in the event; the registered
controller reads current composer state and owns provider selection,
persistence, and error handling.

## Example

This component-only example assumes `send` and `interrupt` are already declared
in the runtime `events` map or registered by Go code.

```yaml
kind: AIComposer
props:
  value:
    bind: draft.text
  send: send
  interrupt: interrupt
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

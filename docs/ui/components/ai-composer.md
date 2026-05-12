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
| `sendAction` | yes | action token | Must reference document `actions`; emits `{text}` with the current draft. |
| `interruptAction` | no | action token | Emits `{reason:"user"}` to stop the active turn; omitted hides the stop control. |
| `disabled` | no | boolean | Default `false`; disables input and send. |

## Boundary

Send and interrupt actions are names in the document top-level `actions` map.
The component does not call a model directly; the registered action handler
owns provider selection, persistence, and error handling.

## Example

This component-only example assumes `send` and `interrupt` are already declared
in the document `actions` map or registered by Go code.

```yaml
kind: AIComposer
props:
  value: { bind: draft.text }
  sendAction: send
  interruptAction: interrupt
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-attachment-list">AIAttachmentList</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-approvals">AIApprovals</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

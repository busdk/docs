---
title: AIPanel UI component
description: Dedicated BusDK UI reference for AIPanel.
---

## Purpose

`AIPanel` is an assistant component. Assistant workbench surface. Use for AI conversations, approvals, model choice, and active work state.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `threads` | yes | array of `{id,title,working}` | `id` and `title` required; `working` defaults false. |
| `activeThread` | yes | thread id | Must match a `threads[].id`; otherwise render no active transcript and a visible error. |
| `messages` | yes | array of `{role,text,html,trusted}` | `role` is `user`, `assistant`, or `system`; exactly one of `text` or sanitized `html` is required. Callers must sanitize `html` with `AIMarkdown` or an equivalent audited sanitizer and set `trusted: ai-markdown` before passing it; other HTML is rejected. Both `text` and `html` together fail validation. |
| `approvals` | no | [`AIApprovals`](./ai-approvals) item array | Default empty; items use `{requestID,title,summary}`. |
| `approveAction` | required when `approvals` is non-empty | action token | Passed to `AIApprovals`; emits `{requestID, decision:"approve"}`. |
| `rejectAction` | required when `approvals` is non-empty | action token | Passed to `AIApprovals`; emits `{requestID, decision:"reject"}`. |
| `model` | no | string | Current model id for display/model select. |
| `attachments` | no | [`AIAttachmentList`](./ai-attachment-list) item array | Default empty; items use `{label,size}`. |
| `terminal` | no | [`TerminalSessionPanel`](./terminal-session-panel) props object | Optional terminal companion state. |
| `sendAction` | no | action token | Enables composer send and emits `{text}`. |
| `interruptAction` | no | action token | Enables stop control and emits `{reason:"user"}`. |
| `setModelAction` | no | action token | Enables model select and emits `{model}`. |
| `attachmentAction` | no | action token | Enables attachment changes and emits a discriminated payload: `{operation:"add", attachment:{label,size}}` or `{operation:"remove", index}` where `index` is zero-based. |

## Boundary

A rendered panel may initiate send, interrupt, model-change, attachment, and
approval actions only when explicit action tokens are supplied. File writes,
command execution, and apply-like decisions remain read-only displays until
`AIApprovals` or a product handler authorizes them.

## Example

```yaml
kind: AIPanel
props:
  activeThread: { bind: ai.activeThread }
  threads: { bind: ai.threads }
  messages: { bind: ai.messages }
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation. When `sendAction`, `interruptAction`, `setModelAction`, or `attachmentAction` is omitted, the matching composer send, interrupt, model select, or attachment control is hidden. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./disposer">Disposer</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-thread-list">AIThreadList</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

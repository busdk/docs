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
| `approvals` | no | `AIApprovals` item array | Default empty; items use `{requestID,title,summary}`. |
| `approve` | required when `approvals` is non-empty | event name | Passed to `AIApprovals`; source identity selects the approval item and decision. |
| `reject` | required when `approvals` is non-empty | event name | Passed to `AIApprovals`; source identity selects the approval item and decision. |
| `model` | no | string | Current model id for display/model select. |
| `attachments` | no | `AIAttachmentList` item array | Default empty; items use `{label,size}`. |
| `terminal` | no | `TerminalSessionPanel` props object | Optional terminal companion state. |
| `send` | no | event name | Enables composer send; the controller reads draft text from panel state. |
| `interrupt` | no | event name | Enables stop control; the controller resolves the active turn from panel state. |
| `setModel` | no | event name | Enables model select; the controller reads selected model state. |
| `attachment` | no | event name | Enables attachment changes; source identity selects the attachment control and operation. |

## Boundary

A rendered panel may initiate send, interrupt, model-change, attachment, and
approval events only when explicit event names are supplied. File writes,
command execution, and apply-like decisions remain read-only displays until
`AIApprovals` or a product handler authorizes them.

## Example

```yaml
kind: AIPanel
props:
  activeThread:
    bind: ai.activeThread
  threads:
    bind: ai.threads
  messages:
    bind: ai.messages
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props,
validation, and confirmation policy. When `send`, `interrupt`,
`setModel`, or `attachment` is omitted, the matching composer send,
interrupt, model select, or attachment control is hidden.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

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
| `onApprove` | required when `approvals` is non-empty | `func(AIApprovalEvent) gx.Result` | Receives the approval `RequestID` and `Decision` value `"approve"`. |
| `onReject` | required when `approvals` is non-empty | `func(AIApprovalEvent) gx.Result` | Receives the approval `RequestID` and `Decision` value `"reject"`. |
| `model` | no | string | Current model id for display/model select. |
| `modelOptions` | required with `onModelChange` | array of `{id,label}` | Selectable model choices. `model` must match one option id. |
| `attachments` | no | `AIAttachmentList` item array | Default empty; items use `{label,size}`. |
| `terminal` | no | `TerminalSessionPanel` props object | Optional terminal companion state. |
| `onSend` | no | `func(AISendEvent) gx.Result` | Enables composer send. Event carries `ThreadID`; the controller reads draft text from panel state key `draft`. |
| `onInterrupt` | no | `func(AIInterruptEvent) gx.Result` | Enables stop control. Event carries `ThreadID`; the controller resolves the active turn from panel state key `turnID`. |
| `onModelChange` | no | `func(AIModelEvent) gx.Result` | Enables model select. Event carries `ThreadID` and selected `ModelID`. |
| `onAttachment` | no | `func(AIAttachmentEvent) gx.Result` | Enables attachment changes. Event carries `ThreadID`, `AttachmentID`, and `Operation`. |

## Boundary

A rendered panel may call send, interrupt, model-change, attachment, and approval
callbacks only when explicit callback props are supplied. File writes, command
execution, and apply-like decisions remain read-only displays until
`AIApprovals` or a product callback authorizes them.

## Example

```gx
var panel = <AIPanel
  activeThread={ai.ActiveThread}
  threads={ai.Threads}
  messages={ai.Messages}
  model={ai.Model}
  modelOptions={ai.ModelOptions}
  onSend={sendMessage}
  onModelChange={selectModel}>
</AIPanel>
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props,
validation, and confirmation policy. When `onSend`, `onInterrupt`,
`onModelChange`, or `onAttachment` is omitted, the matching composer send,
interrupt, model select, or attachment control is hidden.

All event structs include `ThreadID string`. Approval events add `RequestID` and
`Decision`; model events add `ModelID`; attachment events add `AttachmentID` and
`Operation`.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: AIAttachmentList UI component
description: Dedicated BusDK UI reference for AIAttachmentList.
---

## Purpose

`AIAttachmentList` is an assistant component. Assistant attachment chips. Use for draft files, paths, or uploads.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `attachments` | yes | `[]AIAttachment` | `ID` and `Label` are required; `Size` is an optional already-formatted string rendered as the chip subtitle. `ID` is stable within the current draft and is passed to removal callbacks. |
| `onRemove` | no | `func(AIAttachmentEvent) gx.Result` | Runs when an attachment remove control is activated. `AttachmentID` identifies the chip. Omit to render read-only chips. |
| `size` | no | small, medium | List density override; default `medium`. Item file sizes stay in `attachments[].Size`. |

## Boundary

Remove callbacks identify the activated chip by `AttachmentID`. The handler
resolves the attachment from current draft state so stale labels are not trusted.

## Example

```gx
var attachments = <AIAttachmentList
  attachments={draft.Attachments}
  onRemove={removeAttachment}>
</AIAttachmentList>
```

```go
type AIAttachment struct {
	ID    string
	Label string
	Size  string
}

type AIAttachmentEvent struct {
	AttachmentID string
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

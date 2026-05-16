---
title: AIDropController UI component
description: Dedicated BusDK UI reference for AIDropController.
---

## Purpose

`AIDropController` is an assistant component. Assistant drop intake controller. Use for browser file/path drops into an assistant draft.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | yes | string | Stable source id for drop state. |
| `onDrop` | yes | `func(AIDropEvent) gx.Result` | Handles an accepted drop. `SourceID` identifies this drop controller, and `Items` contains accepted items. Each item has `Name`, `Type`, `Size`, and exactly one of `FileHandle` or `UploadToken`. |
| `activeThread` | yes | string | Controller-owned thread id. Empty string disables dropping and shows no drop target because there is no attachment target. |
| `acceptedTypes` | no | array of MIME types or extensions | Default accepts any type allowed by product validation; examples include `text/plain` and `.md`. |
| `maxBytes` | no | int64 | Per-item size limit. Omitted means the product allows no browser drop until a parent supplies a policy. |
| `maxItems` | no | int | Per-drop count limit. Omitted means the product allows no browser drop until a parent supplies a policy. |
| `onError` | no | `func(AIDropErrorEvent) gx.Result` | Handles rejected drops. Stable reason codes are `type-rejected`, `too-large`, `too-many`, `read-failed`, and `policy-rejected`. Omitted renders the default visible error. |

## Boundary

Rejected drops must be visible to the user. Client logging is additional
diagnostics and does not replace the visible error.

## Example

```gx
var dropController = <AIDropController
  id="assistant-drop"
  activeThread={ai.ActiveThread}
  onDrop={attachDrop}
  maxBytes={1048576}
  maxItems={4}
  acceptedTypes={[]string{"text/plain"}}>
</AIDropController>
```

```go
type AIDropEvent struct {
	SourceID string
	ThreadID string
	Items []AIDropItem
}

type AIDropErrorEvent struct {
	SourceID string
	Reason string
	ItemName string
	ItemType string
	ItemSize int64
	Limit int64
	Count int
}

func attachDrop(event AIDropEvent) gx.Result {
	return ai.Attach(event.ThreadID, event.Items)
}
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

---
title: DropZone UI component
description: Dedicated BusDK UI reference for DropZone.
---

## Purpose

`DropZone` is an evidence/media component. File/path intake surface. Use for upload, import, or attachment intake.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | no | string | Source identifier passed to callbacks. When omitted, the component creates a stable local id for this mounted drop zone. |
| `title` | yes | string | Visible label. |
| `onDrop` | yes | `func(DropEvent)` | Go callback invoked after local type filtering accepts at least one item. `DropEvent.SourceID` is the `id` prop or generated local id. `DropEvent.Items` contains accepted `DropItem` values. |
| `input` | no | slot | Augments the default file input. The slot receives `DropZoneContext`; custom content calls `dropzone.Accept(items)` and must not call upload APIs directly. |
| `acceptedTypes` | no | `[]string` | Examples: `image/png`, `application/pdf`, `.csv`. Omitted means the UI accepts any type, but product validation still enforces limits. MIME entries match exact MIME type strings; extension entries start with `.` and match case-insensitive item name suffixes. |

## Boundary

Validation and limits stay product-owned. The UI filters obvious rejected
types, but the event handler must still enforce file count, size, content,
authorization, and storage rules.

Drop callbacks and slots use these Go shapes:

```go
type DropEvent struct {
	SourceID string
	Items    []DropItem
}

type DropItem struct {
	Name        string
	Type        string
	Size        int64
	File        gxwasm.File
	Path        string
	UploadToken string
}

type DropAcceptResult struct {
	Accepted []DropItem
	Rejected []DropReject
}

type DropReject struct {
	Item   DropItem
	Reason string
}
```

`DropEvent.SourceID` is always non-empty. Component code sets exactly one of
`DropItem.File`, `DropItem.Path`, or `DropItem.UploadToken` before calling
`Accept`; the component rejects items that have none or more than one source
field. The `input` slot receives a context object named `dropzone`:

```go
type DropZoneContext struct {
	SourceID   string
	Accept     func([]DropItem) DropAcceptResult
	OpenPicker func()
}
```

`Accept` returns accepted and rejected items. The component invokes `onDrop`
only when the accepted list is non-empty; rejected items stay in local component
state for accessible error text.

## Example

This component-only example assumes `upload` is already in Go lexical scope.

```gx
package intakeui

var evidenceDrop = (
  <DropZone
    title="Drop files here"
    onDrop={upload}
  ></DropZone>
)
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

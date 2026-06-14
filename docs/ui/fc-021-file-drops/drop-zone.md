---
title: DropZone UI component
description: Dedicated BusDK UI reference for DropZone.
---

## Purpose

`DropZone` is a shared intake surface for files, local paths, or trusted staged
upload tokens. Use the public `ui.DropZone` node-first helper where a product
module needs upload, import, evidence, or attachment intake without giving the
component ownership of storage policy.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `ID` | no | string | Source identifier rendered into the drop zone and copied into `DropSource.ID`. When omitted, the component derives a deterministic local id from visible text. |
| `SourcePath` | no | string | Render-tree path copied into `DropSource.Path`; this is not a local filesystem path. |
| `Title` | no | string | Visible label. The default file input uses it as its accessible label when present. |
| `Copy` | no | string | Short visible help text. |
| `InputHTML` | no | string | Trusted, pre-rendered component markup for a custom file input or adapter. Omitted renders the built-in multiple file input. |
| `ActionsHTML` | no | string | Trusted, pre-rendered action controls rendered below the input. |
| `ErrorHTML` | no | string | Trusted, pre-rendered accessible status text for rejected items or adapter failures. |
| `AcceptedTypes` | no | `[]string` | Examples: `image/png`, `application/pdf`, `.csv`. MIME entries match exact strings; extension entries match case-insensitive item name suffixes; wildcard tokens are ignored. |
| `MaxBytes` | no | `int64` | Positive UI byte limit rendered for adapters and reused by `DropPolicy`. Product validation still enforces authoritative limits. |
| `AllowLocalPath` | no | bool | Defaults false. When true, path adapters may pass local paths through policy to trusted controllers. |
| `Attrs` | no | `map[string]string` | Additional root attributes merged with the standard drop-zone classes and data attributes. |

## Boundary

Validation and limits stay product-owned. The current `DropZone` API renders
markup and source metadata; browser adapters or controller code call
`AcceptDropItems` with the same source and policy values. The shared policy
filters exact accepted types, optional byte limits, and the
single-source-handle rule, but the event handler must still enforce file count,
content, authorization, upload, and storage rules.

`InputHTML`, `ActionsHTML`, and `ErrorHTML` are raw HTML insertion points for
trusted Bus UI output and remain a compatibility boundary for host-owned
markup. Do not pass user-controlled strings into those fields; escape user text
before composing the trusted markup.

Drop adapters and controllers use these Go shapes:

```go
type DropEvent struct {
	Source   DropSource
	SourceID string
	Items    []DropItem
}

type DropSource struct {
	ID   string
	Path string
}

type DropItem struct {
	Name        string
	Type        string
	Size        int64
	Path        string
	UploadToken string
	File        any
}

type DropAcceptResult struct {
	Accepted []DropItem
	Rejected []DropReject
	Event    DropEvent
	Reject   DropRejectEvent
}

type DropReject struct {
	Name   string
	Type   string
	Size   int64
	Reason string
}

type DropRejectEvent struct {
	Source   DropSource
	SourceID string
	Rejected []DropReject
}

type DropPolicy struct {
	AcceptedTypes  []string
	MaxBytes       int64
	AllowLocalPath bool
	Log            func(level string, msg string)
}
```

`DropEvent.SourceID` is always non-empty. Adapter code sets exactly one of
`DropItem.File`, `DropItem.Path`, or `DropItem.UploadToken` before calling
`Accept`; policy rejects items that have none or more than one source field.
Custom input/action adapters can use the same context shape returned by
`NewDropZoneContext`:

```go
type DropZoneContext struct {
	SourceID   string
	Source     DropSource
	Policy     DropPolicy
	Accept     func([]DropItem) DropAcceptResult
	OpenPicker func()
}
```

`Accept` returns accepted and rejected items. Controllers handle
`DropAcceptResult.Event` only when the accepted list is non-empty. Rejected
items can be rendered through `ErrorHTML` or logged through `DropPolicy.Log`
without exposing source handles.

## Example

This Go example renders the shared drop zone. The controller-side callback uses
the same source and policy values through ordinary Go lexical scope.

```go
package intakeui

import "github.com/busdk/bus-ui/pkg/ui"

func renderReceiptDrop() (string, error) {
	node, err := ui.DropZone(ui.DropZoneProps{
		ID:            "receipt-drop",
		SourcePath:    "/DropZone[0]",
		Title:         "Drop receipts",
		Copy:          "PDF and CSV files up to 10 MB",
		AcceptedTypes: []string{"application/pdf", ".csv"},
		MaxBytes:      10 << 20,
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}

func acceptReceiptDrop(items []ui.DropItem) ui.DropAcceptResult {
	return ui.AcceptDropItems(
		ui.DropSource{ID: "receipt-drop", Path: "/DropZone[0]"},
		items,
		ui.DropPolicy{
			AcceptedTypes: []string{"application/pdf", ".csv"},
			MaxBytes:      10 << 20,
		},
	)
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Resource](../v0.4.1/resource) defines safe URL resolution. Upload endpoints,
storage targets, provider paths, and file authorization remain host and product
controller boundaries, not `DropZone` behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

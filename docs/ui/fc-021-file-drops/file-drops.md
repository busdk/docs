---
title: Library file drops
description: BusDK UI library file and path drop intake contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`DropZone`](./drop-zone) renders file, path, or staged-token intake state and
emits a stable source identity. Accepted item types and size limits come from
the controller through `DropPolicy`. Rejected drops emit diagnostics that omit
local paths and upload tokens.

Drop policy is controller/runtime configuration:

| Field | Required | Behavior |
| --- | --- | --- |
| `AcceptedTypes` | no | MIME strings such as `application/pdf` or extension strings with leading dot such as `.csv`; MIME wildcards are ignored. Omitted accepts any type before product validation. |
| `MaxBytes` | no | Positive byte limit. Omitted means no UI size limit before product validation. Oversized drops emit `size-exceeds-limit`. |
| `AllowLocalPath` | no | Defaults false. When false, path-only items are rejected and decoded path metadata is redacted. |
| `Log` | no | `func(level string, msg string)` receives redacted rejection, decode, and adapter diagnostics. |

Accepted drops emit source identity plus redacted item summaries:

```go
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

type DropEvent struct {
	Source   DropSource
	SourceID string
	Items    []DropItem
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

type DropAcceptResult struct {
	Accepted []DropItem
	Rejected []DropReject
	Event    DropEvent
	Reject   DropRejectEvent
}

type DropPolicy struct {
	AcceptedTypes  []string
	MaxBytes       int64
	AllowLocalPath bool
	Log            func(level string, msg string)
}

func handleDrop(items []DropItem) DropAcceptResult {
	return AcceptDropItems(
		DropSource{ID: "evidence-drop", Path: "/DropZone[0]"},
		items,
		DropPolicy{
			AcceptedTypes: []string{"application/pdf", ".csv"},
			MaxBytes:      10 << 20,
		},
	)
}

var accepted = handleDrop([]DropItem{
	{
		Name:        "receipt.pdf",
		Type:        "application/pdf",
		Size:        12345,
		UploadToken: "staged-upload-123",
	},
}).Event
```

`DropSource.ID` is the explicit component `ID` or the deterministic fallback
from the rendered drop-zone text. `DropSource.Path` is the component path inside
the rendered tree, not a local filesystem path. `DropEvent.SourceID` and
`DropRejectEvent.SourceID` mirror `DropSource.ID` for callers that only need the
short source key. Product drop zones that route callbacks, persist source
identity, or appear in localized UI must set an explicit `ID`; the text-derived
fallback is only a deterministic last resort for simple local surfaces.

Each accepted `DropItem` has exactly one source handle: `File`, `Path`, or
`UploadToken`. Browser adapters can put the JavaScript file wrapper in `File`,
path adapters can use `DropItemFromPath`, and trusted host intake adapters can
set `UploadToken` after staging a temporary object. `UploadToken` authorizes the
controller to claim that staged object and must be treated as sensitive.
Rendered UI, logs, and rejection diagnostics omit local paths and upload tokens.

Drop handling must not upload, mutate, or persist data by itself. The
controller and host decide what to read, validate, upload, store, or reject.

## Consequence

Drop UI stays reusable and safe while product modules own file policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [DropZone](./drop-zone)
- [Callback props](../v0.1.6/callback-props)

---
title: Library file drops
description: BusDK UI library file and path drop intake contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`DropZone`](./drop-zone) renders file or path intake state and
emits drop identity. Accepted item types and size limits come from the
controller. Rejected drops emit diagnostics and never expose local paths.

Drop policy is controller/runtime configuration:

| Field | Required | Behavior |
| --- | --- | --- |
| `acceptedTypes` | no | Array of MIME strings such as `application/pdf` or extension strings with leading dot such as `.csv`; MIME wildcards are not allowed. Omitted accepts any type before product validation. |
| `maxBytes` | no | Positive integer byte limit. Omitted means no UI size limit before product validation. Oversized drops emit diagnostics. |
| `allowLocalPath` | no | Boolean; defaults false. When false, emitted events omit local paths. |
| `onDrop` | yes | `func(DropEvent)` invoked with the accepted source identity and redacted item summaries. |
| `onReject` | no | `func(DropRejectEvent)` invoked when local type, size, or source validation rejects items. Omitted renders the same diagnostics in the component error state. |

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
	File        gxwasm.File
	Path        string
	UploadToken string
}

type DropEvent struct {
	Source DropSource
	Items  []DropItem
}

type DropReject struct {
	Name   string
	Type   string
	Size   int64
	Reason string
}

type DropRejectEvent struct {
	Source   DropSource
	Rejected []DropReject
}

var event = DropEvent{
	Source: DropSource{
		ID:   "evidence-drop",
		Path: "/DropZone[0]",
	},
	Items: []DropItem{
		{Name: "receipt.pdf", Type: "application/pdf", Size: 12345},
	},
}
```

`DropSource.ID` is the explicit component `id` or the generated mounted id.
`DropSource.Path` is the component path inside the rendered tree, not a local
filesystem path. `DropItem.Path` is empty unless `allowLocalPath` is true and
the runtime policy allows path disclosure. Rejection diagnostics include only
`Name`, `Type`, `Size`, and `Reason`; they must not expose local paths.

`gxwasm.File` is the browser runtime wrapper for a JavaScript `File` object. It
is populated only for browser file picker or drag/drop items and is empty for
server-side rendering, local path drops, and already-staged upload references.
`UploadToken` is set only by a trusted host intake adapter after it stages the
drop into temporary storage; it authorizes the controller to claim that staged
object and must be treated as sensitive. Rendered UI and diagnostics omit
`UploadToken` unless the product controller explicitly consumes it.

Drop handling must not upload, mutate, or persist data by itself. The
controller decides what to read, validate, upload, or reject.

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

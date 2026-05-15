---
title: DropZone UI component
description: Dedicated BusDK UI reference for DropZone.
---

## Purpose

`DropZone` is an evidence/media component. File/path intake surface. Use for upload, import, or attachment intake.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string | Visible label. |
| `drop` | yes | event name | Must match a runtime event or registered handler. The source id identifies this drop zone; the controller reads accepted items from component-owned drop state. Each item has string `name`, MIME `type`, byte-count `size`, and exactly one of `fileHandle`, local `path`, or `uploadToken`. |
| `input` | no | slot | Augments the default file input. Custom content must call `dropzone.accept({items})`, where `items` is the item array described above; the controller invokes `drop`. It must not call upload APIs directly. |
| `acceptedTypes` | no | MIME types or extensions array | Examples: `image/png`, `application/pdf`, `.csv`. Omitted means the UI accepts any type, but product validation still enforces limits. |

## Boundary

Validation and limits stay product-owned. The UI filters obvious rejected
types, but the event handler must still enforce file count, size, content,
authorization, and storage rules.

The `input` slot receives a context object named `dropzone` with
`accept({items})` and `openPicker()` functions. Custom slots should call those
functions instead of bypassing the controller.

## Example

This component-only example assumes `upload` is already declared in the
runtime `events` map or registered by Go code.

```yaml
kind: DropZone
props:
  title: Drop files here
  drop: upload
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

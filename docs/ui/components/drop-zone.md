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
| `action` | yes | action token | Must match a document action or registered handler; receives `{items}`. Each item has string `name`, MIME `type`, byte-count `size`, and exactly one of `fileHandle`, local `path`, or `uploadToken`. |
| `input` | no | slot | Augments the default file input. Custom content must call `dropzone.accept({items})`, where `items` is the item array described above; the controller invokes `action`. It must not call upload APIs directly. |
| `acceptedTypes` | no | MIME types or extensions array | Examples: `image/png`, `application/pdf`, `.csv`. Omitted means the UI accepts any type, but product validation still enforces limits. |

## Boundary

Validation and limits stay product-owned. The UI filters obvious rejected
types, but the action handler must still enforce file count, size, content,
authorization, and storage rules.

The `input` slot receives a context object named `dropzone` with
`accept({items})` and `openPicker()` functions. Custom slots should call those
functions instead of bypassing the controller.

## Example

This component-only example assumes `upload` is already declared in the
document `actions` map or registered by Go code.

```yaml
kind: DropZone
props:
  title: Drop files here
  action: upload
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./projection-detail">ProjectionDetail</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./image-gallery">ImageGallery</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

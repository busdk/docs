---
title: AIAttachmentList UI component
description: Dedicated BusDK UI reference for AIAttachmentList.
---

## Purpose

`AIAttachmentList` is an assistant component. Assistant attachment chips. Use for draft files, paths, or uploads.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `attachments` | yes | array of `{label,size}` | `label` is required display text; `size` is optional string or byte count rendered as the chip subtitle. |
| `remove` | no | event name | Runs when an attachment remove control is activated. Source identity identifies the attachment chip. Omit to render read-only chips. |
| `size` | no | small, medium | List density override; default `medium`. Item file sizes stay in `attachments[].size`. |

## Boundary

Remove events identify the activated chip source. The handler resolves the
attachment from current draft state so stale labels are not trusted.

## Example

This component-only example assumes `remove-attachment` is already declared in
the runtime `events` map or registered by Go code.

```yaml
kind: AIAttachmentList
props:
  attachments:
    bind: draft.attachments
  remove: remove-attachment
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

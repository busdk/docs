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
| `removeAction` | no | action token | Emits `{index}` where `index` is the zero-based attachment index. Omit to render read-only chips. |
| `size` | no | small, medium | List density override; default `medium`. Item file sizes stay in `attachments[].size`. |

## Boundary

Remove action payload carries only the zero-based `index`; the handler resolves
the attachment from the current draft state so stale labels are not trusted.

## Example

This component-only example assumes `remove-attachment` is already declared in
the document `actions` map or registered by Go code.

```yaml
kind: AIAttachmentList
props:
  attachments: { bind: draft.attachments }
  removeAction: remove-attachment
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-model-select">AIModelSelect</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-composer">AIComposer</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

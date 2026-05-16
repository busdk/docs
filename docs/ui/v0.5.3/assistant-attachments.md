---
title: Library assistant attachments
description: BusDK UI library assistant attachment list contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIAttachmentList`](./ai-attachment-list) renders approved
attachment chips from controller-supplied attachment state. Omitted event names
hide matching remove, open, or inspect controls.

| Prop | Required | Behavior |
| --- | --- | --- |
| `items` | no | Array of `{id,label}` objects. `id` is unique; `label` is public-safe text. Defaults empty. |
| `remove` | no | Runtime event name for removing an attachment; omitted hides remove. |
| `open` | no | Runtime event name for opening an attachment; omitted hides open. |
| `inspect` | no | Runtime event name for inspecting metadata; omitted hides inspect. |

Attachment events emit source identity plus item id:

```yaml
event: remove-attachment
source:
  id: attachments
  path: /AIPanel[0]/AIAttachmentList[0]
item:
  id: attachment-123
```

Attachment approval, file access, upload policy, and provider transfer stay
outside the component. The product controller must filter inaccessible,
unapproved, rejected, or expired attachments before rendering.

## Consequence

Attachment display is reusable because it renders approved state only.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIAttachmentList](./ai-attachment-list)
- File drops

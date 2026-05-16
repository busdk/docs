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
controller. Rejected drops emit diagnostics and do not expose local paths unless
policy allows them.

Drop policy is controller/runtime configuration:

| Field | Required | Behavior |
| --- | --- | --- |
| `acceptedTypes` | no | Array of MIME strings such as `application/pdf` or extension strings with leading dot such as `.csv`; MIME wildcards are not allowed. Omitted accepts any type before product validation. |
| `maxBytes` | no | Positive integer byte limit. Omitted means no UI size limit before product validation. Oversized drops emit diagnostics. |
| `allowLocalPath` | no | Boolean; defaults false. When false, emitted events omit local paths. |
| `drop` | yes | Lower-case runtime event name declared in `events` or registered by Go code. |

Accepted drops emit source identity plus redacted item summaries:

```yaml
event: attach-file
source:
  id: evidence-drop
  path: /DropZone[0]
items:
  - name: receipt.pdf
    type: application/pdf
    size: 12345
```

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

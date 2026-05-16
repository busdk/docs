---
title: AIDropController UI component
description: Dedicated BusDK UI reference for AIDropController.
---

## Purpose

`AIDropController` is an assistant component. Assistant drop intake controller. Use for browser file/path drops into an assistant draft.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `drop` | yes | event name | Handles an accepted drop. The source id identifies this drop controller; the controller reads accepted items from component-owned drop state. Each item has `name`, `type`, `size`, and exactly one of `fileHandle` or `uploadToken`. |
| `activeThread` | yes | thread id | Attachment target. |
| `acceptedTypes` | no | array of MIME types or extensions | Default accepts any type allowed by product validation; examples include `text/plain` and `.md`. |
| `onError` | no | event name or log channel | Event names use the runtime `events` map and identify this drop controller source. Stable reason codes are `type-rejected`, `too-large`, `too-many`, `read-failed`, and `policy-rejected`. Size/count checks come from product validation settings `drop.maxBytes` and `drop.maxItems`; the component has no standalone default limits. Log channels use `log:<channel>` and send diagnostics only; omitted renders the default visible error. |

## Boundary

Rejected drops must be visible to the user. Client logging is additional
diagnostics and does not replace the visible error.

## Example

This component-only example assumes `attach-drop` is already declared in the
runtime `events` map or registered by Go code.

```yaml
kind: AIDropController
props:
  activeThread:
    bind: ai.activeThread
  drop: attach-drop
  acceptedTypes:
    - text/plain
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: AIDropController UI component
description: Dedicated BusDK UI reference for AIDropController.
---

## Purpose

`AIDropController` is an assistant component. Assistant drop intake controller. Use for browser file/path drops into an assistant draft.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `dropAction` | yes | action token | Handles accepted drop and receives `{threadID, items}`. Each item has `name`, `type`, `size`, and exactly one of `fileHandle` or `uploadToken`. |
| `activeThread` | yes | thread id | Attachment target. |
| `acceptedTypes` | no | array of MIME types or extensions | Default accepts any type allowed by product validation; examples include `text/plain` and `.md`. |
| `onError` | no | action token or log channel | Action tokens use the document `actions` map and receive `{reason, item}`. Stable reason codes are `type-rejected`, `too-large`, `too-many`, `read-failed`, and `policy-rejected`. Log channels use `log:<channel>` and send diagnostics only; omitted renders the default visible error. |

## Boundary

Rejected drops must be visible to the user. Client logging is additional
diagnostics and does not replace the visible error.

## Example

This component-only example assumes `attach-drop` is already declared in the
document `actions` map or registered by Go code.

```yaml
kind: AIDropController
props:
  activeThread: { bind: ai.activeThread }
  dropAction: attach-drop
  acceptedTypes: [text/plain]
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-thread-isolation">AIThreadIsolation</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./terminal-session-panel">TerminalSessionPanel</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

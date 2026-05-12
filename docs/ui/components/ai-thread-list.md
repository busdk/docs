---
title: AIThreadList UI component
description: Dedicated BusDK UI reference for AIThreadList.
---

## Purpose

`AIThreadList` is an assistant component. Assistant thread list. Use when multiple assistant sessions are visible.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `threads` | yes | array of `{id,title,working}` | `id` and `title` are required strings; `working` defaults false and shows active-work state. |
| `selectAction` | yes | action token | Emits `{threadID}` where `threadID` equals the selected thread `id`. |
| `archiveAction` | no | action token | Emits `{threadID}` where `threadID` equals the archived thread `id`; omit to hide archive. |

## Boundary

Selecting or archiving emits the stable `threadID`; handlers must reject ids
that are not present in the current thread list.

## Example

```yaml
kind: AIThreadList
props:
  threads: { bind: ai.threads }
  selectAction: select-thread
  archiveAction: archive-thread
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-panel">AIPanel</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-message">AIMessage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

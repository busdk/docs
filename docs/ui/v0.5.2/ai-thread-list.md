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
| `select` | yes | event name | Runs when a thread row is selected. The source id identifies the selected thread. |
| `archive` | no | event name | Runs when an archive control is activated. The source id identifies the archived thread; omit to hide archive. |

## Boundary

Selecting or archiving identifies the activated item source. Controllers must
resolve that source against the current thread list and reject missing or stale
items.

## Example

```yaml
kind: AIThreadList
props:
  threads:
    bind: ai.threads
  select: select-thread
  archive: archive-thread
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

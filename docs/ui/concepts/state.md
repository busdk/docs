---
title: State UI concept
description: Dedicated BusDK UI framework concept page for State.
---

## Purpose

State is the visible representation of empty, loading, busy, result, warning, error, and blocked conditions.

Choose `EmptyState` when valid data is absent, `LoadingState` while data is
being fetched, `SubmitState` or another busy control while an action is in
flight, `ResultPanel` after an operation completes, `StatusPill` for compact
row/workflow state, `ErrorBanner` for recoverable page errors, and
`ProviderError` for sanitized upstream failures. Blocked or warning conditions
must include visible text and a next action when one exists.

## Boundary

Use state components so absence and failure are testable. Do not hide state only in local scripts or colors.

## Example

```yaml
body:
  kind: EmptyState
  props:
    title: No notes yet
    action: create-note
```

This renders an explicit empty state instead of a blank panel and gives the
user the next available action.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./collection">Collection</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./action">Action</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)

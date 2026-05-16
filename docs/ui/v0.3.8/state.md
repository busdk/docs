---
title: State UI concept
description: Dedicated BusDK UI framework concept page for State.
---

## Purpose

State is the visible representation of empty, loading, busy, result, warning, error, and blocked conditions.

Choose `EmptyState` when valid data is absent, `LoadingState` while data is
being fetched, `SubmitState` or another busy control while an event is in
flight, `ResultPanel` after an operation completes, `StatusPill` for compact
row/workflow state, `ErrorBanner` for recoverable page errors, and
`ProviderError` for sanitized upstream failures. Blocked or warning conditions
must include visible text and a [next event](../v0.1.6/callback-props) when one exists. A next
event is the stable Go controller event name for the action that can clear or
advance the state, such as `retry-load` or `request-access`.

## Boundary

Use state components so absence and failure are testable. Do not hide state only in local scripts or colors.

A blocked state with an available retry action should expose the event:

```gx
package notesui

var blockedNotes = (
  <section role="status">
    <Text value={blockedMessage}></Text>
    <button id="retry-notes" click="retry-load">Retry</button>
  </section>
)
```

## Template

```gx
package notesui

var emptyNotes = (
  <section aria-live="polite">
    <p><Text value={emptyMessage}></Text></p>
    <button id="create-note" click="create-note">Create note</button>
  </section>
)
```

## Fixture Data

```yaml
empty:
  message: No notes yet
```

This renders an explicit empty state from foundation elements instead of a
blank panel.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Collection concept](../v0.3.6/collection)
- [Callback props](../v0.1.6/callback-props)

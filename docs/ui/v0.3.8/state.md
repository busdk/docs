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
event is the Go callback for the action that can clear or advance the state,
such as `retryLoad` or `requestAccess`.

## Boundary

Use state components so absence and failure are testable. Do not hide state only in local scripts or colors.

A blocked state with an available retry action should expose the event:

```gx
package notesui

var blockedNotes = (
  <ErrorBanner message={blockedMessage} onClick={retryLoad}></ErrorBanner>
)
```

## Template

```gx
package notesui

var emptyNotes = (
  <EmptyState message={emptyMessage} onClick={createNote}></EmptyState>
)
```

## View Data

```go
package notesui

const emptyMessage = "No notes yet"
```

This renders an explicit empty state component instead of a blank panel.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Collection concept](../v0.3.6/collection)
- [Callback props](../v0.1.6/callback-props)

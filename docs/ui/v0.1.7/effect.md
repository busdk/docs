---
title: Effect UI concept
description: Dedicated BusDK UI framework concept page for Effect.
---

## Purpose

An effect owns work that happens outside a single render: browser listeners,
retained callbacks, timers, close guards, resize observers, diagnostics, and
cleanup. Use an effect when the UI must start, observe, or stop lifecycle
behavior.

## Boundary

The lifecycle owner is the mounted component scope registered with
`gx.MountRuntime`. It is identified by the component `id` when present or by
the runtime-provided deterministic tree path. Every effect follows the same
lifecycle: start after that owner mounts, surface failures through
`gx.ClientLog`, and run its disposer when the owner unmounts or the effect is
replaced. Reader-visible effect failures use the `ui.effect.failed` client-log
event with `ownerID`, `label`, and `error` fields. The framework enforces
cleanup.

## Example

```go
disposer := gx.OnceDispose(func() {
	stopResizeObserver()
	releaseCallback()
})
```

This disposer can be registered by mounted code and called repeatedly without
duplicating cleanup.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Lifecycle](./)
- [Event concept](../v0.1.6/event)

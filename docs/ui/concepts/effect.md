---
title: Effect UI concept
description: Dedicated BusDK UI framework concept page for Effect.
---

## Purpose

An effect owns work that happens outside a single render: polling, event
streams, browser listeners, close guards, drops, resize observers, diagnostics,
and cleanup. Use an effect when the UI must start, observe, or stop lifecycle
behavior. Use a resource for one request or data endpoint, and use a component
for visible structure.

## Boundary

Every effect follows the same lifecycle: start after the owner mounts, apply
successful events to declared state or callbacks, surface failures through the
error host/client log, and run its disposer when the owner unmounts or the
effect is replaced. Product modules configure resources, state application, and
error meaning; the framework enforces cleanup.

## Example

```yaml
resources:
  notes:
    method: GET
    path: /api/notes
effects:
  refresh-notes:
    type: polling
    resource: notes
    interval: 30s
    apply: notes
    onError: notes-error
    dispose: stop-refresh-notes
```

This starts a polling effect after mount, applies successful responses to
`notes`, reports failures to `notes-error`, and calls `stop-refresh-notes` when
the owner is disposed.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./resource">Resource</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../component-reference">Component reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)

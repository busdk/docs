---
title: Disposer UI runtime block
description: Dedicated BusDK UI reference for Disposer.
---

## Purpose

`Disposer` is a lifecycle cleanup callback for listeners, timers,
subscriptions, retained callbacks, and mounted resources. Cleanup runs when the
owning component, effect, or runtime scope is disposed.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `dispose` | yes | callback name or `{ callback: name }` | Resolved from callbacks registered on the component/effect owner scope by Go runtime setup, for example `runtime.RegisterDisposer("stopTimer", fn)`. Callback is zero-argument and releases or confirms release. Missing callback names fail validation before mount. If a registered callback fails during cleanup, the runtime records the failure through the error host/client log and still runs remaining disposers. |
| `chain` | no | callback names or disposer objects | Optional extra disposers run in listed order after `dispose`; each item is either a callback name or `{ callback: name }`. Failures are collected without skipping later disposers and surfaced through the runtime error host/client log; disposal still attempts every registered cleanup. |

## Boundary

The runtime guarantees each registered disposer is invoked at most once per
owner. Callback implementations should still be safe to call multiple times so
manual cleanup and runtime cleanup cannot corrupt state.

## Example

```yaml
effects:
  resize:
    type: listener
    dispose: stopResizeListener
```

```go
runtime.RegisterDisposer("stopResizeListener", stopResizeListener)
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./close-guard">CloseGuard</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-panel">AIPanel</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)

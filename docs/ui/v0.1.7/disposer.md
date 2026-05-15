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
| `dispose` | yes | callback name or callback object | Resolved from callbacks registered on the component/effect owner scope by Go runtime setup, for example `runtime.RegisterDisposer("stopTimer", fn)`. Callback is zero-argument and releases or confirms release. Missing callback names fail validation before mount. If a registered callback fails during cleanup, the runtime records the failure through the error host/client log and still runs remaining disposers. |
| `chain` | no | callback names or disposer objects | Optional extra disposers run in listed order after `dispose`; each item is either a callback name or an object with a `callback` field. Failures are collected without skipping later disposers and surfaced through the runtime error host/client log; disposal still attempts every registered cleanup. |

Object form accepts these fields:

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `callback` | yes | callback name | Registered zero-argument disposer callback. Unknown names fail validation before mount. |
| `label` | no | string | Public diagnostic label used when cleanup fails. Defaults to `callback`. |
| `optional` | no | boolean | Defaults false. When true, a missing callback records a warning instead of failing mount. |

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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [Source-tool integration](../v0.1.3/source-tool-integration)

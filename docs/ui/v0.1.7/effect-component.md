---
title: Effect UI runtime block
description: Dedicated BusDK UI reference for Effect.
---

## Purpose

`Effect` is an event/resource/effect runtime block. Background or browser lifecycle behavior. Use for polling, streams, drops, resize, close guards, logging, and cleanup.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes unless map key supplies it | string | Effect identifier. In a runtime `effects` map, the map key is the name. |
| `type` | yes | polling, event-stream, drop, resize, close-guard, log | `polling` repeats a resource read, `event-stream` consumes events, `drop` handles browser drops, `resize` observes layout, `close-guard` blocks unsafe close, and `log` sends diagnostics. |
| `resource` | no | resource name | Required for `polling` and `event-stream`, optional for `drop`, ignored by `resize`, `close-guard`, and `log`; names a runtime `resources` entry. |
| `interval` | for polling | duration string | Required for polling; Go-style positive durations using `ms`, `s`, or `m`, such as `500ms`, `30s`, or `2m`. Values like `0s` or `1hour` are invalid. |
| `target` | for drop | string | Required for `drop`; names a drop controller target registered by the Go WebAssembly host runtime, for example `runtime.RegisterDropTarget("attachment-drop", controller)`. Unknown target names fail validation before listeners are mounted. |
| `activeWork` | for close-guard | boolean or binding | Required for `close-guard`; true blocks unsafe close. |
| `unsavedWork` | for close-guard | boolean or binding | Required for `close-guard`; true blocks unsafe close. |
| `level` | for log | trace, debug, info, warn, error | Required for `log`; no default. |
| `message` | for log | redacted string | Required unless `messageBinding` is present. |
| `messageBinding` | for log | binding | Required unless `message` is present. |
| `dispose` | yes | disposer name or mapping | Names a runtime disposer or zero-argument Go WebAssembly callback registered in the effect owner scope, for example with `runtime.RegisterDisposer("stopPolling", fn)`. Use either a direct disposer name or an object with a `callback` field. |

## Boundary

Every effect has explicit cleanup.

Mode details:

| Type | Required fields | Runtime result |
| --- | --- | --- |
| `polling` | `resource`, `interval`, `dispose` | Reads the resource repeatedly until disposed. |
| `event-stream` | `resource`, `dispose` | Opens a host event stream and applies parsed events. |
| `drop` | `target`, `dispose` | Registers drop listeners for a target controller. |
| `resize` | `dispose` | Registers a resize observer and emits layout updates. |
| `close-guard` | `activeWork`, `unsavedWork`, `dispose` | Blocks unsafe close while configured guard state is active. |
| `log` | `level`, `message` or `messageBinding`, `dispose` | Sends configured diagnostics without blocking rendering. |

Disposer names resolve from the effect owner scope's runtime disposer registry.
Missing disposers fail validation. Callback disposers must be zero-argument and
must report errors instead of panicking. See the [Disposer](./disposer)
runtime block for cleanup registration and failure handling.

Mode-specific options use explicit props on the effect object: `drop` uses
required string `target` to name a host-registered drop controller,
`close-guard` uses required
boolean/binding props `activeWork` and `unsavedWork`, and `log` uses required
`level` plus exactly one of redacted `message` or `messageBinding`. Valid log
levels are `trace`, `debug`, `info`, `warn`, and `error`; there is no default.
Invalid log levels fail validation and omitted optional fields use no default.

## Example

```yaml
effects:
  note-refresh:
    type: polling
    resource: notes
    interval: 30s
    dispose: stop-note-refresh
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)

---
title: UI runtime contract
description: BusDK UI runtime contract for events, resources, effects, and cleanup.
---

## Design References

- [Binding](../v0.1.5/binding)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Runtime helpers are small and composable. The runtime accepts an `events` map,
`resources` map, and `effects` map from typed Go controller code or fixture
runtime config.

- `events.*` uses the map key as the event name and selects exactly one
  receiver: `handler`, `resource`, `navigate`, or `effect`. Event dispatch
  carries interaction identity only: event name, trigger, source id or tree
  path, and optional submitter id. The receiver/controller decides what model
  or form state to read.
- `resources.*` declares `base`, `path`, optional `method`, and optional
  payload or decode settings. `base` is `module`, `portal`, or a named host
  resolver. `path` begins with `/` and contains no `..`.
- `effects.*` declares `type`, type-specific fields, and `dispose` for
  long-running browser work. Polling and event streams name resources; drops,
  resize listeners, close guards, and client logging name host callbacks or
  targets.

Event receivers are mutually exclusive:

| Receiver | Required Fields | Behavior |
| --- | --- | --- |
| `handler` | handler name | Calls a Go or host-registered handler with the interaction record. Unknown handlers fail validation. |
| `resource` | resource name | Executes the named resource. The resource payload is resolved from controller-owned bindings when the receiver runs. |
| `navigate` | safe path or resolver object | Requests host navigation. Unsafe paths and external origins without allowlist fail validation. |
| `effect` | effect name | Starts or signals the named effect. Missing effects or incompatible effect types fail validation. |

Resource declarations use these constraints:

| Field | Rule |
| --- | --- |
| `kind` | Optional resource kind. Omit for HTTP resources; use `link` for safe navigation/download links. Link resources reject `method`, `payload`, and `decode`. |
| `method` | Defaults to `GET`; allowed values are `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, and `UPLOAD`. Links use `kind: link` and reject payload. |
| `base` | Defaults to `module`; allowed values are `module`, `portal`, or a named host resolver. |
| `path` | Required, begins with `/`, and rejects `..`, `javascript:`, `data:`, and direct external URLs. |
| `payload` | Optional controller binding map. `GET` and `DELETE` serialize it as query values, `POST`, `PUT`, and `PATCH` as JSON, `UPLOAD` as multipart file fields, and `kind: link` rejects payload. |
| `decode` | Optional response decoder name; unknown decoders fail validation and decode failures return provider errors. |

Supported effect types are:

| Type | Required Fields | Cleanup |
| --- | --- | --- |
| `polling` | `resource`, `interval`, `apply`, `dispose` | Abort in-flight request and stop timer. |
| `event-stream` | `resource` or host channel, `onMessage`, `dispose` | Close stream and release callbacks. |
| `drop` | `target`, `dispose` | Remove drop listeners and release retained file handles. |
| `resize` | `target`, `dispose` | Disconnect observers. |
| `close-guard` | guard name or callback, `dispose` | Remove close listeners. |
| `log` | channel | No long-running cleanup unless a host logger returns a disposer. |

Event results are typed:

| Result | Required Shape | Handling |
| --- | --- | --- |
| success | `{type:"success"}` plus optional public result data | Controller applies state updates or refreshes resources. |
| validation error | `{type:"validation-error", fields:{...}}` | Field errors are projected into the view model. |
| provider error | `{type:"provider-error", title}` plus optional `summary`, `status`, `requestID`, and field errors | Render through provider-safe error state. |
| navigation request | `{type:"navigate", path}` or host resolver object | Host performs safe navigation. |
| no-op | `{type:"noop"}` | No state change beyond clearing pending event state. |

Provider errors must not expose secrets, bearer tokens, raw credentials, stack
traces, SQL, or raw provider payloads.

Unknown event names fail validation before render or dispatch. Resource decode
failures return typed provider errors. Validation diagnostics identify the
source path, event/resource/effect name, field, and error code. Client logs
receive only redacted public diagnostics.

Effects start only after their owner mounts. Disposers run when the owner
unmounts or the effect is replaced. Every disposer must be idempotent; tests
verify that repeated cleanup does not panic, leak listeners, or emit duplicate
provider requests.

## Consequence

Every runtime helper must expose test seams: injectable event handlers, fake resource
clients, fake timers or event streams, observable state updates, and explicit
disposer calls. Unit tests should cover success, handler/resource failure, and
cleanup. E2e tests should cover only the host bridge and one representative
browser workflow for helpers that depend on browser APIs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Event UI concept](../v0.1.6/event)
- [Resource UI concept](../v0.4.1/resource)
- [Effect UI concept](../v0.1.7/effect)

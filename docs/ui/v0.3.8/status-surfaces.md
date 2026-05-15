---
title: Library status surfaces
description: BusDK UI library status, empty, loading, result, and error surface contract.
---

## Design References

- [UI color and status](./color-status)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Status surfaces render visible state. [`StatusPill`](./status-pill)
shows compact semantic status. [`EmptyState`](./empty-state),
[`LoadingState`](./loading-state), [`ResultPanel`](./result-panel),
and [`ErrorBanner`](./error-banner) render absence, loading,
operation result, and recoverable error states.

| Surface | Use When | Required Inputs | Behavior |
| --- | --- | --- | --- |
| `StatusPill` | A row or summary needs compact status. | `label` string; optional `status`. | `status` is `neutral`, `working`, `success`, `warning`, `danger`, or `muted`; default `neutral`; unknown values fail validation. |
| `EmptyState` | A collection or view has no items. | Public-safe `title` string. | Optional `event` renders one recovery control and emits only surface id/path plus event name. |
| `LoadingState` | Data or work is pending. | Public-safe `label` string; default `Loading`. | No events; replaced by loaded/error state. |
| `ResultPanel` | An operation completed. | Public-safe `title` string and `status`. | `status` uses the same semantic values as `StatusPill`; optional details and event controls render when supplied. |
| `ErrorBanner` | A recoverable error blocks or degrades the view. | Public-safe `title` string. | Optional `retry` and `dismiss` events emit only banner id/path plus event name. |

Public-safe text may include operation names, field names, status codes, and
request ids. It must not include tokens, secrets, raw provider payloads, stack
traces, SQL, private customer data, or credential headers.

## Consequence

Product modules own state meaning. Library status surfaces make that state
visible in a consistent form.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [State UI concept](./state)
- [UI color and status](./color-status)

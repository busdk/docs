---
title: bus-integration-worker
description: "bus-integration-worker will project worker lifecycle and status through Bus Events integration surfaces."
---

## `bus-integration-worker` — worker integration

`bus-integration-worker` is the current singular checkout scaffold for the
target plural `bus-integration-workers` provider. It owns generic worker
lifecycle projection, status reconciliation, metrics/evidence plumbing, and
other worker integration behavior that should not stay embedded inside
task-only integration modules.

The first concrete extraction underway is worker claim eligibility:
worker-specific routing based on assigned worker id, worker group, and eligible
environment filters. That logic is generic worker integration behavior even
when the surrounding task stream is still owned by
[`bus-integration-task`](./bus-integration-task).

The next extraction underway is the worker-start request contract used by
task-side supervisors to request disposable or persistent workers. Even while
the current event name remains `bus.task.worker.start.request` for
compatibility, the request payload and launcher helpers are moving under worker
integration ownership.

Current status: the module hosts reusable Go packages for worker integration
helpers and now includes the first plural `bus-integration-workers` command
slice. That command can consume `bus.workers.list.request` through Bus Events
and publish this environment's correlated `bus.workers.list.response` from a
static non-secret worker catalog. Do not treat it as a stable operator-facing
surface yet.
For current task-worker launch/orchestration behavior, use
[`bus-integration-task`](./bus-integration-task). For current task UX, use
[`bus-task`](./bus-task).

The first `bus.workers.*` request/response loop is:

1. Local `bus-api-provider-workers` publishes `bus.workers.list.request`.
2. Each worker environment running `bus-integration-workers` receives the
   request.
3. Each environment emits `bus.workers.list.response` with the original
   `correlationId`, environment identity, and a bounded worker list.
4. The local workers API provider merges those responses into one list view.

The current intended split is:

- `bus-integration-task` for task-thread launch/orchestration integration
- `bus-integration-worker` for generic worker identity/state integration

The create/pause/resume/assign worker controls, live container state,
proactive task claiming, and durable status evidence are still unfinished.

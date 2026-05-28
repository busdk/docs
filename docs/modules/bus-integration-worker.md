---
title: bus-integration-worker
description: "bus-integration-worker will project worker lifecycle and status through Bus Events integration surfaces."
---

## `bus-integration-worker` — worker integration

`bus-integration-worker` is the planned worker-focused integration module. It
is intended to own generic worker lifecycle projection, status reconciliation,
metrics/evidence plumbing, and other worker integration behavior that should
not stay embedded inside task-only integration modules.

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

Current status: there is no supported end-user command yet, but the module is
starting to host small reusable Go packages for worker integration helpers. Do
not treat it as a stable operator-facing surface yet.
For current task-worker launch/orchestration behavior, use
[`bus-integration-task`](./bus-integration-task). For current task UX, use
[`bus-task`](./bus-task).

This module is still a skeleton. The current intended split is:

- `bus-integration-task` for task-thread launch/orchestration integration
- `bus-integration-worker` for generic worker identity/state integration

The detailed event and API contracts are still being defined. Until they land,
read this page as a reserved ownership marker only.

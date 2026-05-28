---
title: bus-integration-worker
description: "bus-integration-worker will project worker lifecycle and status through Bus Events integration surfaces."
---

## `bus-integration-worker` — worker integration

`bus-integration-worker` is the planned worker-focused integration module. It
is intended to own generic worker lifecycle projection, status reconciliation,
metrics/evidence plumbing, and other worker integration behavior that should
not stay embedded inside task-only integration modules.

Current status: there is no supported end-user command, API, or event contract
in this module yet. Do not depend on `bus-integration-worker` directly today.
For current task-worker launch/orchestration behavior, use
[`bus-integration-task`](./bus-integration-task). For current task UX, use
[`bus-task`](./bus-task).

This module is still a skeleton. The current intended split is:

- `bus-integration-task` for task-thread launch/orchestration integration
- `bus-integration-worker` for generic worker identity/state integration

The detailed event and API contracts are still being defined. Until they land,
read this page as a reserved ownership marker only.

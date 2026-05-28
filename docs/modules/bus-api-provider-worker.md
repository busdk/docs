---
title: bus-api-provider-worker
description: "bus-api-provider-worker will expose worker identity and worker status through the Bus API layer."
---

## `bus-api-provider-worker` — worker API provider

`bus-api-provider-worker` is the planned Bus API provider module for worker
identity and worker-status surfaces.

Current status: there is no supported public API surface in this module yet.
Do not integrate against `bus-api-provider-worker` directly today. Current
worker/task configuration is still documented through modules such as
[`bus-task`](./bus-task) and [`bus-remote`](./bus-remote).

It is expected to connect the future `bus-worker` ownership layer with Bus API
resources for:

- configured worker identities
- worker profile and capability metadata
- active assignments and status views
- worker-related non-secret validation rules

This module is still a skeleton and does not yet define a stable API contract.
Treat this page as a reserved scope marker, not an implementation reference.

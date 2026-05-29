---
title: bus-worker
description: "bus worker will manage durable worker identities, profiles, and worker-home context for Bus."
---

## `bus-worker` — worker identities

`bus worker` is the Bus CLI/module for durable worker identities. It owns
concepts such as worker ids, profiles, capabilities, worker-home references,
registered groups/status, active-work views, and long-lived notes or memory
references.

The current design direction assumes those worker homes are Git-backed. That
serves two related Bus use cases:

- workers need their own durable repositories for `AGENTS.md`, memo logs, and
  other worker-local context
- Bus needs locally managed Git repositories for mirrored development sources
  so work can continue even when an upstream such as GitHub is temporarily
  unavailable
- the same repository infrastructure can also back human-facing content stores
  such as a shared Markdown wiki

The first worker registry stores `worker_home_ref` as a non-secret logical
reference. The preferred shape is:

```text
repos://workers/<worker-id>
```

That reference resolves through the repo module family to a repository record
whose kind is `worker-home`. Related refs use the same topology:
`repos://sources/<project-id>` for source mirrors and `repos://tasks/<task-id>`
for task-context repositories. `bus-worker` stores only the identity-owned
worker-home ref; `bus-repos` owns user-facing repo semantics,
`bus-integration-repos` owns provisioning/sync, and `bus-api-provider-repos`
owns API/controller exposure.

The current architecture direction is:

- `bus-task` owns generic task threads and assignment references
- `bus-agent` owns runtime/provider execution adapters
- `bus-worker` owns durable worker identity and worker-specific context
- the repo module family owns repository provisioning, sync, and API surfaces

The first direct `bus-worker` binary can create/list/show workers, create/list/show
groups, and print registered status snapshots. Live active-work telemetry and
worker-home provisioning remain planned follow-up work.

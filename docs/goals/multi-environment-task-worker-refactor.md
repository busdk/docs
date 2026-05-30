# Multi-Environment Task And Worker Coordination

## Goal

This goal now covers only the multi-environment coordination layer for Bus
tasks and workers. Repository operations, worker identity/lifecycle, task
system repair, and manual Spark worker bootstrap are split into separate
limited-scope goals so each lane can be implemented, reviewed, and accepted
independently.

The target topology is:

- a local `bus-events` service on the supervisor/control environment;
- a remote `bus-events` service on worker hosts such as
  `coding-agent@dev.hg.fi`;
- service-owned relay or sync routes that automatically move eligible Events
  in both directions;
- local API/controller services that publish canonical request Events;
- remote integration services that consume those requests, manage worker
  runtime state, and publish evidence back to the local side.

The normal product path should let an operator create or assign work locally,
see remote worker status locally, and guide workers without manually exporting,
importing, or copying Events between environments.

## Related Limited Goals

Use these focused files for work that used to be mixed into this handoff:

- `docs/goals/repos.md`: Git repository, branch, and worktree operations.
- `docs/goals/workers.md`: the `bus workers` product/API/integration
  surface for agent worker identity and lifecycle.
- `docs/goals/tasks.md`: completing the generic task/thread system and
  removing broken legacy task behavior.
- `docs/goals/manual-spark-worker-bootstrap.md`: the temporary manual
  remote Spark worker launcher used to accelerate implementation before the
  product worker control plane is complete.
- `docs/goals/service-owned-events-relay.md`: detailed Events relay
  service ownership and deployment.
- `docs/goals/service-owned-task-scheduler.md`: scheduler/service-loop
  details that remain relevant while task scheduling moves behind the worker
  and integration surfaces.

If another scope appears during implementation, create or update a focused
goal file instead of expanding this file back into a catch-all handoff.

## Current Product Direction

The product architecture follows the standard Bus module family pattern:

- `bus-{name}` is the user-facing product and CLI surface.
- `bus-api-provider-{name}` is the local API/controller provider mounted by
  `bus-api`.
- `bus-integration-{name}` is the event/integration provider run by the
  integration layer.

For this goal, `bus-task` owns task/thread UX and `bus-workers` owns worker UX.
The local workers API provider publishes canonical `bus.workers.*` request
Events, and the remote workers integration provider consumes those Events in
the worker environment. Task lifecycle and assignment use canonical
`bus.task.*` Events.

Legacy names such as `bus.work.*`, `bus.dev.task.*`, singular
`bus.worker.*`, and historical `bus-integration-dev-task` wording should not
be used as primary product names. Keep them only when implementing explicit
compatibility, migration, or historical documentation.

## Multi-Environment Requirements

Local and remote Events services must run continuously enough that the normal
operator path does not require manual relay commands. A route should move:

- local worker create/list/pause/resume/assign requests to the target worker
  environment;
- local task create/approve/assign/guidance Events to the environment that
  owns the worker or queue;
- remote worker list/status/lifecycle evidence back to the local control
  environment;
- remote task claim/running/progress/terminal evidence back locally.

The list path must support multiple environments returning responses to the
same local request. Local projections must preserve the environment identity so
two environments can report the same worker id without overwriting each other.

Routes must use durable cursors, origin metadata, idempotent imports, and
loop-prevention. Status output should name route id, source and destination
environment ids, configured forward/import filters, last success/error, and
non-secret credential-source labels.

## Target Worker Host For Current Proof

This supervisor host should not assume local Docker or nested virtualization.
Docker-backed worker proof for this goal should use `coding-agent@dev.hg.fi`
unless a later environment explicitly provides local Docker.

Remote Codex/App Server worker tests should pass the raw model id exactly:

```text
gpt-5.3-codex-spark
```

Do not normalize or alias this model name as part of the current goal.

## Acceptance Criteria

This goal is accepted only when current evidence proves:

- local and remote `bus-events` services can run as service-owned components;
- eligible `bus.task.*` and `bus.workers.*` Events relay both directions
  without manual import/export as the normal path;
- worker list requests can collect and project responses from multiple
  environments;
- local task assignment and guidance reach the environment that owns the
  worker;
- remote worker claim, progress, status, lifecycle, and terminal task evidence
  return locally;
- route status is observable and does not leak tokens;
- duplicate relay/import behavior is idempotent and does not echo events back
  to their origin;
- at least one remote `coding-agent@dev.hg.fi` Codex/App Server worker is
  controlled through the product Events/API path rather than only through the
  manual bootstrap script;
- mixed local plus remote routing/capacity behavior is proven;
- docs, README, CLI help, SDD, and plan files tell the same architecture story;
- touched modules and superproject pointers are reviewed, committed, and
  pushed.

Do not mark this goal complete merely because focused unit tests pass in the
individual task, worker, or Events modules. Those tests are necessary evidence,
but this goal needs the integrated multi-environment route to work.

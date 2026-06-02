# Tasks Goal

## Goal

Finish the local Bus task/thread MVP on top of the accepted Bus Events,
workers, and services stack.

A Bus task is a bidirectional communication thread backed by the Bus Events
API. Task modules should let operators and supervisors create tasks, list
tasks, send messages to a task, read the task message history, record task
status, and connect a task reference to an existing worker identity. They
should not know how the work is executed.

The module architecture should match the other Bus service families:
`bus-task` is the CLI client, `bus-api-provider-task` is a thin API
controller, and `bus-integration-task` is the task service/provider that owns
business logic and persistence.

## Current Baseline

This goal was refreshed on 2026-06-02 after the local workers goal was
accepted in `docs/docs/goals/workers.md`.

Accepted baseline:

- `bus services` now starts the local native services stack for the MVP.
- Workers can be created with different models, including raw
  `gpt-5.3-codex-spark`, through the worker product path.
- `bus workers` already covers worker create, message, messages, status, logs,
  attach, and stop flows.
- `bus-integration-worker` accepts `bus.workers.assign.request` and records
  the worker `active_task_ref`.
- `bus-integration-worker` accepts `bus.workers.message.request` with an
  optional `task_ref` and delivers supervisor guidance to the live worker when
  runtime delivery is configured.
- `bus-integration-repos` owns local branch and worktree materialization used
  by worker execution.
- `bus-api-provider-events` already protects canonical `bus.task.*` names with
  task scopes such as `task:send`, `task:read`, `task:reply`, `task:claim`,
  and `task:admin`.

Current task-module state:

- `bus-task` is the current task CLI owner, but the main checkout still carries
  older development-task, worker, container, runtime, and worktree residue.
- `bus-api-provider-task` is still skeletal in the promoted main checkout.
- `bus-integration-task` still contains historical worker/App Server/container
  bridge behavior. It should become the task service/provider instead:
  task business logic, persistence, projection, and task-side coordination
  live here, while worker/runtime pieces move to worker-owned modules.
- The older isolated `codex/task-bidi-core` worktrees were useful review
  evidence, but they are not the promoted software baseline for this goal.

## MVP User Story

1. The operator starts the local stack with `bus services up`.
2. One or more workers already exist, or are created through the accepted
   worker path with a selected model such as `gpt-5.3-codex-spark`.
3. The supervisor creates a task with a title, body, repository context when
   needed, and non-secret metadata.
4. The supervisor can list tasks and inspect a single task thread.
5. The supervisor can send messages to the task and read messages already
   written by the supervisor, worker, or system.
6. The task is assigned to a worker identity by publishing/using the accepted
   worker assignment path, or by sending worker guidance that includes the
   task reference.
7. The worker does the task in a repository worktree owned by the worker/repos
   stack, so multiple tasks for the same Git repository can proceed in
   parallel.
8. The supervisor monitors and guides the worker through task messages plus
   the accepted worker status, messages, logs, and attach surfaces.
9. Completion, blockage, or failure is recorded as task Events and can be read
   back from the task thread.

## Module Boundary

`bus-task` owns the user-facing task CLI. It should expose task create, list,
show, message, assign, status, and read/replay operations as a client of the
task API/controller surface. It should not publish directly to every internal
task service Event when an API/controller route exists, just as `bus workers`
uses the worker API surface.

`bus-api-provider-task` owns the task HTTP/API controller. It should validate
requests, expose the route surface through `bus-api`, publish task request
Events, and read task views through the task Events/API contract. It should
not own task business logic, durable task storage, worker assignment policy,
or project/worktree state. Its in-process projection is a cache of task
service response/snapshot Events, not the task domain store.

`bus-integration-task` owns the task service/provider. It implements task
business logic, task persistence, task projection, task message handling,
task-side assignment state, and terminal task status. Its durable state may be
stored in PostgreSQL or derived directly from the Bus Events API, but it must
remain reachable through Bus Events API contracts. It consumes task request
Events from the API provider and emits task response/status/history Events.

Worker identity, model choice, worker lifecycle, runtime delivery, Codex App
Server communication, and `active_task_ref` handling belong to the worker
module family.

Task project data is represented as Git worktrees. Repository checkout, branch
creation, worktree materialization, dirty-state detection, locking, cleanup,
and promotion remain repository/worker-owned capabilities; task records should
store and expose the resulting project/worktree references rather than
duplicating low-level Git mechanics in the API controller.

Remote access is not a Bus Task implementation concern. Remote task support
comes from using a deployed or relayed Bus Events API; task modules should keep
using the same Events API contract locally and remotely.

Containers and VMs are not part of this MVP. Native `bus services` support is
the current execution baseline.

## Service-Family Pattern

Tasks should follow the same architecture as Workers, Repos, and Events:

- the CLI is a product client;
- the API provider is an HTTP controller and Events adapter;
- the integration service owns domain behavior, persistence, and side effects;
- the Events API is the shared transport, authorization, replay, and remote
  boundary;
- projected API reads are rebuilt from integration response/status Events;
- durable service state lives in the integration service's store, not in the
  controller.

The task API provider should behave like the worker and repos providers:
validate the HTTP request, publish a bounded canonical request Event, return a
stable accepted/error response, and keep reads backed by an Events-fed
projection. The task integration service should behave like the worker and
repos integrations: listen for request Events, apply business rules, update
its persistent state, and publish response/status/history Events that the API
provider and other consumers can replay.

## Required Event Contract

The task product must use the canonical Bus Events namespace:

```text
bus.task.*
```

The first accepted MVP should define a small request/response/status contract
that mirrors the worker and repos patterns. The exact names can be refined
during implementation, but the expected shape is:

- `bus.task.list.request` from the API provider, answered by
  `bus.task.list.response` from `bus-integration-task`;
- `bus.task.create.request` from the API provider, resulting in
  `bus.task.created` and a task status snapshot;
- `bus.task.message.request` from the API provider, resulting in
  `bus.task.message` and updated task projection evidence;
- `bus.task.assign.request` from the API provider, resulting in
  `bus.task.assigned` and worker assignment through the accepted worker path;
- task status snapshots or responses for show/status reads;
- `bus.task.error` or stable error responses for rejected requests.

The state/history Events should use existing canonical names where possible:

- `bus.task.created` for task creation;
- `bus.task.message` for supervisor, worker, and system messages;
- `bus.task.assigned` when recording the task-side assignment relation;
- `bus.task.reopened` when reopening work;
- `bus.task.done`, `bus.task.blocked`, `bus.task.failed`, and
  `bus.task.canceled` for terminal or paused states.

The task service/provider should use `bus-events` and the Bus Events API as
its integration contract and source of truth. It may maintain durable
projections in PostgreSQL or directly over the Bus Events stream. Do not add a
remote transport, worker scheduler, worker launcher, low-level Git
implementation, container runner, or VM runner to task modules.

If new task request, response, or snapshot Event names are added, update
`bus-events`, `bus-api-provider-events` ACL rules, capability metadata, and
tests in the same slice so callers do not need broad administrative Events
scopes to use the task MVP.

`bus-integration-task` projection must be deterministic enough that any
consumer with task read access can reconstruct:

- task identity, title, body, status, and non-secret metadata;
- ordered task messages;
- current worker assignment, when present;
- repository/worktree references for task project data;
- terminal status and bounded evidence references.

The API provider's projection should be restart-safe in the same sense as the
worker provider: it can rebuild from replayed task response/status/history
Events when configured to listen and replay, and it must not be treated as the
authoritative task store.

## Worker Connection

Task assignment should use the accepted worker Events/API surface instead of
inventing a task-owned worker bridge.

The expected MVP path is:

- `bus-api-provider-task` publishes a task assignment request Event;
- `bus-integration-task` records the task-side assignment and publishes or
  projects `bus.task.assigned`;
- worker control publishes `bus.workers.assign.request` with `task_ref` for a
  specific worker identity;
- supervisor guidance can publish `bus.workers.message.request` with the same
  `task_ref`;
- worker responses and status snapshots remain worker-owned evidence, while
  task messages and task status remain task-owned history.

The implementation may choose whether `bus-integration-task` calls the worker
provider/API, emits worker request Events, or coordinates both task-side and
worker-side records, but the proof must show the worker receives the task
reference through the accepted worker path.

## Implementation Slices

1. Rebaseline the task modules against this goal and remove stale active
   guidance from the older `task-bidi` promotion slice.
2. Implement or refresh `bus-integration-task` as the task service/provider
   with task business logic, persistence, projection, message handling,
   assignment state, and terminal status.
3. Define the canonical task request, response, snapshot, history, and error
   Events, and update `bus-events` plus Events API ACL/capability tests for
   that contract.
4. Implement or refresh `bus-api-provider-task` as the thin API controller for
   create, list, show, message, assign, status, and replay/read surfaces,
   using Events to communicate with `bus-integration-task`.
5. Refactor `bus-task` into the product CLI over the API/controller surface,
   with script-friendly text and JSON output.
6. Move or remove the historical worker/App Server/container bridge code from
   task modules; worker-owned modules keep runtime delivery and lifecycle.
7. Wire the task API controller and task integration service into `bus-api`
   and the local `bus services` profile when they need to be available in the
   MVP stack.
8. Prove task-to-worker assignment through `bus.workers.assign.request` or the
   accepted worker API endpoint that publishes it.
9. Prove supervisor guidance through `bus.workers.message.request` with a
   `task_ref`.
10. Prove parallel same-repository task execution by showing distinct
   worker/repos-owned worktree references for distinct task refs.

Before product-code work begins, create feature worktrees and branches for the
affected modules and record their branch names and locations in this goal. No
module merge or promotion should happen until the operator confirms the work.

Current implementation isolation:

These worktrees are relative to the supervisor checkout root
`/Users/jhh/git/busdk/agent-supervisor`.

- BusDK superproject: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/busdk`.
- `bus-events`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-events`.
- `bus-api-provider-events`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-api-provider-events`.
- `bus-integration-task`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-integration-task`.
- `bus-api-provider-task`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-api-provider-task`.
- `bus-task`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-task`.
- `bus-api`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-api`.
- `bus-api-provider-worker`: branch `codex/tasks-mvp`, worktree
  `worktrees/tasks-mvp/bus-api-provider-worker`, used only if the task MVP
  needs worker API contract tests or a narrow compatibility adjustment.

The older `worktrees/task-bidi/*` worktrees remain unmerged historical
prototype/reference material and are not the implementation branch for this
current goal.

Current implementation status in the `codex/tasks-mvp` feature worktrees:

- `bus-events` defines the shared task request, response, status snapshot,
  message, assignment, view, and error contract under canonical `bus.task.*`
  names.
- `bus-api-provider-events` grants scoped Events API ACL coverage for the new
  task request, response, status, message, assignment, and error Events.
- `bus-integration-task` has been cut over to a task service/provider. The old
  development worker/App Server/container/worktree bridge was removed from the
  feature worktree. The service consumes task request Events, persists and
  projects task state, publishes task history/status/list/error Events, and
  emits `bus.workers.assign.request` when task assignment links a task to a
  worker identity.
- `bus-api-provider-task` exposes the thin task HTTP controller and
  Events-fed projection for create, list, show/status, messages, message,
  assign, and status-change routes.
- `bus-api` has a built-in `tasks`/`task` module backend that mounts the task
  provider and communicates with the task service through the Bus Events API.
- `bus-task` has been refactored to a task-only CLI client over the task API
  controller. The feature worktree no longer contains the historical worker
  launcher, runtime, container, or Git helper command code.
- BusDK service profiles now include `bus/integration/tasks/local` and a
  combined `bus/api/tasks-workers` gateway profile; `services.yml` starts the
  local tasks integration service alongside the accepted worker stack.

Focused verification already run in the feature worktrees:

- `go test ./pkg/task` in `bus-events`;
- `go test ./pkg/eventsapi` in `bus-api-provider-events`;
- `go test ./pkg/tasksapi` in `bus-api-provider-task`;
- `go test ./...` in `bus-integration-task`;
- `go test ./...` in `bus-task`;
- `go test -mod=mod -modfile=/private/tmp/bus-api-tasks.mod ./internal/backends -run 'TestTask|TestTasks'`
  in `bus-api`, using a temporary modfile to point ordinary Bus dependencies
  at checked-out sibling modules and task/Event dependencies at the feature
  worktrees;
- `bus-services stack validate` against a temporary copy of the edited BusDK
  `services.yml` and the edited `profiles` directory, using dummy non-secret
  validation env values;
- `BUS_TASK_BIN=/private/tmp/bus-task-tasks-mvp bash tests/e2e.sh` in
  `bus-task`.

## Dependencies

Completed dependency:

- `docs/docs/goals/workers.md` is accepted for the local native workers MVP and
  is the baseline for worker creation, model selection, worker identity,
  worker messaging, and worker-owned task assignment.

Active dependencies for implementation:

- Use the existing Bus Events API and `bus-events` canonical task helpers.
- Match the worker/repos request-response-snapshot architecture instead of
  inventing a task-specific shortcut.
- Keep task business logic and durable task state in `bus-integration-task`.
- Keep `bus-api-provider-task` as the API controller that communicates through
  Events.
- Use the accepted worker assignment and message APIs/events for worker
  connection.
- Use repository/worker-owned worktree materialization for per-task Git
  worktrees.

This goal must not wait on container, VM, or remote-access implementation
work. Those concerns are outside the Bus Task implementation boundary for the
current MVP.

## Acceptance Criteria

This goal is accepted when all of the following are true in the promoted main
checkouts:

- `bus services up` can start the local stack needed for task and worker MVP
  proof.
- A worker can be created through the accepted worker path with a selected
  model such as `gpt-5.3-codex-spark`.
- The task product can create, list, show, message, assign, and read/replay
  tasks through the task CLI/API controller.
- `bus-api-provider-task` is a thin controller and communicates through Events
  with `bus-integration-task`.
- `bus-api-provider-task` serves reads from an Events-fed projection of task
  service response/status/history Events, not from controller-owned task state.
- `bus-integration-task` owns task business logic and persistence, using
  PostgreSQL or direct Bus Events projections behind the same Events/API
  contract.
- The task Events contract includes request, response/status, history, and
  error Events with Events API ACL/capability coverage.
- Task history is reconstructed from canonical `bus.task.*` Events and any
  durable projections remain consistent with that stream.
- A task can be connected to a worker identity through
  `bus.workers.assign.request` or the worker API endpoint that publishes it.
- Supervisor guidance can be delivered to the live worker with a `task_ref`
  through `bus.workers.message.request` or the worker API endpoint that
  publishes it.
- The supervisor can monitor and guide work with task history plus accepted
  worker status, messages, logs, and attach surfaces.
- Parallel work on the same Git repository is proved with distinct
  Git worktree references for distinct task refs.
- Task modules contain no worker launcher, runtime delivery, container, VM,
  remote-transport, or Git worktree implementation logic.
- Focused unit and e2e tests cover provider publishing/projection, CLI output,
  assignment to worker identity, supervisor guidance, terminal task state, and
  local services-stack proof.

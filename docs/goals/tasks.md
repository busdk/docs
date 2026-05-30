# Tasks Goal

## Goal

Finish the generic Bus task/thread system so it is no longer split between old
development-task names, hidden worker behavior, and partially migrated command
surfaces.

`bus-task` should be the user-facing generic task/thread product. It should
not be Codex-only, development-only, or tied to one worker environment.

## 2026-05-30 Review Addendum

This goal was reviewed against the neighboring goal files and current Bus
module checkouts on 2026-05-30. The goal direction remains right, but the
implementation should be sequenced around the current split between task,
worker, repository, and relay ownership.

Current implementation state:

- `bus-task` is the current `bus task` CLI owner and already publishes and
  replays canonical `bus.task.*` events, with assignment, priority, blocker,
  dependency, and monitor/status fields present in the code path. It still
  carries internal `devTask` names and worker-controller commands as migration
  residue, so the public contract is not accepted merely because the command
  exists.
- `bus-api-provider-task` is still a skeleton. It has no service binary, HTTP
  handlers, durable projection, or `bus.task.*` publisher yet.
- `bus-integration-task` consumes canonical `bus.task.*` streams today, but it
  still owns App Server worker execution, start-request consumption, isolated
  worktree preparation, scheduler bridge behavior, and task closeout evidence.
  Those pieces should be treated as transitional until worker-owned lifecycle,
  repository/worktree primitives, and scheduler/service-loop contracts are
  accepted.
- `bus-integration-worker` and `bus-api-provider-worker` already contain
  plural worker scaffolding and reusable claim/routing/scheduler packages, but
  their plans still have open productization items before task integrations can
  stop carrying worker launch and routing glue.
- `bus-events` has canonical `bus.task.*` helper code, while some lower-level
  append-key prefixes, tests, and relay fixtures still mention historical
  `dev-task` or `bus.dev.task.*` names. Treat those as compatibility/audit
  work unless a migration slice explicitly removes them.

Dependencies for full acceptance:

- Finish the worker goal enough that `bus-integration-worker` owns worker
  identity, lifecycle, claim matching, start requests, capacity, and the
  service loop. Until then, `bus-integration-task` cannot be fully slimmed to
  task-specific bridge/review semantics.
- Finish the repos goal enough that task and worker callers use repos-owned
  branch/worktree creation, status, dirty/locked/active detection, and
  conservative cleanup primitives instead of duplicating Git policy in task
  integration code.
- Finish the service-owned Events relay before treating remote task routing or
  returned claim/progress/terminal evidence as normal product proof.
- Finish or update the service-owned task scheduler goal against the current
  `bus.task.*` / `bus-integration-task` / worker-family naming before using it
  as implementation guidance; older `bus.dev.task.*` and
  `bus-integration-dev-task` wording in that handoff is historical.
- Finish the multi-environment task/worker coordination goal before calling
  cross-environment assignment, claim, status, and terminal evidence complete.

No product implementation worktree or feature branch was created for this
review. The operator requested review-only work and allowed this goal file to
be updated in the main checkout.

## Module Boundary

`bus-task` owns task/thread UX, task references, approval, assignment,
priority, blockers, dependencies, queue visibility, and task status.

`bus-api-provider-task` is the planned API/controller provider for task
requests and read projections.

`bus-integration-task` should become the task-specific event bridge and
task-lifecycle/review owner. It should not remain the hidden owner of worker
identity, worker lifecycle, capacity, routing, or runtime launch policy.

Worker identity and worker lifecycle belong to the workers goal. Runtime
provider execution belongs to `bus-agent` and the App Server/runtime layer.

## Required Behavior

The canonical event namespace for task lifecycle is:

```text
bus.task.*
```

Legacy names such as `bus.dev.task.*` and `bus.work.*` should be removed from
primary product paths or explicitly documented as compatibility.

The task product should support:

- create/start task or thread work;
- approve, reopen, cancel, and complete tasks;
- assign tasks to workers or environments;
- represent priority, blockers, dependencies, and claimability;
- expose deterministic queue and monitor state for workers and supervisors;
- preserve assignment metadata and non-secret routing metadata;
- produce script-friendly text and JSON output;
- provide focused subcommand help instead of falling back to top-level help.

Task evidence should be deterministic enough that workers can claim approved
work safely and supervisors can distinguish queued, launch-pending, claimed,
running, stale, blocked, terminal, and false-active work.

## API Provider Slice

`bus-api-provider-task` starts as a skeleton and should grow in small focused
slices:

- stable request/response schemas for list, show, status, and errors;
- a bounded read projection over canonical task Events;
- HTTP handlers suitable for mounting in `bus-api`;
- mutation request shapes for create, approve, assign, reopen, and cancel that
  publish canonical `bus.task.*` Events without owning runtime execution.

The provider should not execute work, launch workers, or store credentials.

## Integration Slice

`bus-integration-task` should keep task-specific behavior: translating task
Events, building task prompts, handling task review/reopen semantics, and
bridging task evidence to the runtime layer when needed.

Remaining worker launch and scheduler glue should continue moving to
worker-owned packages or the workers integration provider.

## Acceptance Criteria

This goal is accepted when:

- `bus-task` is the stable generic task/thread CLI;
- task creation, approval, assignment, priority, blockers, dependencies,
  status, monitor, and queue behavior are tested through user-facing and
  worker-facing paths;
- the API provider exposes the first stable task read/mutation controller
  surface without executing work;
- task status/projection can distinguish queued, approved, claimable,
  assigned, running, blocked, stale, terminal, and reopened work;
- old `bus dev task`, `bus dev work`, `bus.dev.task.*`, and `bus.work.*`
  primary references are audited, removed, or marked as compatibility;
- `bus-integration-task` is slimmed to task-specific bridge/review semantics;
- focused unit tests cover the task state machine, output contracts, help
  routing, projection behavior, and compatibility decisions;
- integration/e2e proof is added after the unit-tested implementation slices
  are accepted.

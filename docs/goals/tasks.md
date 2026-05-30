# Tasks Goal

## Goal

Finish the generic Bus task/thread system so it is no longer split between old
development-task names, hidden worker behavior, and partially migrated command
surfaces.

`bus-task` should be the user-facing generic task/thread product. It should
not be Codex-only, development-only, or tied to one worker environment.

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

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

The implementation-state notes in this section are a historical baseline from
the review date. The 2026-05-31 implementation direction and progress sections
below supersede this baseline for the current isolated worktrees.

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

Historical dependencies for the broader pre-refactor goal:

- Finish `docs/goals/workers.md` enough that `bus-integration-worker` owns
  worker identity, lifecycle, claim matching, start requests, capacity, and
  the service loop. The current narrower task-only slice avoids depending on
  this by removing worker launch and routing code from task modules rather
  than keeping transitional ownership there.
- Finish `docs/goals/repos.md` enough that task and worker callers use
  repos-owned branch/worktree creation, status, dirty/locked/active detection,
  and conservative cleanup primitives instead of duplicating Git policy in
  task integration code.
- Finish `docs/goals/service-owned-events-relay.md` before treating remote
  task routing or returned claim/progress/terminal evidence as normal product
  proof.
- Finish or update `docs/goals/service-owned-task-scheduler.md` against the
  current `bus.task.*` / `bus-integration-task` / worker-family naming before
  using it as implementation guidance; older `bus.dev.task.*` and
  `bus-integration-dev-task` wording in that handoff is historical.
- Finish `docs/goals/multi-environment-task-worker-refactor.md` before
  calling cross-environment assignment, claim, status, and terminal evidence
  complete.

No product implementation worktree or feature branch was created for this
review. The operator requested review-only work and allowed this goal file to
be updated in the main checkout.

## 2026-05-31 Implementation Direction

The operator reopened this goal for implementation with a narrower boundary:
task modules should support the task feature BusDK already had, but without
worker-related code. A Bus task is a bidirectional communication thread backed
by the Bus Events API. Task code may create a thread, publish messages,
replay/listen to messages, expose status derived from task Events, and provide
API/controller shapes for those operations. Task code must not know who uses a
thread or how it is executed.

This implementation must use `bus-events` and the Bus Events API as the event
transport and source of truth. Do not add a local task database, a worker
launcher, container execution, Git worktree management, scheduler capacity
logic, model/profile/runtime selection, or repository promotion behavior to
the task modules. Any remaining Worker Agent, container, scheduler, runtime,
or worktree code should move to the worker module family or another owning
module.

Implementation isolation for this slice:

These worktree paths are relative to the supervisor checkout root. In this
session that root is the current `agent-supervisor` working directory; another
operator can set `BUSDK_SUPERVISOR_ROOT` to their equivalent checkout and use
the same relative paths.

- `bus-task`: branch `codex/task-bidi-core`, worktree
  `worktrees/task-bidi/bus-task`.
- `bus-api-provider-task`: branch `codex/task-bidi-core`, worktree
  `worktrees/task-bidi/bus-api-provider-task`.
- `bus-integration-task`: branch `codex/task-bidi-core`, worktree
  `worktrees/task-bidi/bus-integration-task`.
- `bus-integration-worker`: branch `codex/task-bidi-core`, worktree
  `worktrees/task-bidi/bus-integration-worker`, used for worker-owned code
  that must survive task-module cleanup.
- `bus-api`: branch `codex/task-bidi-core`, worktree
  `worktrees/task-bidi/bus-api`, used for the explicit task provider mount.
- `bus-events`: detached dependency worktree
  `worktrees/task-bidi/bus-events`, used only so isolated task worktrees can
  resolve the existing `../bus-events` module replacement.

No merge or promotion should happen until the operator confirms the work.

## 2026-05-31 Implementation Progress

Current slice status in the isolated worktrees:

- `bus-task` has a task-only CLI over the Bus Events API. User-facing tests
  now cover create, message, close, list, replay, and follow behavior. The
  stale help/e2e assertions for worker runtime flags were replaced with
  task-thread assertions.
- `bus-api-provider-task` now exposes `pkg/tasksapi` with stable task request
  and response shapes, Bus Events-backed create/message/close/list/replay
  helpers, deterministic error envelopes, provider-owned OpenAPI/capability
  metadata, and a mountable HTTP handler for the first task read/mutation
  controller surface. It still has no standalone service binary; it is mounted
  through `bus-api` when that host enables the task provider.
- `bus-integration-task` has a task-thread replay/follow command and package.
  Its old worker/App Server e2e script was replaced with an Events-only smoke,
  stale disposable-worker request notes were moved into explicit
  worker/repository-owned handoff language, and its local module dependency
  list now matches the single `bus-events` replacement used by `go.mod`.
- `bus-integration-worker` guidance records that worker launch, claim,
  lifecycle, capacity, and bridge replacement work belongs to worker-owned
  modules rather than back in task modules.
- `bus-api` now has a focused task provider mount following the existing
  explicit provider/enable-module pattern. The mount wires
  `bus-api-provider-task` through Bus Events API configuration, OpenAPI path
  aggregation, and capability discovery without adding task business logic to
  core `bus-api`.
- `bus-task/tests/live-events-e2e.sh` proves the cross-module flow against a
  real `bus-api-provider-events` memory backend. The smoke signs a local
  task-scoped JWT, creates/messages/closes/replays task threads with
  `bus-task`, replays the same thread with `bus-integration-task`, creates a
  second thread through the `bus-api` task provider mount, and verifies that
  `bus-task` can replay the `bus-api`-created thread from the same Bus Events
  API history.

Recent verification:

- `make check` passed in `worktrees/task-bidi/bus-task`.
- `make check` passed in `worktrees/task-bidi/bus-api-provider-task`.
- `go test ./pkg/tasksapi` passed in
  `worktrees/task-bidi/bus-api-provider-task` after adding provider metadata.
- `make check` passed in `worktrees/task-bidi/bus-integration-task`.
- `go test ./...`, `make test`, and `make lint` passed in
  `worktrees/task-bidi/bus-api`.
- `go test ./internal/backends ./internal/server`, `make test`, `make lint`,
  and `tests/e2e/068-task-provider-mount.sh` passed in
  `worktrees/task-bidi/bus-api` after adding task OpenAPI/capability
  aggregation.
- `tests/live-events-e2e.sh` passed in `worktrees/task-bidi/bus-task`.
- Focused Markdown lint has passed for changed module docs and this goal file.
- Boundary scans show task-module Go code only imports Bus Events packages;
  worker/runtime wording remains only in negative tests, historical handoff
  notes, or boundary guidance.

## Module Boundary

`bus-task` owns task/thread UX, task references, participant labels, message
publication, close/reopen-style thread status, and replay/listen output for
task Events.

`bus-api-provider-task` owns the task API/controller package for task requests
and read projections. It currently has a mountable handler for `bus-api`, but
it does not own a standalone service binary.

`bus-integration-task` should become the task-specific Events replay/follow
bridge for consumers that need task-thread streams. It should not remain the
hidden owner of worker identity, worker lifecycle, capacity, routing, runtime
launch policy, repository state, or worktree policy.

Worker identity and worker lifecycle belong to the workers goal. Runtime
provider execution belongs to `bus-agent` and the App Server/runtime layer.
Assignment, claimability, queue visibility, scheduler decisions, supervisor
evidence, repository promotion, and execution state belong to worker,
scheduler, repository, or runtime-owned goals rather than this task goal.

## Required Behavior

The canonical event namespace for task lifecycle is:

```text
bus.task.*
```

Legacy names such as `bus.dev.task.*` and `bus.work.*` should be removed from
primary product paths or explicitly documented as compatibility.

The task product should support:

- create a bidirectional task thread;
- publish messages into a task thread;
- close and replay a task thread;
- list known task threads from canonical task-created Events;
- preserve participant labels and non-secret message metadata;
- produce script-friendly text and JSON output;
- provide focused subcommand help instead of falling back to top-level help.

Task evidence should be deterministic enough that any consumer can reconstruct
the thread from Bus Events. Worker-owned modules may interpret task threads as
input to assignment, queue, claim, execution, or supervisor workflows, but
those interpretations are outside the task modules.

## API Provider Slice

`bus-api-provider-task` now has the first Events-backed package and mountable
handler slice. Remaining provider work should grow in small focused slices:

- keep stable request/response schemas for list, show, status, and errors;
- keep bounded read projection over canonical task Events;
- preserve HTTP handlers suitable for mounting in `bus-api`;
- preserve provider-owned OpenAPI route metadata, public route prefixes, and
  Bus Events capability metadata for `bus-api` discovery;
- preserve mutation request shapes for create, message, close, and
  replay/listen behavior that publish or read canonical `bus.task.*` Events
  without owning runtime execution;
- keep published scopes aligned with `bus-api-provider-events` ACL behavior
  (`task:send` for creation, `task:reply` for messages, `task:admin` for
  closing, and `task:read` for replay).

The provider should not execute work, launch workers, assign workers, project
worker queue state, or store credentials.

## Integration Slice

`bus-integration-task` should keep task-specific behavior: translating,
replaying, filtering, and following task Events for task-thread consumers.

Remaining worker launch and scheduler glue should continue moving to
worker-owned packages or the workers integration provider.

## 2026-05-31 Pre-Promotion Acceptance Audit

This audit applies to the isolated `codex/task-bidi-core` worktrees listed
above. It is not a merge or release acceptance; no promotion should happen
until the operator confirms the work.

| Requirement | Current evidence | State |
| --- | --- | --- |
| `bus-task` is the stable generic task/thread CLI. | `bus-task` now exposes only task-thread commands over the Bus Events API; `run/run_test.go` covers help, create, say, show/status, close, list, and watch; `make check` passed in the `bus-task` worktree. | Satisfied in the isolated worktree. |
| Task creation, messaging, closing, listing, replay, and follow behavior are tested through user-facing paths. | `bus-task` command tests cover those paths, `tests/e2e.sh` checks the user-facing help surface, and `tests/live-events-e2e.sh` drives create/message/close/list/replay/follow through a real Events API. | Satisfied in the isolated worktree. |
| The API provider exposes the first stable task read/mutation controller surface without executing work. | `bus-api-provider-task/pkg/tasksapi` provides create, message, close, list, replay, status, deterministic errors, strict JSON decoding, OpenAPI path metadata, public route prefixes, and Event capabilities. Tests reject worker-owned fields such as `worker_id`. | Satisfied in the isolated worktree. |
| Task projection reconstructs thread messages and status from canonical Bus Events. | Provider and CLI tests replay `bus.task.created`, `bus.task.message`, and `bus.task.closed`; list/status tests derive open/closed state from Event history. | Satisfied in the isolated worktree. |
| Legacy `bus dev task`, `bus dev work`, `bus.dev.task.*`, and `bus.work.*` primary references are audited, removed, or marked compatibility. | Boundary scans found legacy/worker wording only in negative tests, boundary guidance, or historical handoff notes; compiled task-module dependencies list standard library plus `bus-events` / `eventsapi` and module-local packages. | Satisfied for task-owned worktrees. |
| `bus-integration-task` is slimmed to task-thread replay/follow semantics. | The old `pkg/devtaskintegration` execution bridge is removed; `pkg/taskintegration` consumes canonical task Events; `Makefile.local` now lists only `bus-events` as a source dependency; `make check` passed. | Satisfied in the isolated worktree. |
| Focused unit tests cover task state machine, output contracts, help routing, projection behavior, and compatibility decisions. | `bus-task`, `bus-api-provider-task`, and `bus-integration-task` tests cover command help, event publishing, projection/replay, handler errors, metadata, and worker-field rejection. | Satisfied in the isolated worktrees. |
| Integration/e2e proof covers accepted slices. | `bus-task/tests/live-events-e2e.sh` starts the real `bus-api-provider-events` memory backend, signs a task-scoped JWT, drives `bus-task`, `bus-integration-task`, and the `bus-api` task provider mount, and passed. | Satisfied in the isolated worktrees. |

Remaining work before final acceptance is review and promotion choreography:
commit owning modules first, then update BusDK and supervisor submodule
pointers as appropriate. Do not merge or promote until the operator confirms.

## Review Targets

Start review from these isolated worktree entry points:

- `bus-task`: review `run/run.go`, `run/run_test.go`, `internal/cli/flags.go`,
  `tests/e2e.sh`, and the new `tests/live-events-e2e.sh`. The large deletion
  set is expected: it removes old worker/runtime/repository execution code
  from the task CLI.
- `bus-api-provider-task`: review the new `pkg/tasksapi/tasks.go`,
  `pkg/tasksapi/metadata.go`, `pkg/tasksapi/tasks_test.go`, and
  `tests/e2e.sh`. The old package stub files were removed.
- `bus-integration-task`: review `cmd/bus-integration-task/main.go`, the new
  `pkg/taskintegration/taskintegration.go`,
  `pkg/taskintegration/taskintegration_test.go`, `tests/e2e.sh`, and the
  module docs. The large deletion set is expected: it removes the old
  `pkg/devtaskintegration` worker/App Server/container/worktree bridge.
- `bus-api`: review `internal/backends/module_backends_task.go`,
  `internal/backends/module_backends_task_test.go`,
  `internal/server/server_test.go`, and
  `tests/e2e/068-task-provider-mount.sh`.
- `bus-integration-worker`: review `AGENTS.md` and `PLAN.md` only if the
  guidance-only handoff edits are accepted as part of this slice.

When reviewing, include both tracked diffs and untracked additions from
`git ls-files --others --exclude-standard`; the new source and e2e files in
this slice are intentionally not visible in plain `git diff --name-status`
until staged.

Current untracked additions to include in review:

- `bus-task`: `tests/live-events-e2e.sh`.
- `bus-api-provider-task`: `pkg/tasksapi/metadata.go`,
  `pkg/tasksapi/tasks.go`, `pkg/tasksapi/tasks_test.go`, and `tests/e2e.sh`.
- `bus-integration-task`: `pkg/taskintegration/taskintegration.go` and
  `pkg/taskintegration/taskintegration_test.go`.
- `bus-api`: `internal/backends/module_backends_task.go`,
  `internal/backends/module_backends_task_test.go`, and
  `tests/e2e/068-task-provider-mount.sh`.

Reviewers can refresh the current proof from the supervisor checkout with:

```sh
cd worktrees/task-bidi/bus-task && make check
cd ../bus-api-provider-task && make check
cd ../bus-integration-task && make check
cd ../bus-api && make test && make lint && bash tests/e2e/068-task-provider-mount.sh
cd ../bus-task && bash tests/live-events-e2e.sh
cd ../../../projects/busdk/docs/docs && bus lint goals/tasks.md
```

## Operator Decision Needed

The isolated implementation slice is ready for operator review. The next
decision is one of:

- accept the slice and run the promotion checklist below;
- request revisions in one or more listed worktrees, keeping the goal active;
- reject the slice and leave the primary checkouts unchanged.

Until that decision is made, keep the work unmerged and unpromoted.

## Promotion Checklist After Operator Confirmation

Use this sequence only after review accepts the isolated worktree diffs:

1. Re-run the focused proof commands listed in the acceptance audit, including
   `make check` in the three task-owned modules, `make test` and `make lint`
   in `bus-api`, the `bus-api` task provider e2e, and the live Events task
   e2e.
2. Commit owning module work first:
   `bus-task`, `bus-api-provider-task`, `bus-integration-task`, and `bus-api`.
   Commit `bus-integration-worker` only if its guidance-only edits are still
   part of the accepted slice.
3. Confirm no `bus-events` commit is needed for this slice; it is a detached
   dependency worktree used for module replacement resolution only.
4. Update the BusDK superproject submodule pointers for the accepted module
   commits and commit the `docs/docs/goals/tasks.md` goal update in the docs
   module.
5. Update the supervisor repository pointer for `projects/busdk` and keep the
   supervisor memo/log changes with the supervision commit, not with product
   modules.

## Acceptance Criteria

This goal is accepted when:

- `bus-task` is the stable generic task/thread CLI;
- task creation, messaging, closing, listing, replay, and follow behavior are
  tested through user-facing paths;
- the API provider exposes the first stable task read/mutation controller
  surface without executing work;
- task projection can reconstruct thread messages and thread status from
  canonical Bus Events;
- old `bus dev task`, `bus dev work`, `bus.dev.task.*`, and `bus.work.*`
  primary references are audited, removed, or marked as compatibility;
- `bus-integration-task` is slimmed to task-thread replay/follow semantics;
- focused unit tests cover the task state machine, output contracts, help
  routing, projection behavior, and compatibility decisions;
- integration/e2e proof covers the accepted slices, including the current
  `bus-task/tests/live-events-e2e.sh` cross-module proof against a real
  `bus-api-provider-events` memory backend.

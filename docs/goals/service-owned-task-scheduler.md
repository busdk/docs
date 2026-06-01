# Service-Owned Task Scheduler Handoff

## Goal

This conversation thread defined the plan for a service-owned task scheduler
for remote Bus development workers.

The requested end state is:

- A long-lived service consumes queued `bus.dev.task.*` work.
- The service starts Codex App Server workers up to configured capacity.
- The service avoids replaying stale claims as live work.
- The service exposes current queue, worker, capacity, stale-claim,
  launch-pending, and drain status.
- `bus-dev` remains an operator/client surface. It should display scheduler
  status and submit/request work, but it should not own the scheduler loop.

This handoff exists so a later conversation can resume implementation from the
same architecture and planning state without relying on chat history.

## Operator Direction Captured

The operator asked for a plan and goal around:

> Service-owned task scheduler for remote workers: A service consumes queued
> bus dev task work, starts App Server workers up to configured capacity, avoids
> replaying stale claims, and exposes current queue/worker status.

The operator also provided strict completion guidance: work should be verified
against the actual current repository state, not against memory or partial
progress. The plan should preserve the original scope instead of redefining
success around a smaller implementation slice.

The conversation established that the relevant planning boundary is split
between two modules:

- `bus-integration-dev-task` owns the scheduler service, worker-start event
  contract, replay safety, App Server worker launch semantics, and scheduler
  progress/health events.
- `bus-dev` owns the developer/operator UX that submits tasks, displays
  status, and consumes scheduler snapshots without becoming the scheduler.

## Current Evidence Inspected

The repository already had related implementation and plan history before this
handoff:

- `bus-integration-dev-task/pkg/devtaskintegration/supervisor.go` contains a
  bounded supervisor loop, monitor snapshot types, capacity-based refill logic,
  worker-start request publishing, stale-worker health events, preflight hooks,
  and self-check events.
- `bus-integration-dev-task/README.md` documents `--supervisor`, monitor/refill
  behavior, `bus.dev.work.worker.start.request`, App Server worker policy, and
  status expectations.
- `bus-integration-dev-task/PLAN.md` already had a closed item named "Repair
  the queued App Server scheduler/service slice and worker supervisor-review
  findings for `busdk#85.1`". That item made queued monitor observations
  launchable and added worker-start request behavior, but it did not complete
  the new service-owned scheduler architecture.
- `bus-dev/PLAN.md` already had active and closed work for remote Events sync,
  direct Events API bootstrap, task status/monitor surfaces, remote worker
  routing, and multi-remote stats.
- `bus-dev/AGENTS.md` already says `bus dev work status`, `task monitor`, and
  related supervisor surfaces must distinguish queued, request-only,
  launched-only, claimed/running, stale, false-active, and terminal states.

The key gap found in the current state is ownership and replay semantics:
existing code can request worker starts from bounded monitor snapshots, but the
target architecture is a service that owns replay, queue projection, scheduling
decisions, capacity, worker launch requests, stale-claim handling, pause/drain,
and scheduler status publication.

## What Changed

Two planning entries were added.

### `bus-integration-dev-task/PLAN.md`

Added an active item:

`Build a service-owned task scheduler for remote App Server workers.`

That item defines the service-side target:

- Replay task lifecycle events into an event-sourced queue projection.
- Treat `bus.dev.task.created` and `bus.dev.task.reopened` as queue inputs only
  when recipient, remote, write-scope, and terminal-state policy allows it.
- Start workers through the existing `bus.dev.work.worker.start.request`
  contract with exact `work_ref`, recipient, write scopes, agent backend,
  remote metadata, credential source labels, and expected-ref environment.
- Enforce global, remote, and per-recipient capacity.
- Count only fresh launch-pending, claimed, and running attempts against
  capacity.
- Support pause/drain.
- Model stale claims explicitly instead of allowing old claims to hide queued
  work or block capacity forever.
- Publish scheduler progress/health events and expose a script-friendly status
  projection.
- Verify FIFO/fair selection, capacity, pause/drain, launch binding, terminal
  exclusion, launch-pending accounting, stale-claim requeue eligibility, replay
  after service restart, orphaned worker-start requests, canceled queued tasks,
  reopened tasks, stale inherited environment tokens, and fixture/e2e smoke.

### `bus-dev/PLAN.md`

Added an active item:

`Consume service-owned dev-task scheduler status in bus dev work.`

That item defines the client/status target:

- `bus dev work status`, `task monitor`, and related views should render
  scheduler-owned status instead of inferring remote-worker reality from
  one-off controller commands or raw Events alone.
- Status snapshots should include queued work by recipient, active and
  launch-pending workers, per-work-ref attempt id and worker id, last progress
  time, freshness deadline, stale or false-active reason, next scheduler
  action, remote id/kind, sync route, and non-secret credential source labels.
- `bus-dev` may submit tasks, request status, and display diagnostics, but must
  not become the scheduler loop, capacity owner, worker lease database, SSH
  relay owner, or stale-claim reaper.
- Bootstrap compatibility can remain, but status should identify whether data
  came from the scheduler service or compatibility replay.

## Files Touched So Far

Relevant files touched in this goal thread:

- `bus-integration-dev-task/PLAN.md`
- `bus-dev/PLAN.md`
- `docs/goals/service-owned-task-scheduler.md`

There was existing dirty repository state outside this goal. Do not assume all
dirty state belongs to this handoff.

Observed from the superproject during the thread:

```text
M  .gitmodules
AM agents/supervisor
?? docs
 m logs
```

Observed inside module checkouts after the plan edits:

```text
bus-integration-dev-task: M PLAN.md
bus-dev:                  M PLAN.md
docs:                     ?? docs/goals/
```

The `docs` checkout showed `docs/goals/` as untracked from its own Git view
before this new handoff file was added. The next thread should inspect current
state before staging or committing.

## Verification Already Run

For the planning edits in `bus-integration-dev-task` and `bus-dev`:

```bash
git diff --check
bus lint PLAN.md
```

Both checks passed in both module directories.

From the docs repository checkout, this handoff file should still be checked
after creation with:

```bash
git diff --check -- docs/goals/service-owned-task-scheduler.md
bus lint docs/goals/service-owned-task-scheduler.md
```

## Important Design Decisions

The scheduler service must be event-sourced. Task Events remain the source of
truth; the service may keep projections and status snapshots, but it must not
replace the ledger with a separate mutable task database.

The scheduler owns capacity. `bus-dev` should not infer capacity from local
commands, raw container ids, SSH-runner requests, or stale worker claims.

Stale claims are first-class state. A replayed `claimed` or `running` event is
live only when it belongs to the newest non-terminal attempt and has recent
worker progress, heartbeat, or launch evidence within the configured freshness
window.

Worker launch must be exact-ref bound. The scheduler path must not start a
worker that can claim an arbitrary neighboring same-recipient task. Launch
requests need exact `work_ref`, recipient, write scopes, attempt identity, and
expected-ref environment.

App Server startup must fail closed. Before starting a model turn, the worker
must recheck latest replayed status for its exact expected work ref and refuse
terminal, canceled, stale, or unrelated tasks.

Status must distinguish operational states precisely. Important states include
queued, launch-pending, request-only, launched-only, claimed/running with real
worker progress, stale, false-active, terminal, and drain-blocked.

Credentials remain source-labeled and non-secret. Scheduler and status events
should report credential source labels and last auth errors without exposing
token values.

Pause/drain is part of the scheduler contract. Draining should stop new claims
while letting active attempts finish or time out with reviewable evidence.

## Current State At Handoff

The planning goal is complete. The repository now has explicit active PLAN
items describing the service-owned scheduler target and the `bus-dev` status
consumer boundary.

The implementation is not complete. The next thread should not mark the
product goal done until code, tests, status output, and at least fixture/e2e
proof satisfy the requirements in the PLAN entries.

## Deferred From Accepted Workers MVP

The accepted local sandboxed Codex workers MVP deliberately does not require
workers to auto-pick tasks. It proves that an operator can create a long-running
local `direct` / `codex-direct` Spark worker, guide it through
`bus workers message`, observe responses/status/logs/attach evidence, and stop
it.

The next scheduler-owned worker work belongs here, not in the
[workers goal](/docs/goals/workers.md):

- idle worker task-picking;
- atomic task claim and reopen behavior before worker creation;
- queue and capacity ownership across workers;
- scheduler-owned status for launch-pending, claimed, running, stale, and
  terminal work;
- a long-running service loop that starts or assigns workers without relying on
  one-shot test commands.

The highest-risk implementation areas are:

- Correct replay projection for task lifecycle events.
- Freshness and stale-claim semantics after service restart.
- Exact work-ref binding across scheduler, worker-start request, worker claim,
  and App Server startup.
- Capacity accounting that does not count orphaned requests or stale claims
  forever.
- Status snapshots that are strong enough for `bus-dev` to display without
  making `bus-dev` the scheduler owner.
- Credential source boundaries, especially avoiding inherited stale
  `BUS_API_TOKEN` behavior.

## Next Thread Should Do First

Start by reading:

1. `docs/goals/service-owned-task-scheduler.md`
2. `bus-integration-dev-task/PLAN.md`, especially the active scheduler item
3. `bus-dev/PLAN.md`, especially the active scheduler-status item
4. `bus-integration-dev-task/pkg/devtaskintegration/supervisor.go`
5. `bus-integration-dev-task/README.md`, especially "Dev-Work Supervisor"
6. `bus-dev/AGENTS.md`, especially `work` and `task` status requirements

Then inspect current state:

```bash
git status --short
git -C bus-integration-dev-task status --short
git -C bus-dev status --short
git -C docs status --short
```

Then verify the handoff itself:

```bash
git -C docs diff --check -- docs/goals/service-owned-task-scheduler.md
(cd docs && bus lint docs/goals/service-owned-task-scheduler.md)
```

The first implementation slice should be small but aligned with the real end
state:

1. Add scheduler projection types and tests in
   `bus-integration-dev-task/pkg/devtaskintegration`.
2. Model task state, attempt freshness, launch-pending, stale claims, and
   capacity decisions in memory from replayed Events.
3. Add tests before wiring command/service entrypoints, so the replay and
   stale-claim invariants are pinned down.
4. Then wire the service loop and status event/snapshot output.
5. Finally update `bus-dev` to consume scheduler snapshots with compatibility
   fallback.

## Suggested Concrete Requirements

Use these as the initial implementation checklist:

- Scheduler config includes environment id, remote id/kind, recipients,
  capacity limits, freshness windows, pause/drain mode, credential source
  labels, and launch backend policy.
- Queue projection consumes created, reopened, claimed, progress/running,
  worker-start-request, terminal, canceled, supervisor health, and scheduler
  progress events as needed.
- Queue projection emits current work rows with state, work ref, recipient,
  write scopes, attempt id, worker id, launch request id, last progress time,
  freshness deadline, stale reason, and next scheduler action.
- Scheduler chooses launchable queued work up to capacity, excluding terminal,
  canceled, stale-without-requeue, already launch-pending, and active fresh
  attempts.
- Scheduler publishes exact-ref worker-start requests with enough metadata for
  the worker to fail closed before App Server startup.
- Worker startup validates expected work ref against latest replay before
  starting Codex App Server.
- Status JSON/text surfaces queue depth, active count, launch-pending count,
  capacity, stale count, drain state, last auth/launch/claim error, remote
  metadata, and credential source labels.
- Tests prove stale claims from old disposable workers do not suppress new
  work, consume capacity forever, or cause a worker to claim the wrong task.

## Open Questions

The exact scheduler command name and flags are not settled. The likely home is
`bus-integration-dev-task`, but the next thread should inspect command metadata
and existing service flags before naming the entrypoint.

The exact Events names for scheduler status snapshots may need to be chosen.
Existing nearby events include `bus.dev.work.supervisor.progress`,
`bus.dev.work.supervisor.health`, and `bus.dev.work.worker.start.request`.
Prefer extending the module-owned event surface coherently instead of inventing
parallel names without checking current conventions.

The integration point for `bus-dev` status snapshots is still open. Preserve
existing monitor/status compatibility while adding scheduler-owned source
diagnostics.

The live remote proof may require prepared Events APIs, token files, and remote
worker hosts. Fixture tests should come first; live proofs should remain
operator-gated when they require external infrastructure.

No commit was requested in this thread. Do not stage or commit without an
explicit operator request, and do not mix this handoff with unrelated dirty
state.

# Service-Owned Events Relay Handoff

## Goal

This goal is to make Events synchronization between local and remote BusDK
development systems a normal service-owned capability.

The intended end state is that local-to-remote development work does not depend
on a supervisor manually running `bus events export`, `bus events import`,
SSH sync scripts, or `bus task --sync-now` as the daily path. A configured
environment such as local Docker, dev-hg, H100, or an UpCloud-style worker host
should run a bounded Events relay service with durable checkpoints. That relay
forwards target-marked local task and Notes operation events to the remote
Events API, imports remote-originated claim, progress, terminal, and lifecycle
evidence back, and reports status clearly enough that `bus task` and a
supervisor can trust the route.

The operator clarified that this is high priority. Treat it as a gating
dependency for a trustworthy remote worker lane, not as medium-priority
transport cleanup.

## Why This Exists

The current remote-worker path has proved several important pieces: task Events
can be synced, remote workers can run useful work, H100/local-model workers can
produce evidence, and `bus-events` already has local/testable relay machinery.
The weak point is ownership of the sync loop. If a supervisor has to remember
which import/export or SSH sync command to run, the system is still not a
normal worker lane.

The immediate product problem is that local-issued work should reach the remote
Events service before a worker starts, and remote claim/progress/terminal
evidence should come back without manual intervention. The broader product
problem is that every later remote-worker feature depends on this route being
observable, restartable, and bounded. Scheduler capacity, credential-source
selection, systemd user deployment, durable task evidence, artifact transfer,
remote freshness, and live worker review all become unreliable if Events relay
is still a manual bridge.

## Current Baseline

`bus-events` already contains completed building blocks:

- bounded bidirectional sync for task routing
- export/import event envelopes
- origin environment and origin system metadata
- per-destination sync state
- duplicate handling and idempotent imports
- cursor state via `--state-file`
- a `bus events relay` command with bounded iteration or loop/service mode
- text/JSON status with forwarded/imported/skipped/pending counters and last
  error
- regression coverage for restart cursor resume and token non-leakage

The relevant completed item is in `bus-events/PLAN.md`:

```text
Promote Events sync from a CLI/bootstrap helper into an environment-local relay
service.
```

That item is only a local/testable slice. It explicitly says that the work did
not contact live H100 or dev-hg endpoints. The next thread should not treat the
checked item as full product completion.

The root tracker now has a high-priority section:

```text
High-Priority Service-Owned Events Relay Goal
```

The owning module tracker now has an unchecked item:

```text
Deploy service-owned Events relay for live remote worker routes end to end.
```

Use current Git state as authoritative before continuing, because these plan
files were edited during an active dirty worktree.

## Current Naming And Dependencies

Review on 2026-05-30 found that this goal was partly written against the older
`bus dev task` / `bus dev work` transition state. The current implementations
make `bus-task` the generic task/thread CLI owner, and `bus-dev` now tombstones
`bus dev task` and `bus dev work` in favor of `bus task`. Future implementation
work should use `bus task` and `bus.task.*` as the primary operator and event
surface unless a current plan explicitly requires legacy compatibility.

`bus-integration-task` is the current worker integration module. Do not use the
historical `bus-integration-dev-task` name for new work.

The `bus-events` relay implementation has also moved beyond a bare local test
command. Current source includes relay config-file parsing, source/destination
credential-source labels, route ids, durable state files, route locks, bounded
once/loop modes, and text/JSON relay status. The open work is service
deployment, route configuration from environment metadata, status consumption by
the current task surface, and live dev-hg/H100 proof.

Dependency: the `bus-events` service route/config/status work can proceed
first, but this goal cannot be fully accepted until the generic `bus task` state
machine and CLI contract is accepted enough for remote start/status/stats proof,
and until the remote worker scheduler/worker service can consume the relayed
`bus.task.*` stream and publish claim/progress/terminal evidence. Those are
tracked in the neighboring `bus-task` and `service-owned-task-scheduler` goals.

## Required Behavior

The normal remote task path should look like this from the operator's point of
view:

```bash
bus task start --environment h100-weekend @bus-module "Do real product work"
bus task status
bus task stats --all
```

The operator should not have to run a separate import/export loop. The relay
service should already be moving eligible events between the local/controller
Events API and the selected remote Events API.

The service should handle these flows:

- local task creation events move to the remote Events API
- remote worker claim/running/progress/terminal events move back locally
- approval, guidance, and task message events move to the environment that owns
  the active worker
- worker lifecycle and scheduler evidence moves back locally
- `bus.notes.*` operation and lifecycle events move through the same Events
  origin/cursor model once Notes-over-Events is enabled
- duplicate imports remain idempotent
- imported remote-origin events are not forwarded back to their origin
- restart resumes from durable checkpoints rather than replaying old unrelated
  history

## What Needs To Be Built

### Service Configuration

Define a deployable route configuration shape. Each route needs at least:

- local Events URL
- destination Events URL
- stable source environment id
- stable destination environment id
- origin system id when useful
- token-file or credential-source references for each side
- event filters
- durable state-file path
- iteration bounds
- retry/backoff policy
- lock or single-instance behavior

The configuration should come from `bus-remote` and environment metadata where
possible. Token values must not be embedded in route config, task Events, logs,
or command output.

### Service Ownership

Run the relay through the normal service surface for each worker environment.
Acceptable service owners include a user-level systemd unit, a Compose service,
or a combined Bus integration/runtime host when that service shape is ready.
Manual one-shot commands should remain available only for deterministic tests,
bootstrap, and recovery.

The service must fail clearly when route configuration is incomplete. It should
name missing endpoint, state-file, credential-source, or environment-id fields
without exposing secret values.

### Relay Health And Status

Expose script-friendly JSON and human text status with:

- current local and remote cursors
- last successful iteration time
- last attempted iteration time
- forwarded/imported/skipped/pending counters
- pending truncation evidence
- source and destination environment ids
- credential-source labels
- state-file path
- route id
- service mode or loop mode
- last error
- whether another relay instance owns the route lock

`bus-task` should use this relay status in normal remote status/start flows. A
route with missing or stale relay checkpoints should be visible before work is
dispatched or before a worker is trusted as active.

### Replay And Loop Safety

A normal relay run must not replay thousands of old unrelated task Events.
Persisted cursors and target-state filtering should bound work after the first
successful iteration. If the relay reports pending counts from a bounded sample
rather than a full replay, status must say so explicitly.

The relay must preserve origin metadata and avoid loops. Events imported from a
remote environment must not be forwarded back to that same environment as new
local work. Duplicate delivery should remain safe and idempotent.

### Service Restart Semantics

Stopping and restarting the relay should resume from its durable state file.
The restart path should prove:

- no cursor loss
- no broad full-history replay
- no duplicate task claim or stale task resurrection
- status reports the same route identity before and after restart
- failure states are recoverable without manually editing the state file

### Live Proof

A live proof is required before calling this complete. The proof should use
dev-hg or H100 when available:

1. Confirm local and remote Events endpoints and token-file references.
2. Start or verify the relay service.
3. Create a local task targeted at the remote environment.
4. Observe the relay forward the task event.
5. Observe the remote worker claim and publish progress.
6. Observe the relay import claim/progress/terminal evidence.
7. Restart the relay service.
8. Repeat or continue without replaying unrelated history.
9. Confirm `bus task status` and `bus task stats --all` show the remote
   identity and terminal result locally.

The proof should record task ref, route id, local and remote environment ids,
state-file path, before/after cursors, forwarded/imported/skipped/pending
counters, terminal status, and any manual intervention. If manual intervention
is needed, record it as an implementation defect rather than treating the proof
as complete.

## Related Goals Discussed In This Thread

### Accepted Local Workers MVP

`docs/docs/goals/workers.md` is accepted only for local native Services plus
local sandboxed Codex Spark workers. It does not complete remote worker
operation. Any unfinished work where worker create/control/message/status
Events must cross environment boundaries belongs to this relay goal and the
multi-environment coordination goal, not to the accepted local workers MVP.

### Service-Owned Task Scheduler

A remote worker environment also needs a service-owned scheduler that consumes
queued task work and starts App Server workers up to configured capacity. This
is separate from Events relay, but relay is the prerequisite that lets tasks
arrive and evidence return without manual sync.

The scheduler should avoid stale replay claims, bind launches to the intended
task ref, expose queue/worker status, and fail with task-stream evidence when a
worker cannot start.

### Remote Credential Source Selection

Controller credentials, remote Events credentials, and worker runtime
credentials must come from explicit config or token files. A stale
process-global `BUS_API_TOKEN` must not control normal remote behavior. Relay
routes should carry source labels and token-file references only, never token
values.

### Systemd User Deployment

The relay service should fit the same deployment model as the rest of the Bus
infrastructure. A local or remote worker environment should be able to start
Events, integration handlers, provider handlers, and relay as one or a few user
services. Docker or Podman should remain worker/container runtime dependency,
not the primary Bus control-plane host by default.

### Durable Task And Notes Evidence

Normal development services must use durable Events storage. Memory-backed
Events services are acceptable for tests, self-tests, or intentionally
disposable smokes only. If a memory-backed service must be restarted during a
bootstrap path, visible task Events should be exported first.

Worker Notes should use the platform architecture. Notes API mutations should
append or consume `bus.notes.*` Events, relay should move those Events with the
same origin/cursor machinery, and the Notes projection should materialize into
durable BusData/Postgres or repository-file storage. Do not add a separate
Notes replication layer.

### First-Class Task Artifact Transfer

Task attachment support already has bounded small-file attachment and
extraction primitives for patches, logs, and evidence files. Remote review
should use task attachments rather than `scp` or shared filesystem paths. The
relay path must move those task Events reliably so attached evidence is
available locally.

### Trustworthy Remote Worker Lane

The full worker lane is not trustworthy until the relay, scheduler,
credentials, service deployment, durable evidence, artifact transfer, remote
freshness, and App Server worker backend all work together. A remote task should
be issued locally, run remotely, return evidence, and be reviewed locally
without environment-specific correction.

### Remote Freshness Command

Remote worker environments need a freshness command that updates root and
submodule pins, builds or installs changed tools, rebuilds or reloads worker
images only when needed, and records source, tool, and image identity. Relay
service deployment should be part of that readiness/freshness story so a stale
remote does not appear ready.

## Acceptance Criteria

This goal is complete only when all of these are true:

- `bus-events` owns an unchecked-to-checked implementation item for deployed
  service-owned relay, not only local command support.
- Relay route config is explicit, non-secret, and driven by remote/environment
  metadata where possible.
- Relay can run as a bounded service or service-owned loop for at least one
  local-to-remote route.
- Relay status exposes cursors, counters, route ids, last success/error, and
  credential-source labels.
- Restart resumes from persisted cursors without broad replay.
- Duplicate imports and remote-origin loop prevention are covered by tests.
- Token values are absent from relay output, state summaries, and forwarded
  event payloads.
- The current `bus task` remote status/start paths can consume relay status
  instead of requiring `--sync-now` as the primary operator path.
- A live dev-hg or H100 proof shows local task creation, service relay to
  remote, remote worker evidence, relay back to local, and local status/stats
  without manual import/export.
- Any remaining manual SSH sync, import/export, or `--sync-now` usage is
  documented as bootstrap/recovery only.

## Files To Read First

Start with these files:

1. `PLAN.md`
2. `bus-events/PLAN.md`
3. `bus-events/internal/cli/sync.go`
4. `bus-events/internal/cli/cli.go`
5. `bus-events/README.md`
6. `bus-events/internal/cli/relay_config.go`
7. `bus-task/PLAN.md`
8. `bus-task/run/sync.go`
9. `bus-integration-task/PLAN.md`
10. `bus-remote/PLAN.md`
11. `bus-operator-deploy/PLAN.md`
12. `bus-dev/PLAN.md`
13. `logs/20260527-17-agent-memo.md`
14. `logs/20260529-14-agent-memo.md`

Use the current worktree and current remote state as authoritative. The memo
files are supporting context, not proof by themselves.

## Suggested First Commands

Run these commands from the BusDK superproject root. Inspect the current plan
and dirty state:

```bash
git status --short
git -C bus-events status --short
git -C bus-task status --short
rg -n "High-Priority Service-Owned Events Relay Goal|Deploy service-owned Events relay|bus events relay|--sync-now|state-file" PLAN.md bus-events/PLAN.md bus-events bus-task
```

Inspect the current relay command and tests:

```bash
make -C bus-events build
go -C bus-events test ./...
bus-events/bin/bus-events --help
bus-events/bin/bus-events relay --help
```

If only this handoff file is changed, run:

```bash
git -C docs diff --check -- docs/goals/service-owned-events-relay.md
bus lint docs/docs/goals/service-owned-events-relay.md
```

## Known Boundaries

Do not solve this by adding a new ad hoc SSH loop in `bus-task` or by reviving
`bus dev work` in `bus-dev`. Routine sync ownership belongs to
environment-local services or `bus-events` service mode.

Do not put token values in relay route config, state summaries, task Events,
Notes Events, logs, or command output.

Do not treat local relay command tests as sufficient proof. The currently
important missing evidence is service deployment, status integration, restart
resume, and a live dev-hg/H100-style route.

Do not build a separate Notes replication path. Notes movement should use
`bus.notes.*` Events and the same relay origin/cursor machinery.

Do not call a Docker container, a queued SSH request, or a stale process an
active worker lane unless task Events show claim/progress/terminal evidence or
a precise relay/scheduler failure.

## Current State At Handoff

The relay goal is defined and prioritized, but implementation remains open.

Root `PLAN.md` now contains a high-priority service-owned Events relay section.
`bus-events/PLAN.md` now contains an unchecked implementation item for deploying
service-owned relay for live remote worker routes. The existing `bus events
relay` local/testable command is useful starting point, but it has not been
proved as the normal live dev-hg/H100 service path.

The next useful thread should start by checking current Git state, reading the
root and `bus-events` plan items, and deciding whether the first implementation
step is completing route configuration/status in `bus-events`, service
installation in `bus-operator-deploy`, or `bus-task` consumption of relay
health. The safest sequence is usually: finish service route config/status and
loop safety in `bus-events`, prove restart/loop safety with fixtures, add
service wrapper/deploy support, then wire `bus-task` to prefer relay status over
`--sync-now` for normal remote status/start flows.

No commit was requested for this handoff. Avoid staging or committing until the
operator asks, and keep this docs handoff separate from unrelated dirty
submodule work.

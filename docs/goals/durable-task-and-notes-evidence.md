# Durable Task And Notes Evidence Handoff

## Goal

This conversation defined a durable evidence goal for BusDK development worker
systems:

Normal local, dev-hg, H100, and future remote development services must preserve
task and Notes evidence across restarts and remote sync. Visible
`bus.dev.task.*` Events must be exported before any memory-backed service
restart can discard them. Normal development services must use durable Events
storage, either PostgreSQL or an explicit repository-file-backed store. Worker
Notes must be written through `bus.notes.*` Events, moved by the Events
sync/relay path, projected into durable Notes storage, and queryable by module,
task, session, tag, source, and origin environment/system after remote sync.

The practical purpose is to make remote worker evidence trustworthy. A local
supervisor should be able to submit work, let remote services route and execute
it, restart services, and still recover the task stream, worker closeout,
patch/log artifacts, and worker Notes without manual shell archaeology.

## Conversation Scope

The discussion covered four related product threads that should remain aligned:

1. Service-owned task scheduler for remote workers.
2. Remote credential source selection.
3. User-level systemd deployment for Bus infrastructure.
4. Durable task and Notes evidence.

The durable evidence goal depends on the first three. Scheduler status is where
operators see what work is queued or running. Credential source selection keeps
local, remote, and worker tokens from being confused. User-systemd deployment is
where durable Events services, relay services, integration workers, and API
hosts should run without manual handler launches.

## Current Planning State

The root plan now contains a dedicated durable evidence section:

- `PLAN.md`: `Durable Task And Notes Evidence Goal`

That root section splits ownership across these modules:

- `bus-events`: durable Events backend and memory restart export guard.
- `bus-api`: normal service startup must use a configured durable EventBus
  instead of silently constructing memory storage.
- `bus-operator-deploy`: install/update/restart paths must detect memory-backed
  Events services and export or refuse before restart.
- `bus-api-provider-notes`: API mutations must route through `bus.notes.*`
  operation Events and expose query filters.
- `bus-integration-notes`: Notes projection workers must consume synced
  operation Events and materialize origin-aware durable indexes.
- `bus-notes`: CLI list/search must expose worker-evidence filters.

Related root plan sections also matter:

- `High-Priority Service-Owned Events Relay Goal`
- `Remote Credential Source Selection Goal`
- `Deterministic Task Evidence Goal`
- `Current Refined Finish Line`

Those sections describe the larger remote-worker lane: service-owned relay,
remote-safe credentials, deterministic worker attempt evidence, and a repeatable
H100/dev-hg offload loop.

## What Was Added During The Planning Pass

The planning pass added or confirmed these owner items:

- `bus-events/PLAN.md`: `Add a durable Events storage backend contract for
  normal development services.`
- `bus-events/PLAN.md`: `Add a memory-backed Events restart export guard.`
- `bus-api/PLAN.md`: `Require durable Events storage for normal API/service
  startup.`
- `bus-operator-deploy/PLAN.md`: `Add a memory-backed Events restart/export
  guard to service deployment.`
- `bus-api-provider-notes/PLAN.md`: `Expose Notes query filters needed for
  synced worker evidence.`
- `bus-integration-notes/PLAN.md`: `Materialize origin-aware Notes projections
  for remote worker evidence.`
- `bus-notes/PLAN.md`: `Add worker-evidence query filters to the bus notes CLI.`

The existing `bus-api-provider-notes` and `bus-integration-notes` open items are
also part of the same goal:

- Route Notes API mutations through the Bus Events operation contract instead
  of direct-only projection writes.
- Add the production Bus Notes projection worker path over Events instead of a
  Notes-specific replication mechanism.

## Requirement Breakdown

### Durable Events Storage

Normal worker systems must not depend on the process-local `InMemoryBus` for
task or Notes evidence. Memory mode is acceptable only for tests, self-tests,
or explicitly disposable smokes.

Required behavior:

- Provide a repository-file-backed or PostgreSQL-backed Events append log.
- Preserve replay, `after_id`, conditional append, work delivery, import,
  export, sync, and relay behavior.
- Report `events_storage=postgres|file|memory` and a non-secret storage identity
  in service startup/status.
- Refuse or hard-warn when a normal development service would start with memory
  storage.
- Prove durable replay after restart and conditional-append conflict behavior
  across reopen.

This belongs primarily to `bus-events`, with `bus-api` and deployment surfaces
consuming the storage contract.

### Memory Restart Export Guard

If an Events service is still memory-backed, restart/update/replace operations
must not discard visible evidence silently.

Required behavior:

- Detect memory-backed Events storage before service restart when possible.
- Export visible `bus.dev.task.*`, `bus.notes.*`, and bounded lifecycle Events
  before restart.
- Write JSONL plus a manifest containing endpoint, storage kind, source labels,
  event count, first and last event IDs, origin environment/system IDs seen,
  checksum, and an import command.
- Refuse restart if export fails, unless the operator gives an explicit discard
  decision such as `--discard-memory-events`.
- Never print token values. Do not put private note bodies into lifecycle Events
  or logs when they belong only in Notes storage.

This belongs to `bus-events` for the export surface and `bus-operator-deploy`
for install/update/restart integration.

### Notes Over Events

Notes must use the platform architecture instead of a separate Notes replication
layer.

Required behavior:

- Notes API create/update/delete/import/publish/unpublish/archive appends or
  publishes the corresponding `bus.notes.*` operation Event with stable
  idempotency and source metadata.
- The Notes API provider may keep a synchronous response path only when it uses
  the same operation Event and idempotency key.
- Events sync/relay moves Notes operation Events between local/dev-hg/H100 and
  other environments with origin metadata and cursors.
- `bus-integration-notes` consumes those operation Events and materializes the
  durable Notes projection.
- No separate Notes sync, cursor, origin, or replication system should be added.

This belongs primarily to `bus-api-provider-notes`, `bus-integration-notes`, and
`bus-events`.

### Queryable Worker Notes

Worker Notes need to be retrievable after remote sync without relying on vague
free-text search.

Required query dimensions:

- module
- task
- session
- tag
- source kind
- source ref
- origin environment id
- origin system id

The CLI should expose these filters on `bus notes list` and `bus notes search`.
The API provider should parse and pass them to the Notes service/projection
boundary. The projection stores should index them durably. Worker closeout
should report either concrete note IDs or a reproducible query, for example:

```text
module=bus-dev task=busdk#81.1 tag=agent-work-log origin_environment_id=h100
```

### Service-Owned Task Scheduler

The scheduler item is not the same as durable evidence, but it is part of the
same remote worker lane.

What still needs to exist:

- A service consumes queued `bus.dev.task.*` work.
- It launches Codex App Server workers up to configured capacity.
- It binds each launch to the intended task ref.
- It does not let stale claims, orphaned launch requests, or old terminal work
  consume capacity forever.
- It publishes queue, worker, capacity, stale-claim, launch-pending, drain, and
  next-action status.
- `bus-dev` consumes that status instead of becoming the scheduler loop.

Current planning anchor:

- `bus-integration-task/PLAN.md`: `Build a service-owned task scheduler for
  remote App Server workers.`
- `bus-dev/PLAN.md`: `Consume service-owned dev-task scheduler status in bus dev
  work.`

### Remote Credential Source Selection

Credential source selection is a required boundary for durable evidence because
sync, relay, worker runtime, and Notes/API services all need different token
contexts.

Required behavior:

- Controller credentials, remote Events credentials, and worker runtime
  credentials are selected separately.
- Explicit token files and configured remote credential sources are the normal
  path.
- Inherited `BUS_API_TOKEN` is only a compatibility fallback.
- Remote-only token-file references for ssh-docker must not be opened by the
  local controller.
- Expired, unreadable, unsupported, or missing credentials fail before expensive
  worker/model startup.
- Diagnostics name the selected remote id/kind and safe source label, never the
  token value.

Current planning anchor:

- `PLAN.md`: `Remote Credential Source Selection Goal`
- `bus-events/PLAN.md`: `Prove relay credential-source boundaries and
  diagnostics.`
- `bus-dev/PLAN.md`: `Prove controller credential-source selection across
  remote work commands.`

### User-Systemd Deployment

The normal readiness path should be one named user-systemd profile, not manual
launches for each handler.

Target service shape:

- `bus-events` service with durable storage.
- One combined `bus-integration` runtime for selected integration and
  provider-adjacent handlers.
- Optional `bus-api` runtime for selected API providers.
- Rootless Docker/Podman reported as a runtime dependency for worker/container
  execution, not as the default Bus control-plane host.
- Explicit config files and token-file or credential-source paths.
- No raw secret values or process-global `BUS_API_TOKEN` in unit files.

Current planning anchor:

- `bus-operator-deploy/PLAN.md`: `Add an administrator-configured
  single-runtime Bus service profile for user-level systemd hosts.`
- `bus-operator-deploy/PLAN.md`: `Add a memory-backed Events restart/export
  guard to service deployment.`
- `bus-api/PLAN.md`: `Productize administrator-selectable multi-provider API
  hosting end to end.`

## Minimum End-To-End Proof

The goal is not complete until an end-to-end proof covers the whole evidence
path.

Minimum acceptable proof:

1. Start local and remote Events services with durable storage.
2. Create a local development task.
3. Route it to a remote environment through service-owned Events relay.
4. Have the remote scheduler start a worker.
5. Have the worker publish task progress, terminal evidence, artifacts, and a
   Bus Note.
6. Sync remote-origin evidence back locally.
7. Restart the relevant Events and Notes services.
8. Query the task Events locally.
9. Query the worker Note locally by module, task, session, tag, source, and
   origin.
10. Confirm Events payloads, logs, and status do not expose token values or
    private note bodies.

Useful command surfaces for proof will likely include:

```bash
bus dev work --environment <env> start ...
bus dev work status --format json
bus dev work stats --all
bus events relay --state-file <path> ...
bus events export ...
bus events import ...
bus notes list --module <module> --task <task> --tag <tag> --origin-environment-id <id>
bus notes search --module <module> --task <task> <query>
bus operator deploy service user-systemd status ...
```

The exact command flags may change as implementation lands. The invariant is
the evidence path, not a specific provisional CLI shape.

## Suggested Implementation Order

Start with `bus-events`. Other modules need a storage/status contract before
they can safely decide whether restart is allowed.

1. Implement durable Events storage contract and status output in `bus-events`.
2. Implement the memory restart export guard in `bus-events`.
3. Wire `bus-api` normal service startup to require or inject durable Events
   storage for non-disposable development profiles.
4. Wire `bus-operator-deploy` restart/update paths to use the export guard.
5. Route Notes API mutations through `bus.notes.*` operation Events.
6. Run the concrete `bus-integration-notes` projection worker over Events.
7. Add origin-aware durable Notes indexes.
8. Add API and CLI filters for worker-evidence queries.
9. Connect the scheduler status and user-systemd service profile into the proof.
10. Run the local-to-remote restart proof.

## Current Git And State Notes

At the time this handoff was written, the superproject root reported unrelated
dirty state:

```text
M  .gitmodules
AM agents/supervisor
 ? docs
 m logs
```

Inside the docs submodule, `docs/goals/` was already untracked because
`docs/docs/goals/supervisor-identity-root.md` existed before this file was
created. Do not assume this handoff is the only docs change.

The current superproject commit inspected for this handoff was `7088b3c`.
Relevant submodule commits included:

- `bus-api`: `a5c5937`
- `bus-api-provider-notes`: `e8118d3`
- `bus-dev`: `1eb6e21`
- `bus-events`: `e8319d8`
- `bus-integration-notes`: `24624b0`
- `bus-integration-task`: `add791c`
- `bus-notes`: `0cac8ed`
- `bus-operator-deploy`: `7ec83a2`
- `docs`: `e3b12b0`
- `logs`: `8d58f54`

These hashes are evidence anchors, not a claim that the working tree was clean.

## Verification Already Done

During the earlier planning pass, `git diff --check` passed for the edited root
and module `PLAN.md` files plus the session memo.

For this handoff, run at minimum:

```bash
git -C docs diff --check -- docs/goals/durable-task-and-notes-evidence.md
bus lint docs/docs/goals/durable-task-and-notes-evidence.md
```

If the next thread edits implementation code, run the owning module checks from
that module's `AGENTS.md` and `PLAN.md`. Do not treat this handoff as proof that
implementation is complete.

## What Is Complete

The planning goal is complete. The repository now has a root goal definition and
module-owned plan slices for durable Events storage, memory restart export,
Notes-over-Events mutation routing, origin-aware projections, and CLI/API query
filters.

This handoff records the surrounding scheduler, credential, and systemd context
needed to resume the work in a new conversation thread.

## What Is Not Complete

No implementation is complete merely because the plan exists.

Open implementation work remains in:

- durable Events storage
- memory-backed restart/export guard
- service-owned Events relay deployment
- service-owned App Server task scheduler
- `bus-dev` scheduler-status consumption
- remote credential-source proof across controller, relay, and worker runtime
- user-systemd combined service profile
- Notes API operation Events
- concrete Notes projection worker over Events
- origin-aware Notes projections
- `bus notes` query filters
- end-to-end local-to-remote restart proof

## First Actions For The Next Thread

Start by reading:

1. `docs/docs/goals/durable-task-and-notes-evidence.md`
2. `PLAN.md`
3. `bus-events/PLAN.md`
4. `bus-api/PLAN.md`
5. `bus-operator-deploy/PLAN.md`
6. `bus-api-provider-notes/PLAN.md`
7. `bus-integration-notes/PLAN.md`
8. `bus-notes/PLAN.md`
9. `bus-integration-task/PLAN.md`
10. `bus-dev/PLAN.md`

Then inspect current state:

```bash
git status --short
git -C docs status --short
git -C bus-events status --short
git -C bus-api status --short
git -C bus-operator-deploy status --short
git -C bus-api-provider-notes status --short
git -C bus-integration-notes status --short
git -C bus-notes status --short
git -C bus-integration-task status --short
git -C bus-dev status --short
```

The most useful next implementation target is `bus-events`: define the durable
backend/status contract and the memory restart export guard. That gives the
other modules a concrete interface for safe startup, restart, relay, and proof.

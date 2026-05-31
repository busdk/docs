# Workers Goal

## Goal

Build the Bus worker product surface for creating and operating agent workers
with durable identity, state, assignment, and non-secret runtime metadata.

The target UX is `bus workers ...`. Workers should behave like a Bus-managed
runtime resource: listable, creatable, pausable, resumable, assignable, and
observable through the local API/controller service and local worker
integration service.

The first acceptance scope is local sandboxed Codex workers only. A Codex
worker runs through the `direct` / `codex-direct` runner on the selected local
worker environment, using Codex sandboxing, Bus-managed Git worktrees and
branches, isolated `CODEX_HOME`, logs, scratch paths, and non-secret runtime
metadata. Remote worker environments, cross-environment relay, container
runners, and VM runners are adjacent goals, not acceptance requirements for
this first workers goal.

The first proof model for Codex/App Server workers is the raw model id:

```text
gpt-5.3-codex-spark
```

Pass that value through exactly for the first proof. Model aliasing or
normalization is not part of the first acceptance path, but the model should
remain configurable so later worker profiles can select different Codex models.

## Module Boundary

The target module family is:

- `bus-workers`: user-facing product and plural CLI.
- `bus-api-provider-workers`: local API/controller provider mounted by
  `bus-api`.
- `bus-integration-workers`: local event/integration provider that manages
  worker lifecycle in the worker environment through runner providers.

The existing singular `bus-worker`, `bus-api-provider-worker`, and
`bus-integration-worker` checkouts are implementation scaffolds until they are
renamed, wrapped, or promoted into the plural product surface. Do not treat the
singular names as the final user-facing architecture.

Runner-provider implementations are below the `bus-integration-workers`
boundary. The worker product/API/Event contract must not need to change when a
new runner is added. The first known runner families are:

- direct Codex on the environment, with no virtualization;
- Codex inside a container, using Docker, Podman, or a future container API
  through `bus-integration-containers` where practical;
- Codex inside a VM later, without making VM concepts part of the core worker
  contract before that provider exists.

`bus-integration-workers` owns the stable worker-runner interface,
configuration selection, lifecycle state mapping, and redaction policy.
Runner-specific modules own provider mechanics such as container creation,
Podman/Docker flags, VM boot/session details, or host process launch details.
Task modules, `bus-worker`, and `bus-api-provider-workers` must not call those
runner-specific implementation details directly.

The extension rule is strict: after the first runner-provider interface is in
place, adding a new worker runner should mean registering a provider and
writing provider-owned tests, not refactoring the whole workers product or all
callers of the workers integration module. Public callers may request a
runner kind/provider and read non-secret status metadata, but they should not
learn provider-specific construction details.

The stable compatibility contract for callers of `bus-integration-workers` is
canonical worker requests in and canonical worker snapshots out. Current and
future callers should depend on create/control/list/status request structs,
Bus Event names, lifecycle phases, runner identity fields, and bounded
metadata, not on direct-runner worktree preparation, container flags, VM boot
settings, process command templates, or provider-specific filesystem layouts.
Provider-owned options should be selected through explicit `runner_kind`,
`runner_provider`, environment defaults, or provider configuration. If a new
runner needs more private setup data, that data belongs in the provider's
configuration adapter and capability metadata, not in every worker caller or
task scheduler integration.

## Affected Bus Modules

The product surfaces touched by this goal are plural: `bus-workers`,
`bus-api-provider-workers`, and `bus-integration-workers`. The current
checkout names remain singular scaffolds in several places:
`bus-worker`, `bus-api-provider-worker`, and `bus-integration-worker`.
Implementers may continue changing those checkouts while this goal is in
flight, but new product contracts, documentation, Events, and operator-facing
commands should use the plural worker surface.

Within those current checkouts, `bus-worker` owns the product CLI and worker
identity/status UX, `bus-api-provider-worker` owns the local API/controller
projection and canonical `bus.workers.*` request publication, and
`bus-integration-worker` owns worker-runner selection, provider dispatch,
lifecycle reconciliation, canonical status snapshots, and the first direct
Codex runner.

Supporting Bus modules are touched only through their boundaries:

- `bus-api` mounts the workers API provider but should not learn runner
  mechanics.
- `bus-events` and `bus-api-provider-events` carry the protected
  `bus.workers.*` Event namespace, ACLs, relayable payloads, and correlation
  behavior. The worker goal should use the generic Events sync/relay
  machinery that already carries arbitrary Event names, including
  `bus.workers.*`; it must not add worker-specific transport loops or make
  `bus-events` hardcode worker semantics.
- `bus-integration-containers` is the required boundary for a container-backed
  worker provider. Worker code may ask for container lifecycle through that
  boundary, but must not duplicate Docker or Podman policy. Concrete Docker
  and Podman behavior remains behind the container integration stack.
- `bus-vm` and `bus-api-provider-vm` are future VM-adjacent boundaries. This
  goal should leave room for a VM runner without making VM fields required in
  the first worker contract.
- `bus-repos`, `bus-integration-repos`, and the `agents/worker` repository own
  durable repository/worktree and worker-identity materialization that workers
  should reference instead of recreating as private policy.
- `bus-task`, `bus-api-provider-task`, and `bus-integration-task` own task UX,
  task Events, and scheduler/claim behavior. They may address a worker by the
  canonical workers contract, but should not import runner-provider mechanics.

## Current Status

This goal is partially implemented on isolated `codex/workers-direct` module
branches, but it is not accepted. The direct Codex runner path has local
provider, API, CLI, projection, and host-process evidence; container and VM
runners remain extension targets behind the same provider interface. The first
acceptance scope no longer includes remote worker-host proof or
multi-environment relay proof; those belong to the remote/relay goals.
Remaining acceptance for this goal depends on the local sandboxed Codex
product path and repos-owned worktree and identity materialization.

## Dependencies

The workers product can continue in parallel on API shape, projection tests,
and integration lifecycle planning, but this goal cannot be fully accepted
until these neighboring goals are complete enough to supply their local worker
contracts:

- `docs/goals/repos.md` must be accepted, or explicitly accepted for the
  worker-needed slice, before this goal can claim automatic isolated worktree
  and branch creation as product behavior.
- Explicit `bus workers assign` can be implemented and tested before idle
  claiming is complete. Task-side assignment remains owned by `bus-task`; both
  entry points should publish or route to the same `bus.workers.assign.request`
  contract when the target is a specific worker.

Idle worker task claiming, queue/capacity behavior, and scheduler-owned status
belong to `docs/goals/tasks.md` and
`docs/goals/service-owned-task-scheduler.md`. They may create or assign workers
through the same canonical worker contract later, but a service-owned
scheduler/task-claiming loop is not an acceptance requirement for the initial
local sandboxed Codex worker product.

Remote worker hosts, service-owned Events relay, multi-environment worker
reads, and remote credential-source proof are tracked by
`docs/goals/service-owned-events-relay.md`,
`docs/goals/multi-environment-task-worker-refactor.md`, and
`docs/goals/remote-credential-source-selection.md`. Those goals may reuse the
workers Event contract, but they are not blockers for accepting the local
sandboxed Codex worker product path.
When remote support is added, the local environment must not directly start a
worker process in another environment. The expected remote model is Event
routing: a local provider publishes canonical worker request Events, relay
moves them to the destination environment, and that destination environment's
own `bus-integration-workers` service creates, controls, observes, and reports
its workers.
Container runners likewise depend on `bus-integration-containers` or an
equivalent stable container lifecycle boundary before a container provider can
be accepted; that is not part of the first local sandboxed Codex acceptance
scope.

## Required Behavior

`bus workers list` should list all visible workers and include enough
information for a supervisor to understand where each worker lives and what it
is doing. In the first local sandboxed Codex scope, list responses must
preserve the reporting worker environment id; multi-environment response
merging belongs to the remote/relay goals.

The product should support:

- create a worker with identity, environment, model, module, branch/worktree
  target, worker identity home, runner provider, sandbox, and prompt/task
  metadata;
- pause, resume, and stop a worker;
- assign a worker to a task;
- show current status, active task, lifecycle phase, last non-secret error,
  App Server URL or logical endpoint, runner provider, and bounded lifecycle
  metadata;
- expose bidirectional communication for an operator to provide task details,
  guide the long-running Codex App Server worker, and observe enough
  non-secret response/status evidence to keep steering it after it starts;
- keep tokens, secrets, and private credential values out of Events,
  projections, status, logs, and docs.

Worker status and control state must not be stored in ad hoc local catalog
files. `--workers-file` in the current integration command is bootstrap input
for local development and preflight only. The accepted product source of truth
for worker identity, lifecycle state, assignment, and status should be either
the canonical `bus.workers.*` Event stream/projections or a database-backed
provider such as PostgreSQL. Git worktrees and branches are also authoritative
evidence for materialized repository state and can be used for reconciliation:
the worker branch, worktree path, current revision, dirty/locked indicators,
and implementation branch provenance can confirm or repair what the worker
record claims about repository materialization. Git should complement the
Events/database worker record rather than become the only control-plane
database for worker lifecycle, assignment, or status.

Each worker should get an isolated worktree and implementation branch
automatically. Repository and worktree policy should use the repos goal rather
than being duplicated in the worker integration service. The canonical
repository rules are in `docs/goals/repos.md`: create a worker-owned worktree
from the configured source repository, use a unique implementation branch per
worker/task assignment, report dirty/locked/active states conservatively, and
never reset or delete a worker worktree as part of normal lifecycle control.

## Worker Runner Providers

Worker runner providers are the runtime implementations that actually start and
control Codex/App Server. They are replaceable implementation details behind
`bus-integration-workers`, not separate product APIs that every caller needs to
understand.

The first accepted stable worker control surface must support the `direct`
runner kind. It should reserve the same canonical request/status fields for
later container and VM providers so those providers can be added without
changing worker callers:

- `direct`: run Codex directly on the selected environment with no Docker,
  Podman, VM, or nested virtualization. Isolation comes from the Bus-managed
  worktree and implementation branch, a worker-specific `CODEX_HOME`, logs and
  scratch directories, the configured Codex sandbox, and the host user's normal
  toolchain such as `git`, `go`, `make`, Bus binaries, and module-local test
  scripts. This is the preferred first runner for local macOS proof and for
  environments where virtualization is unavailable or unnecessary. The product
  worktree is the primary Codex workspace; worker identity, logs, and scratch
  paths are additional writable roots, and each live direct worker needs a
  deterministic non-conflicting local endpoint or session reference.
- `container`: future runner kind for Codex inside a container. The workers
  integration should
  delegate container mechanics to `bus-integration-containers` or a stable
  container integration interface instead of duplicating Docker or Podman
  policy. Image, container id, mount, network, and runtime-driver details are
  provider metadata, not required fields for all workers.
- `vm`: future runner kind for Codex running directly inside a VM. The current
  contract should leave room for it, but VM image, boot, snapshot, and
  connection details should not be required until a VM runner exists.

The create path should select a runner from explicit request fields or
environment defaults. The selection result should be visible as non-secret
status metadata such as `runner_kind` and `runner_provider`, but the rest of
the worker lifecycle should stay the same: create, pause, resume, assign, stop,
status, and list should work through the same `bus.workers.*` Events for every
runner.

Adding a new runner provider must not require refactoring `bus-worker`,
`bus-api-provider-workers`, `bus-task`, or external callers of the workers API.
The required extension point is inside `bus-integration-workers`: a runner
provider registry or equivalent interface that maps worker create/control
requests to provider-specific lifecycle operations, redacts provider output,
and converts provider-specific state back into the canonical worker status
view.

That registry should keep provider choice and provider execution separate.
Selection should use explicit `runner_kind` / `runner_provider` request fields
when present, otherwise the target environment's defaults. Execution should be
through a narrow provider interface with create, pause, resume, assign, stop,
status/list reconciliation, capability reporting, and redaction behavior. The
provider interface should take canonical worker requests and return canonical
worker snapshots; provider-private config such as container driver flags, VM
image refs, socket paths, or host process command templates should stay in
provider configuration and bounded metadata.

Provider implementations may live in `bus-integration-workers` when they are
small and direct, or delegate to another integration module when that module
owns the lower-level runtime. In particular, the container provider should
delegate container lifecycle mechanics to `bus-integration-containers` or a
stable container integration boundary, while the direct provider should own
host process/session launch and worker-local filesystem preparation. A later
VM provider should plug into the same registry without changing the worker
Event contract.

Provider acceptance is staged. The first accepted implementation should prove
`direct` / `codex-direct` through command-backed host execution and the normal
worker API/Event path. The same registry and status contract must already make
room for additional providers, but `container`, `docker`, `podman`, or `vm`
must not be reported as working merely because the request fields exist. Until
the owning provider is registered and tested, unsupported runner
kind/provider pairs should fail closed with a bounded lifecycle error and a
non-secret failure snapshot. The later container acceptance slice should add a
provider that delegates to `bus-integration-containers`; the later VM slice
should add its own provider behind the same interface.

## Event/API Path

The normal path is:

1. `bus workers ...` talks to local `bus-api`.
2. `bus-api` routes to `bus-api-provider-workers`.
3. The provider publishes canonical `bus.workers.*` Events and maintains a
   bounded local read projection.
4. The selected worker environment's `bus-integration-workers` consumes those
   Events. In the first scope this is local; later remote support should use
   Events relay so the destination environment's own integration service
   consumes the request.
5. That integration service creates, pauses, resumes, assigns, and observes
   worker runner instances.
6. The same integration service publishes `bus.workers.status.snapshot`,
   `bus.workers.list.response`, and task-related evidence back through Events.

The first interoperable event contract must align with the Bus Events envelope
that is already implemented. Correlation belongs in the message envelope as
`correlationId`, and source environment identity belongs in Events metadata,
normally `bus.origin.environment.id`, with `bus.environment.id` accepted only
as legacy/current compatibility. Do not add duplicate payload fields such as
`correlation_id` or `source_environment_id` unless a compatibility adapter is
explicitly documented.

The canonical worker payload identity field is `id`, matching the current
`bus-worker`, API-provider, and integration-provider code. If a future schema
wants `worker_id`, it must be introduced as an explicit migration or alias
rather than silently replacing `id`. The canonical status field is `status`,
not `state`, for the current product slice.

The first interoperable payload contract must include these names and fields:

- `bus.workers.create.request`: required string fields `id`, `label`, `type`,
  and `profile`; optional string fields `environment_id`, `model`, `module`,
  `branch`, `runner_kind`, `runner_provider`, `image`, `sandbox`,
  `prompt_file`, `prompt`, `worker_home_ref`, and `task_ref`; optional string
  arrays `capability_tags`, `eligible_environments`, and `group_ids`;
  optional object field `labels`.
  Allowed `type` values are `human`, `automaton`, and `agent`, matching the
  current `bus-worker` identity contract. `profile` is a non-secret
  operator/config-selected profile name with no whitespace, `@`, or `#`;
  examples include `default-agent` and `codex-spark`.
  `capability_tags`, `eligible_environments`, and `group_ids` are non-secret
  routing and selection hints, not credentials or policy grants. They must use
  the current `bus-worker` normalized identifier rules: lowercase ASCII
  letters, digits, `.`, and `-`, no blanks, deduplicated and sorted by the
  identity owner. `worker_home_ref` is an optional non-secret reference to the
  worker identity/home repository and must not contain whitespace or a secret
  path. These fields may influence runner selection and task routing, but they
  must not by themselves authorize access to secrets, repositories, or
  environments.
- `bus.workers.list.request`: envelope `correlationId` required for correlated
  responses; optional string field `environment_id`; optional string array
  `worker_ids` for narrowing a request.
- `bus.workers.pause.request` and `bus.workers.resume.request`: required
  string field `id`; optional string fields `environment_id` and `reason`.
- `bus.workers.stop.request`: required string field `id`; optional string
  fields `environment_id` and `reason`; optional boolean field
  `preserve_worktree`, defaulting to `true` for the first product slice. The
  current feature branch has local API, Event ACL, integration lifecycle, and
  CLI coverage for stop; first-scope stop acceptance depends on local
  product-path proof.
- `bus.workers.assign.request`: required string fields `id` and `task_ref`;
  optional string fields `environment_id`, `assignment_id`, and `reason`.
- `bus.workers.list.response`: envelope `correlationId` matching the request;
  required string field `environment_id`; required array field `workers`,
  where each entry uses the same non-secret worker view as
  `bus.workers.status.snapshot`.
- `bus.workers.status.snapshot`: required string fields `environment_id`,
  `id`, `status`, and `lifecycle_phase`; optional string fields `model`,
  `module`, `branch`, `active_task_ref`, `runner_kind`, `runner_provider`,
  `worker_home_ref`, `app_server_url`, `logical_endpoint`, `runtime_ref`,
  `container_id`, `worktree_ref`, `worktree_path`, `logs_ref`, `logs_path`,
  and `last_error`; optional object field `metadata` for bounded non-secret
  lifecycle details.
  `worktree_path` and `logs_path` are current bootstrap fields; `worktree_ref`
  and `logs_ref` are the preferred durable-reference direction once
  repos/artifact ownership is ready. `container_id` is only meaningful for
  container runners; non-container runners should use provider-neutral
  `runtime_ref` or bounded metadata. Direct-runner metadata should include
  `codex_home`, `scratch_path`, `sandbox`, `session_backend`, and
  `writable_roots` when available; because `metadata` is string-to-string,
  `writable_roots` is encoded as a comma-separated string until a later typed
  status field exists. Later remote proofs that use `bus-remote` environment
  configuration should carry non-secret provenance metadata such as
  `remote_id`, `remote_host`, `remote_user`, `events_url`, `worker_root`,
  `credential_source_kind`, and `credential_source_label`.
  Token-file paths and credential values are not valid worker status metadata.

Defaults: first-scope local worker reads and mutations should target one
selected local worker environment. The Event contract still leaves room for
later broadcast-safe list discovery, where multiple environments may answer
the same correlation id, but that behavior belongs to the remote/relay goals.
Single-worker status discovery uses `bus.workers.list.request` with
`worker_ids`, not a separate status request Event in the first contract.
Create, pause, resume, assign, and stop are lifecycle mutation requests and
must target exactly one selected environment through request payload, route
metadata, or an explicitly documented API-provider selection rule before the
Event is published.
`environment_id` on response/snapshot Events means the reporting environment.
Absent optional runner/runtime fields mean the integration provider uses the
selected environment's configured defaults.
The first worker contract reserves `direct` and `container` runner kinds, with
`vm` reserved for a later runner. Reservation is not the same as execution
support: an environment may accept only the providers it has registered, and
unsupported kind/provider pairs must fail closed rather than falling back to a
different runner. `runner_provider` is a non-secret provider id such as
`codex-direct`, `docker`, `podman`, or a later VM provider id. Redaction rule:
tokens, credential values, raw auth paths, private prompt contents, absolute
secret file paths, and unbounded command output must not appear in Events or
projections.
`prompt` is allowed only for bounded non-secret inline bootstrap text, no more
than 8 KiB, that is safe to store in Events. Private or long task prompts must
use a non-secret `prompt_file` source label or a later `prompt_ref` contract
resolved inside the worker environment, rather than embedding the prompt body
in the Event.
`labels` and `metadata` are string-to-string maps only. Keys must be lowercase
ASCII identifiers using letters, digits, `_`, `.`, or `-`, and values must be
non-secret UTF-8 strings no longer than 512 bytes each. A single event should
carry at most 32 label keys and 64 metadata keys. Later snapshots replace the
stored value for the same key and must not preserve a removed key unless the
projection owner explicitly documents tombstone behavior.

Allowed `status` values for the first product slice are `creating`, `running`,
`paused`, `stopping`, `stopped`, `failed`, and `unknown`. Allowed
`lifecycle_phase` values are `requested`, `prepared`, `starting`, `ready`,
`pausing`, `paused`, `resuming`, `assigning`, `stopping`, `stopped`, and
`failed`. A create request should eventually publish `running`/`ready` or
`failed`. Pause moves a running worker through `pausing` to `paused`. Resume
moves a paused worker through `resuming` to `running`/`ready`. Assign keeps the
worker running and changes `active_task_ref` when accepted. Stop moves any
non-terminal worker through `stopping` to `stopped`; the first slice preserves
the worktree unless an explicit later cleanup contract says otherwise.

Do not build a second hidden worker launcher. The first product lifecycle
should reuse the shape proven by the manual Spark worker launcher: worker-local
product worktree, implementation branch, worker identity branch/worktree,
editable `AGENTS.md`, durable memory, memo logs, logs directory,
`CODEX_HOME`, model, sandbox, and live control path. Reuse the shape, not a
hard-coded container assumption: direct-host, container, and future VM runners
should all flow through the same worker lifecycle interface.

## Runtime Scope

Worker runner instances running Codex/App Server are long-running runtime
instances, not one-shot commands, smoke scripts, or test-only launchers. A
local sandboxed Codex worker should keep a live App Server/session endpoint or
logical attach reference so an operator can guide it interactively while it
does real work in its isolated worktree. Runtime instances may later be
containerized or VM-hosted, but the first accepted runner is a direct host
process using this environment's Codex runtime and configured sandbox. The
workers product owns identity, control, assignment, state, lifecycle policy,
runner selection, and projection. Runtime/provider protocol details remain in
`bus-agent` and the App Server integration layer, while container mechanics
belong in `bus-integration-containers` or its stable container integration
surface.

Workers may be assigned explicitly through `bus workers assign <worker>
<task-ref>` when the operator is controlling a specific worker, or through
`bus task ...` when the operator is assigning from the task/thread side.
`bus-task` remains the owner of task/thread UX and task status. Both paths
should map to the same worker assignment event once they cross the API/Event
boundary. The first local sandboxed Codex worker version does not need workers
to auto-pick approved tasks. It does need bidirectional communication so the
operator or task-side UI can provide task details to the selected long-running
worker and receive enough response, status, logs, or attach evidence to keep
guiding it. Idle workers may claim an approved available task only after the
task and service-owned scheduler goals have accepted the canonical
claimability, queue, capacity, and scheduler-owned status contracts.

## Acceptance Criteria

This goal is accepted when:

- `bus workers` is the documented product CLI for worker identity and control;
- the local API provider publishes and projects canonical `bus.workers.*`
  requests/evidence;
- the integration provider consumes those Events and controls real local
  worker lifecycle through a runner-provider interface;
- the `direct` runner kind can be selected and executed through canonical
  request fields without changing the user-facing worker CLI, worker API
  provider, task modules, or event names;
- the worker contract leaves container runner behavior to
  `bus-integration-containers` or an equivalent stable container integration
  boundary when a later container goal accepts that provider, instead of
  duplicating hidden Docker/Podman logic inside worker callers;
- the design leaves a clear path for a later VM runner without making VM fields
  required in the first product slice;
- each created worker gets an isolated worktree and branch automatically;
- list/status reads preserve the local worker environment identity;
- pause/resume/assign/stop create observable state transitions;
- at least one local sandboxed Codex worker is created, controlled, observed,
  and stopped through the product path using `gpt-5.3-codex-spark`,
  `direct` / `codex-direct`, an isolated product worktree and branch,
  worker identity worktree, isolated `CODEX_HOME`, logs, scratch paths,
  bounded non-secret runtime metadata, Codex sandbox settings, and a live
  App Server/session endpoint or logical attach reference that can be used for
  bidirectional interactive guidance;
- focused unit tests cover API request shaping, projection merge behavior,
  integration request handling, runner selection, direct-runner lifecycle
  planning/execution, lifecycle execution errors, CLI encoding/decoding, and
  secret redaction;
- integration/e2e proof covers the full local product path for a real
  long-running sandboxed Codex worker, including CLI/API request publication,
  integration consumption, worker lifecycle execution, bidirectional guidance
  or attach evidence for task details and worker responses, status projection,
  stop, and non-secret evidence.

## Appendix: Implementation History

### 2026-05-31 Local Sandbox Scope Refinement

The first accepted workers goal was narrowed to local sandboxed Codex workers.
Remote worker hosts, cross-environment Events relay, remote credential-source
proof, container runners, and VM runners are adjacent goals rather than
acceptance requirements here.

The accepted worker must be a real long-running Codex App Server/runtime
instance using this environment's Codex runtime and sandbox, not a one-shot
command, smoke script, or unguidable test launcher. The first proof uses
`gpt-5.3-codex-spark` exactly, while keeping the model configurable for later
worker profiles.

The remote model was also corrected: later remote support should not make a
local environment directly start worker processes in another environment.
Instead, local worker APIs publish canonical `bus.workers.*` Events, relay
routes those Events to the destination environment, and that destination
environment's own `bus-integration-workers` service creates, controls,
observes, and reports its workers.

Service-owned scheduler/task claiming is also outside the first acceptance
unless it is explicitly reopened. The initial worker product must support
long-running workers that can be created, controlled, assigned, observed,
attached to, guided with task details, and stopped; automatic idle-task
claiming belongs to the task and scheduler goals.

### 2026-05-30 Review Notes

This file was reviewed against the neighboring goal files and the current
`bus-worker`, `bus-api-provider-worker`, `bus-integration-worker`, `bus-api`,
`bus-events`, `bus-task`, `bus-repos`, and `bus-agent` checkouts on
2026-05-30. No product implementation worktree or feature branch was created
for this review; the operator requested review-only work and allowed the goal
file itself to be updated in the main checkout.

The current code already has accepted bootstrap slices that should not be
rediscovered as absent:

- `bus-worker` provides the current singular implementation module and direct
  binary for local non-secret identity records and API-mode
  list/show/create/pause/resume/assign/status calls. The product CLI target in
  this goal remains plural: `bus workers ...`.
- `bus-api-provider-worker` builds the plural `bus-api-provider-workers`
  service, publishes canonical `bus.workers.*` request Events, listens to
  list/status response Events, and maintains memory or file-backed projections.
- `bus-api` can mount the workers provider through the `worker` or `workers`
  module alias when the module is enabled.
- `bus-integration-worker` builds the plural `bus-integration-workers`
  command, handles list/create/pause/resume/assign requests, publishes
  list/status responses, and has App Server plan/exec lifecycle scaffolding.
  That lifecycle scaffolding is currently too container-shaped in places and
  must be moved behind a runner-provider boundary instead of becoming the
  permanent worker architecture.

The remaining work is therefore contract normalization, durable/lived
projection behavior, real App Server lifecycle proof, repository/worktree
integration, runner-provider abstraction, stop support, and product hardening.

### 2026-05-31 Runner Provider Refinement

This goal was refined against
`docs/goals/manual-spark-worker-bootstrap.md` on 2026-05-31. The manual
bootstrap goal now deliberately targets host-run Codex workers with no Docker,
Podman, VM, or nested virtualization dependency. The product workers goal
should inherit that lifecycle shape for its first direct runner instead of
treating the older container/App Server bootstrap shape as canonical.

The manual bootstrap goal is not a required predecessor for this product goal:
it is a temporary acceleration and proof path. However, the product
implementation should reuse its accepted concepts so that operators do not
learn two unrelated worker models. In particular, the product lifecycle should
eventually create and report:

- a product/module worktree created from the reviewed BusDK module pin;
- a unique implementation branch for the worker or assignment;
- a worker identity branch and worktree created from the `agents/worker`
  repository;
- editable worker-local `AGENTS.md`, durable memory, and hourly memo logs
  under the worker identity worktree;
- worker-local logs, scratch, and isolated `CODEX_HOME` paths;
- explicit model and sandbox settings, with `gpt-5.3-codex-spark` passed
  through exactly for the first Codex proof;
- a non-secret runtime reference for the live process, session, container, or
  later VM;
- enough metadata for `status`, `logs`, `attach` or equivalent live guidance,
  and eventual stop/recovery flows without exposing secrets.

The first product runner provider should therefore be `direct`/`codex-direct`:
Codex runs directly on the selected environment with Bus-managed Git
worktrees, branches, worker identity checkout, `CODEX_HOME`, logs, scratch,
and sandbox boundaries. Container and VM providers must be additive
implementations behind the same runner-provider interface, not reasons to
reshape the user-facing worker contract.

The manual bootstrap work is useful proof, not a second source of truth. Its
accepted host-run shape should become the direct provider's lifecycle recipe,
while container and VM providers translate the same canonical worker lifecycle
into their own runtime mechanics.

The related manual-script implementation lane is branch
`codex/manual-go-worker-script`, with the session worktree recorded in the
supervisor memo as `worktrees/manual-go-worker-script/busdk` relative to the
supervisor checkout root. It primarily changes
`scripts/manual-dev-hg-spark-worker.sh`. That branch is not a prerequisite for
starting product worker work and must not be merged or promoted through this
goal. Treat it as implementation evidence for the direct runner shape:
`WORKER` maps to worker `id`, `MODULE` to `module`, `BRANCH` to `branch`, the
worker identity branch/worktree to `worker_home_ref` or bounded status
metadata, and the live process/session id to provider-neutral `runtime_ref`.
Product Events should carry `logs_path`, `worktree_path`, `runner_kind`,
`runner_provider`, and bounded metadata such as `codex_home`, `scratch_path`,
`sandbox`, and `session_backend`; they should not inherit manual-only
configuration names, shell command shapes, or the older Docker container/image
bootstrap model.

### 2026-05-31 Direct Codex Worker Implementation Worktrees

Initial product work for direct Codex workers is isolated outside the main
module checkouts. Do not merge or promote these branches until the operator
explicitly confirms the work. Worktree locations below are session-local and
relative to the supervisor checkout root; the branch names are the durable
recovery handles:

- `bus-worker`: branch `codex/workers-direct`, worktree
  `worktrees/workers-direct/bus-worker`.
- `bus-api-provider-worker`: branch `codex/workers-direct`, worktree
  `worktrees/workers-direct/bus-api-provider-worker`.
- `bus-integration-worker`: branch `codex/workers-direct`, worktree
  `worktrees/workers-direct/bus-integration-worker`.
- `bus-api-provider-events`: branch `codex/workers-direct`, worktree
  `worktrees/workers-direct/bus-api-provider-events`.
- `bus-api`: branch `codex/workers-direct`, worktree
  `worktrees/workers-direct/bus-api`.

The first slice carries `runner_kind`, `runner_provider`, and `runtime_ref`
through the worker CLI/client, API-provider create/projection/status path, and
integration-provider status snapshots. It also adds a direct Codex lifecycle
planner and command-backed executor in `bus-integration-workers` for host-run
Codex workers using product worktree, worker identity worktree, isolated
`CODEX_HOME`, logs, scratch, model, sandbox, non-secret runtime metadata, and
process-backed pause/resume/stop control. A local process smoke test proves
the executor against temporary Git repositories and a fake Codex executable:
it creates both worktrees, starts a host process, records process runtime
metadata, writes logs/startup evidence under the isolated `CODEX_HOME`, and
stops the process without container tooling. The direct executor prepares the
assigned Bus module inside the product worktree by initializing its submodule,
checking out or creating the worker branch, and initializing safe local sibling
module replacements discovered from the module `go.mod`.

The follow-up selector slice adds the first runner-provider registry inside
`bus-integration-workers`: empty create/control requests default to
`direct`/`codex-direct`, explicit direct requests route to the same provider,
and unsupported runner kinds/providers fail with a bounded lifecycle failure
snapshot instead of leaking provider-specific behavior into callers. The
direct command modes now return this selector with a direct provider
registered, so future container or VM providers have an extension point below
the workers integration boundary.

The Events ACL slice adds `bus.workers.stop.*` to the protected worker control
namespace in `bus-api-provider-events`, requiring `workers:control` to publish
stop requests and `workers:read` to stream them. This keeps stop aligned with
pause, resume, and assign for the first direct Codex worker control surface
instead of forcing ordinary stop operations through `workers:admin`.

The logs/attach guidance slice adds provider-neutral read endpoints and CLI
commands in the current singular scaffolds. `bus-api-provider-workers` now
serves `GET /api/v1/workers/{id}/logs` and
`GET /api/v1/workers/{id}/attach` from the worker projection, and
`bus worker logs <worker-id>` / `bus worker attach <worker-id>` call those
endpoints in API mode. The returned guidance is bounded and non-secret:
`logs_path`, `runtime_ref`, `app_server_url`, `session_backend`, runner
kind/provider, worktree path, and environment id. The CLI and API provider do
not embed provider-specific terminal or filesystem access policy; the
integration provider remains the source of truth for direct-runner metadata.

The plural product CLI slice adds a real `bus-workers` executable in the
current `bus-worker` implementation worktree while keeping `bus-worker` as a
legacy/scaffold compatibility binary. The module build now produces both
binaries, install/uninstall handle the plural alias, the e2e check verifies the
plural binary can read the local registry, and README examples use the built
`./bin/bus-workers` executable that the Bus dispatcher can resolve for the
target `bus workers ...` UX. The e2e now also starts a local workers API stub
and drives the plural executable through the API path for direct Codex worker
create, list, status, logs, attach, assign, pause, resume, and stop using
`gpt-5.3-codex-spark`, `direct`/`codex-direct`, runtime refs, logs paths, and
session metadata. This proves the product CLI's API-mode command encoding and
output for the direct-worker lifecycle without containers, while still leaving
the real API provider relay and remote dev-hg path as separate acceptance
evidence.

The product CLI error-handling slice keeps that API-mode UX aligned with the
provider read-refresh hardening. `bus-workers` now parses structured workers
API error envelopes such as `refresh_failed` and prints the error type plus
bounded message, while non-JSON HTTP error bodies are no longer echoed to the
terminal. This prevents token-file paths or private relay diagnostics from a
failed provider/relay read from leaking through the CLI, but still gives the
operator a useful status and reason. Focused tests cover both structured
`refresh_failed` errors and plain HTTP error bodies containing a synthetic
private token path. The `bus-worker` `make check` gate passed for this slice,
including the plural binary build and local API e2e stub.

The API-provider product-path proof slice adds a hermetic direct-worker
lifecycle projection test in `bus-api-provider-workers`: create, pause, resume,
assign, list, logs, attach, and stop requests are published as canonical
`bus.workers.*` Events, a simulated direct worker environment returns
`bus.workers.status.snapshot` and `bus.workers.list.response` evidence, and the
provider projection makes the direct runner status, lifecycle phase, task ref,
runtime ref, logs path, worktree path, runner kind/provider, and
`session_backend` metadata observable through the API. The provider module also
now refreshes projection evidence after publishing a list request when a
mounting service supplies a request-scoped refresh hook, so same-response list
reads can include returned multi-environment worker evidence without requiring
the provider package to own a hidden background listener. A focused unit test
proves that the hook runs after `bus.workers.list.request` is published and
before the list response is read from the projection. The provider module also
now has a minimal e2e readiness smoke so its standard `make check` gate passes
instead of failing on a missing `tests/e2e.sh`.

The provider read-refresh hardening slice makes that same request-scoped
refresh path fail closed. `bus-api-provider-workers` now returns a bounded
`502 refresh_failed` response if list/show/status/logs/attach publishes its
worker evidence request but the mounted provider or standalone refresh hook
cannot replay returned worker Events into the projection. The response does not
include the raw refresh error, so relay diagnostics cannot leak token-file
paths or private transport details. Focused tests cover both multi-environment
list and targeted status refresh failures after the canonical
`bus.workers.list.request` has been published. This is still local product-path
hardening rather than live service-owned relay proof, but it prevents stale or
empty reads from being mistaken for a successful worker relay.

The stronger API-provider product-path slice wires the API provider test
harness to the actual `bus-integration-workers` handler and direct lifecycle
through local module replacements. The in-process loopback publishes the
provider's canonical `bus.workers.*` requests into `workersintegration.Worker`,
uses the real direct runner selector/lifecycle with a fake process runner, and
applies the emitted `bus.workers.status.snapshot` and
`bus.workers.list.response` Events back into the API projection. This proves
create, pause, resume, assign, list, logs, attach, and stop across the local
API-provider-to-integration-provider contract without a hand-written status
simulator, while still remaining hermetic and container-free. It is not a
substitute for service-owned relay or remote dev-hg proof.

The API-provider binary e2e slice strengthens the standalone local provider
proof. `bus-api-provider-workers` is now started as a real binary against a
hermetic fake Bus Events endpoint, then driven through direct-worker create,
pause, resume, assign, and stop HTTP requests. The e2e asserts that the
accepted create response preserves `worker_home_ref` and that the fake Events
endpoint received canonical `bus.workers.*` Events with `gpt-5.3-codex-spark`,
`direct`/`codex-direct`, module, branch, sandbox, create `task_ref`, control
`reason`, assign `assignment_id`, and stop `preserve_worktree=true`. This
proves the binary's event-publication contract for the direct Codex worker
path without starting containers or depending on a live remote relay.

The `bus-api` normal-path slice adds an isolated `bus-api` worktree to the
same feature branch family and proves that the workers provider can be mounted
through the local API gateway for direct Codex worker requests. A focused
`bus-api` e2e starts a fake Bus Events endpoint, runs `bus-api serve
--provider workers --enable-module workers`, sends direct-worker create,
pause, resume, assign, and stop requests through the printed capability URL,
and asserts that the downstream Events are the canonical `bus.workers.*`
payloads with `gpt-5.3-codex-spark`, `direct`/`codex-direct`, module, branch,
sandbox, `worker_home_ref`, create `task_ref`, control reasons, assign
`assignment_id`, and default stop `preserve_worktree=true`. This proves the
local `bus-api` provider mount and Event publication path. The same slice now
refreshes the mounted workers projection on read requests by replaying returned
worker Events with `follow=false`, avoiding hidden background goroutine
ownership inside `bus-api` while still making status/list reads observe
returned worker snapshots. The e2e's fake worker environment publishes a
direct-runner `bus.workers.status.snapshot`, and the test reads back
`status=running`, `runtime_ref`, `worker_home_ref`, and the create
`active_task_ref` through the `bus-api` capability URL. The same slice now
mounts public provider collection roots exactly as well as their slash-ended
subtrees, so the `bus-workers` client path `POST /api/v1/workers` reaches the
mounted provider without relying on a redirect to `/api/v1/workers/`. When the
sibling `bus-workers` binary is present, the focused e2e also creates, reads
status for, and stops a direct worker through `bus-workers --api-url <bus-api
capability-url>`, proving the local product CLI-to-gateway path against the
same fake Events endpoint. The mounted provider now wires the request-scoped
projection refresh hook to replay returned worker Events with `follow=false`
after list request publication as well as before ordinary read projection
access. The focused e2e's fake Events endpoint returns two
`bus.workers.list.response` Events for the same worker id in `local-dev` and
`dev-hg`, and the `bus-api` list response preserves both environments with
their direct-runner runtime metadata. This proof is still hermetic and does
not replace service-owned relay or remote dev-hg proof.

The gateway refresh/redaction slice tightens the same mounted provider path.
The `bus-api` workers backend no longer performs a separate best-effort
pre-refresh before handing a request to `bus-api-provider-workers`; the
provider's own request-scoped refresh hook is now the single owner of replay
and `refresh_failed` responses. Provider-construction failures are also
bounded before being returned from the public mounted route: unavailable
responses name the relevant configuration variable, such as
`BUS_WORKERS_EVENTS_TOKEN_FILE` or `BUS_EVENTS_URL`, but do not echo private
token-file paths, raw URLs, or OS error strings. Focused tests cover redaction
of a synthetic private token path and raw bad Events URL, and the full
`bus-api` `make check` gate passed with the mounted workers provider e2e
running rather than skipped.

The durable-ref contract slice threads optional `worktree_ref` and `logs_ref`
through the direct integration snapshot, API provider projection, logs/attach
responses, and plural CLI output while keeping `worktree_path` and `logs_path`
for today's bootstrap inspection. The first direct implementation emits stable
logical refs shaped like `worker:<id>:product-worktree` and `worker:<id>:logs`;
these are intentionally non-secret placeholders for future repos/artifact-owned
references, so new runner providers can attach durable locations without
changing Events, API, or CLI schemas again.

The targeted read-refresh slice adds the worker-id narrowing path required by
the Event contract. `bus-integration-workers` now honors optional
`worker_ids` on `bus.workers.list.request` before lifecycle reconciliation, so
a remote worker environment can answer a status-focused read without scanning
or reconciling unrelated workers. `bus-api-provider-workers` now accepts
`worker_id` / `worker_ids` query filters on list reads and publishes targeted
`bus.workers.list.request` Events before single-worker show, status, logs, and
attach reads. When mounted through `bus-api`, those read requests can refresh
the local projection from returned worker Events before answering the operator.
The mounted-provider e2e helper now asserts the extra targeted list request
and synthesizes matching list responses for requested worker ids. This is
still local and hermetic; it strengthens the product path for later
service-owned relay and remote dev-hg proof.

The direct workspace-materializer slice narrows the remaining repos ownership
gap inside the direct Codex runner. `bus-integration-workers` now has a
`DirectCodexWorkspaceMaterializer` boundary for product and worker-identity
branch/worktree materialization. The default materializer preserves today's
Git compatibility behavior, but a repos-backed materializer can now own
preflight, base-ref refresh, and worktree ensure for those two generic
workspaces without changing direct Codex process launch, runner selection,
pause/resume/stop, status projection, or task assignment. A focused test proves
that when a materializer is injected, the direct runner sends generic
product/worker-identity workspace requests and does not run its own
repository preflight, fetch, or `git worktree add` commands for those
workspaces. This does not complete repos-owned materialization, but it removes
one hard coupling that would otherwise force a larger worker refactor.

The repos-materializer adapter slice adds the first concrete worker-side
adapter for that seam without importing an unpromoted repos module directly.
`bus-integration-workers` now has a `DirectCodexReposWorkspaceMaterializer`
that delegates the direct runner's generic product and worker-identity
workspace requests to a repos-owned client interface shaped like the
`bus-integration-repos` feature branch's `EnsureWorkspace` contract:
`repo_id`, `branch`, `base_ref`, `worktree_name`, `worktree_path`, and
`environment_id` in, non-secret workspace status out. The adapter validates
that repos returned the same repo, branch, worktree path, and environment the
direct runner is about to use before Codex starts. Tests prove that direct
Codex launch emits repos-owned ensure requests for both product and
worker-identity workspaces and fails closed when repos returns a mismatched
workspace. This still is not full repos-owned materialization because the
repos feature branches are not promoted and service wiring is not attached,
but the direct runner no longer needs another refactor to delegate workspace
creation once repos is accepted.

The repos-readiness validation slice makes that adapter fail closed on unsafe
repos-owned workspace status. After a repos client returns non-secret workspace
evidence, `bus-integration-workers` now requires the workspace to exist and
rejects dirty, locked, active, missing, failed, or otherwise not-ready status
before the direct Codex process starts. Focused tests cover missing,
dirty, locked, and active repos results in addition to the existing mismatch
checks. This still does not complete repos-owned materialization, because the
repos modules remain unpromoted skeletons and there is no service wiring yet,
but it makes the worker-side handoff conservative for the dirty/locked/active
states called out by the repos contract.

The selected-environment mutation slice makes the broadcast/read distinction
enforceable in the API provider. `bus-api-provider-workers` now rejects create
requests unless they carry `environment_id` or exactly one
`eligible_environments` entry that can be selected as the create target. Pause,
resume, assign, and stop now require a selected `environment_id` from the query
or request body before publishing canonical `bus.workers.*` mutation Events.
Read-style list/status refresh requests may still omit `environment_id` when
broadcast evidence discovery is intended. This keeps mutation fan-out from
depending on whichever worker environments happen to be listening.

The remote-provenance metadata slice makes the future dev-hg direct proof more
auditable through the normal worker status path. When `bus-integration-workers`
is configured from `--remote-id`, the direct Codex lifecycle now threads
non-secret Bus remote metadata into direct runner plans, worker `meta.env`, and
canonical `bus.workers.status.snapshot` metadata: `remote_id`, `remote_host`,
`remote_user`, `events_url`, `worker_root`, `credential_source_kind`, and a
redacted `credential_source_label`. Profile-level credential-source metadata
wins over the remote default when present, and token-file refs that look like
paths collapse to a kind label rather than leaking absolute token paths into
Events. The API-provider loopback proof now asserts that these fields survive
the integration-provider-to-projection boundary. This still does not prove live
remote dev-hg execution or service-owned relay, but it makes the required
remote proof fields part of the product evidence stream.

The product CLI status-surface slice exposes that evidence through the plural
`bus-workers` API-mode status command. `bus-workers status <worker-id>` now
prints a fixed allowlist of non-secret direct-runner metadata in text mode,
including `remote_id`, `remote_host`, `remote_user`, `events_url`,
`worker_root`, `credential_source_kind`, `credential_source_label`,
`session_backend`, `sandbox`, `codex_home`, `scratch_path`, worker identity
paths, and writable roots when present. JSON status still preserves the full
bounded metadata map for structured callers, but text output intentionally
does not print arbitrary metadata keys. The plural CLI e2e stub includes a
token-file-like compatibility probe and verifies the default text status does
not leak that path while still showing the dev-hg proof fields.

The gateway provenance proof slice extends the mounted `bus-api` workers e2e
so the same non-secret remote provenance survives the local product gateway.
The fake worker environment now returns direct-worker status/list evidence
with dev-hg-style `remote_host`, `remote_user`, `events_url`, `worker_root`,
and `credential_source_label` metadata. The focused `bus-api` e2e asserts
those fields in raw mounted provider JSON and, when the sibling `bus-workers`
binary is available, through `bus-workers --api-url <bus-api capability-url>
status ...`. This is still hermetic local proof, not service-owned relay or
live dev-hg execution, but it pins the product CLI-to-gateway-to-provider
projection path for the fields required by the later remote proof.

The logs/attach operator-guidance slice extends the same metadata allowlist to
`bus-workers logs <worker-id>` and `bus-workers attach <worker-id>` in API
mode. Text output now shows bounded direct-runner provenance such as
`remote_host`, `remote_user`, `events_url`, and `credential_source_label` when
the provider returns it, while arbitrary metadata keys remain JSON-only. The
plural CLI tests and e2e include token-file-like metadata and assert that text
logs/attach output does not leak those paths. This keeps normal operator
guidance aligned with status without expanding the public worker contract to
provider-private fields.

The projection metadata sanitization slice moves the same redaction boundary
into `bus-api-provider-workers` itself. Worker status/list metadata ingested
from Events is now bounded before entering memory or file-backed projections:
metadata keys must be lowercase ASCII identifiers, values must be single-line
valid UTF-8 no longer than 512 bytes, each worker view keeps at most 64
metadata keys, and secret-shaped keys or values such as token files,
credential values, raw auth paths, private keys, and prompt bodies are dropped.
Useful direct-runner provenance such as `remote_host`, `remote_user`,
`events_url`, `worker_root`, `credential_source_kind`,
`credential_source_label`, `codex_home`, `scratch_path`, `session_backend`,
and `sandbox` remains projectable. File-backed projections also sanitize
metadata loaded from disk so older unsafe projection files do not reintroduce
invalid metadata. This still depends on upstream integration providers not
publishing secrets in the first place, but the local read model now enforces
the goal's projection boundary instead of relying only on CLI text allowlists.

The integration status metadata sanitization slice moves the same bounded
metadata contract to the upstream Event producer. `bus-integration-workers`
now sanitizes worker metadata while normalizing status snapshots and list
responses, before publishing `bus.workers.status.snapshot` or
`bus.workers.list.response` Events. Secret-shaped metadata such as token-file
paths, credential values, auth paths, private prompt bodies, private keys,
multiline command output, invalid keys, and oversized values is dropped at the
integration boundary, while non-secret direct-runner provenance still
survives. The direct-runner capability metadata now also advertises the remote
proof metadata fields (`worker_root`, `remote_id`, `remote_host`,
`remote_user`, `events_url`, `credential_source_kind`, and
`credential_source_label`) alongside the local direct-runner fields. This
keeps the API-provider projection sanitizer as defense in depth rather than
the only redaction layer.

The create-path contract slice fixes the product CLI/API response shape for
direct worker creation. `bus-api-provider-workers` now answers
`POST /api/v1/workers` with an accepted worker view rather than the raw
published Event, so the plural `bus-workers` CLI can decode and report the
created worker id through the real API-provider product path. The same slice
threads optional `task_ref` through CLI create, API create Events, and
`bus-integration-workers` create handling; when present, the initial direct
worker status snapshot reports it as `active_task_ref` before later assign
requests can replace it.

The control-metadata slice threads optional non-secret operator context through
the explicit control path. `bus-workers` now accepts `--reason` on
pause/resume/stop/assign and `--assignment-id` on assign; the API provider
publishes those fields on the corresponding `bus.workers.*.request` Events and
continues to default stop requests to preserving the worktree unless an
explicit body override is provided. The integration payload types accept and
trim that metadata, keeping the public contract ready for scheduler/audit use
without changing direct runner mechanics.

The worker-home projection slice preserves the non-secret durable identity
pointer after create. `worker_home_ref` now flows from `bus-workers create`,
through API-provider accepted create responses, integration worker status/list
snapshots, API-provider projection merges, and CLI status output. This keeps
the worker identity/home reference visible next to live runner state while
repos-owned worktree/home materialization remains a separate acceptance
dependency.

The capability-discovery slice makes `bus-integration-workers` advertise the
first direct runner through Bus Events capability extensions. The capability
document now declares the default runner `direct`/`codex-direct`, the supported
direct runner provider with runtime `host-process` and session backend
`process`, the canonical non-secret worker status fields, the direct-runner
metadata fields (`worker_identity_branch`, `worker_identity_worktree_path`,
`codex_home`, `scratch_path`, `session_backend`, `sandbox`, `writable_roots`,
and optional `process_id`), and the extension/redaction policy for future runner
providers. This is discovery metadata only: it does not add a container runner
and it keeps provider mechanics below the `bus-integration-workers` boundary.

The direct-exec readiness slice moves `bus-integration-workers --check-ready`
closer to real host-run Codex proof. In planning mode, readiness remains a
lightweight catalog validation. In `direct-exec`, readiness now also validates
the worker root by creating it and probing writability, the product Git
repository, the worker identity Git repository, and the configured Codex
command with `--version` before reporting ready. This gives operators a
no-container preflight before allowing the integration service to create
worktrees, write worker-local logs/scratch/`CODEX_HOME`, and start a real Codex
process. The integration README was updated so `direct-plan` is the documented
safe default, `direct-exec` is the documented command-backed host process
mode, and older App Server/container modes are explicitly not the first direct
Codex worker path. A module e2e smoke now builds the
`bus-integration-workers` binary and proves both readiness paths
hermetically: `direct-plan --check-ready` validates a static catalog, while
`direct-exec --check-ready` validates temporary product and worker-identity Git
repositories plus a fake Codex executable responding to `--version`.
The same built binary also passed a local host preflight against the real
`projects/busdk` checkout, the real `projects/busdk/agents/worker` identity
repository, a temporary writable worker root, and the operator's local Codex
binary reporting `codex-cli 0.135.0`. This is useful host evidence, but it is
not yet the command-backed worker execution proof because it does not create a
worker or start the real Codex process.

The remote-config binding slice makes the direct integration command consume
`bus-remote` metadata for the later dev-hg proof. `bus-integration-workers`
now accepts `--remote-id` / `BUS_WORKERS_REMOTE_ID` and resolves that id from
the normal Bus remote registry. When direct lifecycle mode is selected, the
resolved remote fills missing non-secret defaults: `environment_id`, display
name, worker Events URL, product repo root from `remote_workdir`, worker root
under `<remote_workdir>/tmp/workers`, worker identity repo under
`<remote_workdir>/agents/worker`, the configured Codex tool path, and the
selected remote worker profile's model. Explicit direct flags still win. A
focused command test writes a repo-local `dev-hg` remote config with
`ssh_target=coding-agent@dev.hg.fi`, token-file credential-source reference,
remote workdir, codex tool path, and `codex-spark` model
`gpt-5.3-codex-spark`, then proves `direct-exec --check-ready` derives the
required direct preflight configuration from that remote without embedding
tokens. The built binary also resolves the current repository-local `dev-hg`
remote in planning mode. This is necessary setup for the remote proof, not the
remote proof itself.

The writable-roots direct-runner implementation slice keeps the product
worktree as the Codex process working directory and passes the worker identity
worktree, logs directory, and scratch directory as Codex `--add-dir` writable
roots. The direct plan/status metadata now reports all writable roots,
including the primary product worktree, so operators can audit the sandbox
boundary without learning provider-private command templates. Direct App Server
ports are derived
deterministically from the worker id and configured base port instead of
reusing one fixed port for every direct worker, which keeps parallel direct
workers from colliding by default. The in-memory worker catalog also rejects
updates that try to mutate a worker id through an update path.

The verified follow-up hardening slice in `bus-integration-worker` adds
provider-neutral list/status reconciliation: the worker handler asks the
selected lifecycle provider to reconcile listed workers before publishing a
list response, and the direct provider checks live host-process runtime refs for
running, paused, creating, and stopping workers. Missing direct processes are
reported as `failed` with bounded non-secret error text, while context
cancellation and deadlines remain real request errors. Lifecycle failure
snapshots are persisted back to the catalog before status publication and the
returned error is sanitized so raw runner errors, command output, and secret-ish
strings do not leak to callers.

That same slice keeps direct planning non-executing. Direct and legacy App
Server port reservations now happen only on the command-backed create/launch
path, probe around in-process reservations, and are released on launch failure
or stop. Direct host processes use fingerprinted `process:<pid>:<token>`
runtime refs, are reaped instead of detached with no wait path, and stop waits
until the original process is gone before the worker is marked stopped. Runtime
signals validate the fingerprint first so a reused PID is not treated as the
same worker. Direct preparation commands may inherit the host environment when
no explicit env is supplied for Git and credential helper behavior, but the
Codex process itself still receives the prepared `CODEX_HOME`, model, and
source env plus a narrow host allowlist rather than an unbounded environment
dump.

The direct runner also now separates product and worker-identity base refs:
`BUS_WORKERS_DIRECT_BASE_REF` applies to the product worktree, while
`BUS_WORKERS_DIRECT_WORKER_IDENTITY_BASE_REF` can point the worker identity
worktree at a different branch/ref and defaults to the product base ref when
omitted. Create-request model and sandbox values override process defaults for
the specific worker, and unsafe module paths, branch refs, process ids, base
ref parsing, and sibling-module replacements are rejected or bounded before
they reach Git or process-control calls.

The worker integration module gate is now green for this direct-runner branch.
`pkg/workerconsumer` makes background control-listener ownership explicit by
requiring a caller-supplied `StartControlLoop` hook when dual primary/control
consumption is used, and its idle-timeout controller no longer owns a package
goroutine. The full `bus-integration-worker` `make check` passed with Bus Go
quality lint, verbose Go tests across all packages, build, and the
direct-plan/direct-exec e2e preflight smoke.

The same branch now has an optional real-Codex direct lifecycle smoke,
`TestDirectCodexLifecycleExecutesAgainstRealCodexCommand`, gated by
`BUS_WORKERS_REAL_CODEX_E2E=1` and `BUS_WORKERS_REAL_CODEX_COMMAND`. On this
local host it passed with the operator's local Codex binary: the lifecycle
created temporary product and worker-identity Git repositories, started the
real Codex App Server on a loopback listener through the direct runner,
observed the listener, stopped the worker, and verified the process exited.
This proves the local command-backed direct runner against the real Codex
binary without container tooling. It still is not the remote dev-hg product
proof or the final service-owned API/Event path proof.

The direct-exec Events product-path slice adds a command-level e2e to
`bus-integration-workers`. The test starts a hermetic fake Bus Events API that
streams one canonical `bus.workers.create.request`, runs the built
`bus-integration-workers` binary in `direct-exec`, prepares temporary product
and worker-identity Git repositories, starts a fake Codex process on the host,
and asserts the published `bus.workers.status.snapshot` includes
`status=running`, `lifecycle_phase=ready`, `gpt-5.3-codex-spark`,
`direct`/`codex-direct`, `worker_home_ref`, `active_task_ref`, process
`runtime_ref`, worktree/log refs, writable roots, isolated `CODEX_HOME`,
scratch path, worker identity path, sandbox, and process session metadata.
This proves the standalone integration service can consume worker Events and
launch a direct Codex runtime without containers. It remains local and
hermetic: it does not replace service-owned relay proof or live remote dev-hg
execution through the full local API/gateway/relay path.

The API-provider to integration round-trip slice extends the standalone
`bus-api-provider-workers` e2e from publish-only proof to a local Events relay
proof. Its hermetic Events stub now supports authenticated publish, replay, and
follow streams. The e2e starts the built `bus-api-provider-workers` binary with
its projection listener enabled, starts the real `bus-integration-workers`
command in `direct-exec`, creates temporary product and worker-identity Git
repositories, and uses a fake host Codex process. A create request sent to the
provider publishes canonical `bus.workers.create.request`; the integration
service consumes it, launches the direct runner, publishes
`bus.workers.status.snapshot`; and the provider projects that snapshot back
through `/api/v1/workers/{id}/status` as `running`/`ready` with
`direct`/`codex-direct`. The same e2e then publishes pause, resume, assign, and
stop requests, verifies the provider emits the canonical control Events, and
waits until the provider reads back the integration's `stopped`/`stopped`
snapshot. This proves the standalone provider and standalone integration can
round-trip direct worker lifecycle through the shared `bus.workers.*` Events
contract without adding provider-specific API coupling. It is still local,
hermetic, and fake-Codex proof; it does not yet prove the service-owned relay,
repos-owned worker persistence, or live remote dev-hg path.

The mounted product-path round-trip slice adds the local gateway and plural CLI
in front of the same real integration command. A new `bus-api` e2e starts a
hermetic replay/follow Events relay, the real `bus-integration-workers`
command in `direct-exec`, the built `bus-api` server with the workers provider
mounted, temporary product and worker-identity Git repositories, and a fake
host Codex process. It first sends raw HTTP requests through mounted
`/{token}/v1/api/v1/workers` and verifies the mounted provider projects
`running`/`ready`, list evidence, stop, and `stopped`/`stopped` from the
integration service. It then runs the plural `bus-workers` CLI source against
the mounted `bus-api` capability URL and verifies create, status, process
runtime metadata, task ref, worker-home ref, stop, and stopped status through
the same gateway. The assertion helper checks provider create/stop Events,
provider read/list requests, integration list responses, and integration
status snapshots for both the raw HTTP worker and CLI-created worker. This
closes a local product-path proof gap between standalone provider evidence and
the intended `bus workers -> bus-api -> bus-api-provider-workers ->
bus-integration-workers` flow. It is still local and hermetic: it uses a fake
Events relay and fake Codex process, so it does not replace service-owned
relay, repos-owned persistence, scheduler/task claiming, or live remote dev-hg
acceptance proof.

The scheduler launch-contract slice in `bus-integration-workers` now preserves
worker routing identity after queue selection. `workerqueue.SelectReconcileDecision`
already evaluated assigned worker id, assigned worker group, and eligible
environment selectors before choosing a launch; the selected
`workerstart.LaunchRequest` now carries the selected worker id, worker groups,
task assignment fields, and eligible environment ids into the deterministic
worker-start Event and sanitized launch environment. `workerstart.TargetsWorker`
also rejects a start request with a different explicit `worker_id`, so a
scheduler-selected launch cannot silently drift to another worker lane after
selection. Focused tests cover the queue-to-launch metadata handoff and
worker-start payload/environment projection, and the full
`bus-integration-worker` `make check` gate passed for this slice. This is
useful scheduler-contract evidence, but it does not complete idle worker
claiming or scheduler-owned status acceptance; those still depend on the task
and service-owned scheduler goals.

The scheduler-to-workers contract slice adds a canonical workers launch
adapter in `bus-integration-workers`. Scheduler-selected
`workerstart.LaunchRequest` values can now be published as
`bus.workers.create.request` Events for `direct`/`codex-direct`, carrying the
selected worker id or a deterministic task-derived worker id, target
environment id, module/recipient, task ref, worker groups, eligible
environments, branch, worker-home ref, sandbox, and pending Events relay
metadata for the destination environment. A focused scheduler test runs
`workerscheduler.Reconcile` with this adapter as `StartLaunchBatch` and
asserts that the refill path emits the canonical workers create Event rather
than requiring scheduler callers to depend on runner-specific mechanics. This
is the workers-contract bridge needed for Codex-only scheduler integration,
but it is not a full service-owned scheduler loop, task claim verification
proof, or live dev-hg worker execution proof.

The same slice now has an in-module scheduler-to-integration proof. A focused
test wires `workerscheduler.Reconcile` through `WorkersCreateLauncher`, feeds
the emitted `bus.workers.create.request` into the real
`workersintegration.Worker` handler with the direct runner selector in
planning mode, and asserts the returned `bus.workers.status.snapshot` contains
the selected worker id, planning-mode `paused`/`prepared` direct-runner state,
active task ref, target environment, `direct`/`codex-direct`, model,
worktree/log refs, and bounded direct metadata. The `paused`/`prepared` state is
not final create acceptance; it is the non-executing planning lifecycle's
evidence before a command-backed runner starts Codex. This proves the scheduler
bridge reaches the actual workers integration contract without starting Codex or
containers. It remains hermetic planning evidence, so the live scheduler loop,
task claim race handling, and remote execution proof are still open.

The command-level scheduler slice makes that bridge invokable through
`bus-integration-workers --scheduler-once`. The command reads queued task and
active-worker JSON snapshots, runs the existing worker queue selector, and
publishes selected launches as canonical `bus.workers.create.request` Events to
the configured Events API with `direct`/`codex-direct`, target environment,
worker id/group routing, task ref, branch, worker-home ref, sandbox, and
pending relay metadata. A focused command test drives this mode against an
`httptest` Events endpoint and verifies the published Event and
script-friendly scheduler result output. This is still bounded one-shot
scheduler proof, not a service-owned loop or atomic claim acceptance, but it
turns the Codex worker bridge into an executable command path.

The command-level Events round-trip slice strengthens that proof by running
both command modes against one fake Events API. The test first runs
`bus-integration-workers --scheduler-once` to publish a scheduler-selected
`bus.workers.create.request`, then runs `bus-integration-workers --once` in
`direct-plan` listener mode against the same Events API. The listener consumes
the replayed create request and publishes a `bus.workers.status.snapshot` with
the selected worker id, task ref, target environment, `paused`/`prepared`,
`direct`/`codex-direct`, model, and bounded direct metadata. The command now
normalizes the internal processed-one sentinel as a clean `--once` exit. This
still does not perform an atomic task claim or start Codex, but it proves the
executable scheduler and worker listener commands interoperate through Events
using the canonical workers contract.

The local command-backed direct-exec scheduler slice takes the same two-command
round trip through actual host-process launch with fake Codex. The test creates
temporary product and worker-identity Git repositories, publishes a
scheduler-selected `bus.workers.create.request`, then runs
`bus-integration-workers --once --lifecycle direct-exec` against the same fake
Events API. The worker listener consumes the create request, creates the
direct worker worktrees from `HEAD`, starts the fake Codex process, publishes a
`running`/`ready` `bus.workers.status.snapshot` with process runtime ref,
active task ref, `direct`/`codex-direct`, and worktree/identity metadata, and
the test cleans up the fake process. This proves the executable scheduler
bridge can reach command-backed direct Codex launch locally without containers.
It remains hermetic local proof; live dev-hg execution, service ownership, and
atomic task claiming are still unaccepted.

The opt-in scheduler claim slice adds the first bounded atomic task-claim proof
to `bus-integration-workers --scheduler-once`. When
`--scheduler-claim-tasks` is set, selected task snapshots must include the
latest claimable source Event id and name. The command uses Events conditional
append to publish `bus.task.claimed` for that exact task before publishing the
canonical `bus.workers.create.request`; missing source Event identity or a
claim conflict fails closed and does not launch a worker. If the claim
succeeds but publishing `bus.workers.create.request` fails, the command
attempts a conditional `bus.task.reopened` append against the claimed Event
before returning the publish error. Focused command tests prove the claim is
appended before the worker create request, that a failed worker-create publish
reopens the task instead of leaving it claimed, and that a task without
`source_event_id` / `source_event_name` does not create a worker. This is still
a bounded command proof rather than the final service-owned scheduler loop,
but it closes the previous scheduler bridge gap where worker creation could be
requested from a static ready snapshot without first winning the task claim
race.

The direct status reconciliation slice now persists stale-runtime findings
back into the mutable integration catalog. Before this slice,
`bus.workers.list.request` could reconcile a dead direct host process and
return a one-off `failed` worker view without updating the in-process control
catalog. The worker list path now normalizes and upserts reconciled snapshots
when the catalog supports control updates, so future list/status/control paths
observe the failed lifecycle state instead of repeatedly rediscovering the
same dead process. A focused test covers a `direct`/`codex-direct` worker with
a missing `process:<pid>` runtime and verifies the `failed`/`failed` snapshot,
last non-secret error, and environment id are persisted in the mutable
catalog. This improves local stale-worker state handling for direct Codex
workers, but it is still in-memory catalog proof rather than durable
repos-owned persistence or remote service-owned reconciliation.

The source-of-truth clarification slice rejects using `--workers-file` as
durable worker state. The file remains bootstrap input for local development
and preflight only. Accepted worker state should come from canonical
`bus.workers.*` Events/projections or a database-backed provider such as
PostgreSQL; Git worktrees and branches may serve as reconciliation evidence
for materialized repository state. A focused command regression test verifies
that processing a `bus.workers.create.request` with `--workers-file` configured
does not rewrite that file, while still publishing the direct-plan status
snapshot through Events. This keeps the current direct-worker implementation
from quietly turning a bootstrap catalog into an accidental control-plane
database.

The Events status hydration slice makes the integration command use the
correct source-of-truth direction for restart recovery. On startup, before
listening for worker requests, `bus-integration-workers` replays existing
`bus.workers.status.snapshot` Events with broadcast replay/no-follow and
hydrates its mutable in-memory catalog from matching environment snapshots.
Focused tests prove that later snapshots replace earlier ones for the same
worker, snapshots from other environments are ignored, and a command started
with an empty `--workers-file` can answer a `bus.workers.list.request` from a
previously published direct `running`/`ready` status snapshot. This is
Events-backed projection proof, not PostgreSQL-specific proof and not yet a
remote service-owned relay proof, but it removes the accidental local-file
state direction for the direct Codex worker slice.

The API-provider projection cleanup applies the same source-of-truth rule to
the local controller path. `bus-api-provider-workers` no longer exposes a
`--projection-file` / `BUS_WORKERS_PROJECTION_FILE` path or a file-backed
worker projection; its standalone read projection is an in-process cache fed by
replayed/followed `bus.workers.list.response` and
`bus.workers.status.snapshot` Events. This keeps restart recovery pointed at
canonical Events replay, with PostgreSQL/database-backed projection still
available as a later provider-owned backing store, rather than introducing
another ad hoc local worker-state file.

This is still not full goal acceptance. Remaining work includes a real Codex
full local product-path proof through `bus workers` / `bus-api` /
`bus-api-provider-workers` / Events / `bus-integration-workers`,
including bidirectional guidance or attach evidence for task details and worker
responses on the long-running worker. Repository/worktree ownership through the
repos contract also remains open.

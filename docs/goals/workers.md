# Workers Goal

## Goal

Build the Bus worker product surface for creating and operating agent workers
with durable identity, state, assignment, and non-secret runtime metadata.

The target UX is `bus workers ...`. Workers should behave like a Bus-managed
runtime resource: listable, creatable, pausable, resumable, assignable, and
observable through local API/controller services and remote integration
services.

The current test model for Codex/App Server workers is the raw model id:

```text
gpt-5.3-codex-spark
```

Pass that value through exactly. Model aliasing or normalization is not part of
the first acceptance path.

## Module Boundary

The target module family is:

- `bus-workers`: user-facing product and plural CLI.
- `bus-api-provider-workers`: local API/controller provider mounted by
  `bus-api`.
- `bus-integration-workers`: remote event/integration provider that manages
  worker lifecycle in a worker environment.

The existing singular `bus-worker`, `bus-api-provider-worker`, and
`bus-integration-worker` checkouts are implementation scaffolds until they are
renamed, wrapped, or promoted into the plural product surface. Do not treat the
singular names as the final user-facing architecture.

## 2026-05-30 Review Notes

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

The remaining work is therefore contract normalization, durable/lived
projection behavior, real App Server lifecycle proof, repository/worktree
integration, stop support, service-owned relay, and product hardening.

## Dependencies

The workers product can continue in parallel on API shape, projection tests,
and integration lifecycle planning, but this goal cannot be fully accepted
until these neighboring goals are complete enough to supply their contracts:

- `docs/goals/repos.md` must be accepted, or explicitly accepted for the
  worker-needed slice, before this goal can claim automatic isolated worktree
  and branch creation as product behavior.
- `docs/goals/service-owned-events-relay.md` and
  `docs/goals/multi-environment-task-worker-refactor.md` must be accepted for
  the live remote proof that local worker requests reach dev-hg and remote
  worker status returns locally without manual import/export.
- `docs/goals/tasks.md` and `docs/goals/service-owned-task-scheduler.md` must
  be accepted for idle worker claiming, queue/capacity behavior, and
  scheduler-owned status.
- The completed `docs/goals/remote-credential-source-selection.md` work needs
  a current `bus task` / worker-provider credential-source proof before the
  dev-hg acceptance proof is treated as final evidence, because the old
  `bus-dev` proof does not by itself cover the current user-facing path.
- Explicit `bus workers assign` can be implemented and tested before idle
  claiming is complete. Task-side assignment remains owned by `bus-task`; both
  entry points should publish or route to the same `bus.workers.assign.request`
  contract when the target is a specific worker.

## Required Behavior

`bus workers list` should list all visible workers and include enough
information for a supervisor to understand where each worker lives and what it
is doing. The list response must support multiple environments returning
workers to the same local request.

The product should support:

- create a worker with identity, environment, model, module, branch/worktree
  target, image, sandbox, and prompt/task metadata;
- pause, resume, and stop a worker;
- assign a worker to a task;
- show current status, active task, lifecycle phase, last non-secret error,
  App Server URL or logical endpoint, and bounded lifecycle metadata;
- keep tokens, secrets, and private credential values out of Events,
  projections, status, logs, and docs.

Each worker should get an isolated worktree and implementation branch
automatically. Repository and worktree policy should use the repos goal rather
than being duplicated in the worker integration service. The canonical
repository rules are in `docs/goals/repos.md`: create a worker-owned worktree
from the configured source repository, use a unique implementation branch per
worker/task assignment, report dirty/locked/active states conservatively, and
never reset or delete a worker worktree as part of normal lifecycle control.

## Event/API Path

The normal path is:

1. `bus workers ...` talks to local `bus-api`.
2. `bus-api` routes to `bus-api-provider-workers`.
3. The provider publishes canonical `bus.workers.*` Events and maintains a
   bounded local read projection.
4. Remote `bus-integration-workers` consumes proxied Events in the target
   environment.
5. The integration service creates, pauses, resumes, assigns, and observes
   worker containers.
6. The integration service publishes `bus.workers.status.snapshot`,
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
  `branch`, `image`, `sandbox`, `prompt_file`, `prompt`, `worker_home_ref`,
  and `task_ref`; optional string arrays `capability_tags`,
  `eligible_environments`, and `group_ids`; optional object field `labels`.
  Allowed `type` values are `human`, `automaton`, and `agent`, matching the
  current `bus-worker` identity contract. `profile` is a non-secret
  operator/config-selected profile name with no whitespace, `@`, or `#`;
  examples include `default-agent` and `codex-spark`.
- `bus.workers.list.request`: envelope `correlationId` required for correlated
  responses; optional string field `environment_id`; optional string array
  `worker_ids` for narrowing a request.
- `bus.workers.pause.request` and `bus.workers.resume.request`: required
  string field `id`; optional string fields `environment_id` and `reason`.
- `bus.workers.stop.request`: required string field `id`; optional string
  fields `environment_id` and `reason`; optional boolean field
  `preserve_worktree`, defaulting to `true` for the first product slice. The
  current bootstrap code has pause/resume/assign but not stop; stop support is
  remaining required work before this goal can be accepted.
- `bus.workers.assign.request`: required string fields `id` and `task_ref`;
  optional string fields `environment_id`, `assignment_id`, and `reason`.
- `bus.workers.list.response`: envelope `correlationId` matching the request;
  required string field `environment_id`; required array field `workers`,
  where each entry uses the same non-secret worker view as
  `bus.workers.status.snapshot`.
- `bus.workers.status.snapshot`: required string fields `environment_id`,
  `id`, `status`, and `lifecycle_phase`; optional string fields `model`,
  `module`, `branch`, `active_task_ref`, `app_server_url`,
  `logical_endpoint`, `container_id`, `worktree_ref`, `worktree_path`,
  `logs_ref`, `logs_path`, and `last_error`; optional object field `metadata`
  for bounded non-secret lifecycle details. `worktree_path` and `logs_path`
  are current bootstrap fields; `worktree_ref` and `logs_ref` are the preferred
  durable-reference direction once repos/artifact ownership is ready.

Defaults: absent `environment_id` on request Events means any listening worker
environment may respond; `environment_id` on response/snapshot Events means
the reporting environment. Absent optional runtime fields mean the integration
provider uses its configured defaults. Redaction rule: tokens, credential
values, raw auth paths, private prompt contents, absolute secret file paths,
and unbounded command output must not appear in Events or projections.
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
worktree, branch, `AGENTS.md`, logs directory, `CODEX_HOME`, model, image,
sandbox, and App Server control path.

## Runtime Scope

Worker containers running Codex/App Server are runtime instances. The workers
product owns identity, control, assignment, state, lifecycle policy, and
projection. Runtime/provider protocol details remain in `bus-agent` and the
App Server integration layer.

Workers may be assigned explicitly through `bus workers assign <worker>
<task-ref>` when the operator is controlling a specific worker, or through
`bus task ...` when the operator is assigning from the task/thread side.
`bus-task` remains the owner of task/thread UX and task status. Both paths
should map to the same worker assignment event once they cross the API/Event
boundary. Idle workers may claim an approved available task only after
`docs/goals/tasks.md` has accepted the canonical task claimability/queue
contract and `docs/goals/multi-environment-task-worker-refactor.md` has
accepted bidirectional relay for task claim, progress, and terminal evidence.

## Acceptance Criteria

This goal is accepted when:

- `bus workers` is the documented product CLI for worker identity and control;
- the local API provider publishes and projects canonical `bus.workers.*`
  requests/evidence;
- the remote integration provider consumes those Events and controls real
  worker lifecycle;
- each created worker gets an isolated worktree and branch automatically;
- list/status reads preserve environment identity and can merge responses from
  multiple environments;
- pause/resume/assign/stop create observable state transitions;
- at least one worker in the configured remote environment whose operator host
  is `coding-agent@dev.hg.fi` is created and controlled through the product
  path using `gpt-5.3-codex-spark`; the environment id and credential-source
  label must come from the Bus remote/environment configuration used by
  `bus-remote` and the Events relay route, with at least `environment_id`,
  `remote_host`, `remote_user`, `events_url`, `credential_source_label`,
  `worker_root`, and `container_image` fields. For the current dev-hg proof,
  the reproducible config source must declare `remote_host=dev.hg.fi`,
  `remote_user=coding-agent`, and a non-secret credential-source label such as
  `dev-hg-ssh` or the configured equivalent; those values must not be
  hard-coded in worker Events;
- focused unit tests cover API request shaping, projection merge behavior,
  integration request handling, lifecycle planning/execution errors, CLI
  encoding/decoding, and secret redaction;
- integration/e2e proof is added after the unit-tested pieces are available
  and reviewed.

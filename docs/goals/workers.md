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

The first interoperable event contract must include these names and fields:

- `bus.workers.create.request`: required string fields `correlation_id`,
  `source_environment_id`, and `worker_id`; optional string fields
  `target_environment_id`, `model`, `module`, `branch`, `image`, `sandbox`,
  `prompt_file`, and `task_ref`; optional object field `labels`.
- `bus.workers.list.request`: required string fields `correlation_id` and
  `source_environment_id`; optional string field `target_environment_id`;
  optional string array `worker_ids` for narrowing a request.
- `bus.workers.pause.request` and `bus.workers.resume.request`: required
  string fields `correlation_id`, `source_environment_id`, and `worker_id`;
  optional string fields `target_environment_id` and `reason`.
- `bus.workers.stop.request`: required string fields `correlation_id`,
  `source_environment_id`, and `worker_id`; optional string fields
  `target_environment_id` and `reason`; optional boolean field
  `preserve_worktree`, defaulting to `true` for the first product slice.
- `bus.workers.assign.request`: required string fields `correlation_id`,
  `source_environment_id`, `worker_id`, and `task_ref`; optional string fields
  `target_environment_id`, `assignment_id`, and `reason`.
- `bus.workers.list.response`: required string fields `correlation_id` and
  `environment_id`; required array field `workers`, where each entry uses the
  same non-secret worker view as `bus.workers.status.snapshot`.
- `bus.workers.status.snapshot`: required string fields `environment_id`,
  `worker_id`, `state`, and `lifecycle_phase`; optional string fields
  `model`, `module`, `branch`, `active_task_ref`, `app_server_url`,
  `logical_endpoint`, `container_id`, `worktree_ref`, `logs_ref`, and
  `last_error`; optional object field `metadata` for bounded non-secret
  lifecycle details.

Defaults: absent `target_environment_id` means any listening worker
environment may respond; absent optional runtime fields mean the integration
provider uses its configured defaults. Redaction rule: tokens, credential
values, raw auth paths, private prompt contents, absolute secret file paths,
and unbounded command output must not appear in Events or projections.
`labels` and `metadata` are string-to-string maps only. Keys must be lowercase
ASCII identifiers using letters, digits, `_`, `.`, or `-`, and values must be
non-secret UTF-8 strings no longer than 512 bytes each. A single event should
carry at most 32 label keys and 64 metadata keys. Later snapshots replace the
stored value for the same key and must not preserve a removed key unless the
projection owner explicitly documents tombstone behavior.

Allowed `state` values for the first product slice are `creating`, `running`,
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

Workers may be assigned explicitly through `bus task ...`, or may claim an
approved available task when idle only after `docs/goals/tasks.md` has accepted
the canonical task claimability/queue contract and
`docs/goals/multi-environment-task-worker-refactor.md` has accepted bidirectional
relay for task claim, progress, and terminal evidence.

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
- pause/resume/assign create observable state transitions;
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

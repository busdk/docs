# Workers Goal

## Goal

This page is now the acceptance record for the first Bus workers MVP: local
native Services plus local sandboxed Codex Spark workers. The accepted product
surface creates and operates agent workers with durable identity, state,
assignment, and non-secret runtime metadata through the `bus workers ...`
product path.

The target UX is `bus workers ...`. In the accepted local scope, workers behave
like Bus-managed runtime resources: listable, creatable, pausable, resumable,
assignable, and observable through the local API/controller service and local
worker integration service.

The first acceptance scope is local sandboxed Codex workers only. A Codex
worker uses the public `appserver` / `codex-appserver` runner pair on the
selected local worker environment, with Codex sandboxing, Bus-managed Git
worktrees and branches, isolated `CODEX_HOME`, logs, scratch paths, and
non-secret runtime metadata. The implementation may run the App Server as a
host process inside the worker environment, but callers should not depend on
that private lifecycle detail. Remote worker environments, cross-environment
relay, container runners, and VM runners are adjacent goals, not acceptance
requirements for this first workers goal.

The first proof model for Codex/App Server workers is the raw model id:

```text
gpt-5.3-codex-spark
```

Pass that value through exactly for the first proof. Model aliasing or
normalization is not part of the first acceptance path, but the model should
remain configurable so later worker profiles can select different Codex models.

## Initial MVP User Story

The first MVP is deliberately small:

1. The operator uses the product command `bus workers ...` to request creation
   of a worker with model `gpt-5.3-codex-spark` and the required non-secret
   worker options. The plural `bus-workers` executable is the current product
   CLI binary for this path; the singular `bus-worker` binary remains a
   compatibility scaffold while the dispatcher form settles.
2. The system creates a UUID worker identity and records the selected model and
   related durable non-secret identity settings for that worker.
3. The system derives the worker identity branch from a configurable branch
   prefix and the UUID, defaulting to `worker/{worker_uuid}`, then asks
   `bus-integration-repos` to create, discover, or materialize that branch in
   the configured worker identity repository.
4. The system starts a Codex App Server session with sandboxing enabled, rooted
   in the worker's product worktree and with the worker identity worktree
   available as an allowed writable location.
5. The operator uses `bus workers ...` to communicate with the worker through
   bidirectional messages, similar to the previous task-thread communication
   model.
6. The worker operates on a task with live guidance from the supervisor.
7. The operator can request that the worker stop.

Anything not needed for that story is outside the first MVP unless explicitly
called back in. In particular, first-MVP workers do not need to auto-pick tasks,
run in containers or VMs, or prove remote environment support.

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

Internally, `bus-integration-workers` should use a runner-provider interface or
registry for runtime implementations. The first registered provider is local
host-run Codex through this environment's Codex runtime and sandbox. Later
providers, such as Docker/Podman/container Codex or VM Codex, should implement
the same internal provider interface instead of changing worker CLI, API,
Events, task, or scheduler callers.

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

Within those current checkouts, `bus-worker` owns only the product CLI/API
client UX. It must not own or persist worker identity data in local files such
as `.bus/worker/config.json`. `bus-api-provider-worker` owns the local
API/controller projection and canonical `bus.workers.*` request publication,
but it is still only a controller/projection surface. `bus-integration-worker`
owns persistent worker identity/state for its environment, worker-runner
selection, provider dispatch, lifecycle reconciliation, canonical status
snapshots, and the first direct Codex runner.

Supporting Bus modules are touched only through their boundaries:

- `bus-api` mounts the workers API provider but should not learn runner
  mechanics.
- `bus-agent` owns reusable Codex/App Server protocol clients and host runtime
  adapter mechanics. `bus-integration-workers` may depend on that boundary to
  deliver direct-runner guidance into a live App Server session, but worker
  callers must not learn App Server JSON-RPC or WebSocket details.
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
- `bus-api-provider-workers` owns the worker API boundary: it validates worker
  requests, publishes canonical `bus.workers.*` Events, and serves bounded
  worker projections. `bus-integration-workers` owns the actual worker claim,
  routing, launch, lifecycle transition, and runtime delivery behavior for the
  selected environment.

## Current Status

This first local sandboxed Codex workers goal is implemented, promoted, and
accepted for the Initial MVP User Story. The worker implementation was first
promoted from the isolated `codex/workers-direct` worktrees into the parent
module branches and then into the BusDK superproject at commit `a7a00be`
(`Promote local Codex workers MVP`). Later BusDK service-stack work, promoted
through commit `971e287` (`Group Bus service profiles by role`), adds a
top-level `services.yml` and public `profiles/` layout that can start the local
PostgreSQL-backed Events API, repos integration, workers integration, and
`bus-api` gateway needed for local Codex Spark workers. The accepted direction
remains the Initial MVP User Story above: a real long-running `appserver` /
`codex-appserver` Codex App Server/runtime instance, using
`gpt-5.3-codex-spark` for the first proof, this environment's Codex runtime and
sandbox, an `agents/worker` branch/worktree, and bidirectional guidance through
`bus-worker` / `bus-workers`.

Accepted evidence so far:

- The module feature branches have been fast-forwarded into their parent
  branches and the BusDK superproject pointer has been committed. Promoted
  module commits are: `bus-events` `ccfcfe5`, `bus-api-provider-events`
  `84a59da`, `bus-integration-repos` `1fc8253`, `bus-worker` `a93427f`,
  `bus-api-provider-worker` `0366d3c`, `bus-integration-worker` `0a688c6`,
  `bus-api` `669ba77`, and `docs` `b5e6add`.
- Promoted-checkout verification passed from the normal `projects/busdk`
  checkout. Unit tests passed with `go test ./...` in `bus-events`,
  `bus-api-provider-events`, `bus-integration-repos`, `bus-worker`,
  `bus-api-provider-worker`, `bus-integration-worker`, and `bus-api`.
  Product and provider e2es passed in `bus-api-provider-events`,
  `bus-worker`, `bus-api-provider-worker`, `bus-integration-worker`, and the
  worker product e2es `068-workers-provider-direct-events.sh`,
  `069-workers-product-direct-integration.sh`,
  `071-workers-product-repos-materializer.sh`, and the gated real Codex proof
  `070-workers-product-real-codex.sh` with
  `BUS_WORKERS_REAL_CODEX_PRODUCT_E2E=1`. The real Codex proof completed with
  `real codex product e2e OK`.
- `bus-worker` / `bus-workers` issue create, message, message-projection reads
  through the existing `bus-workers messages` path, and stop requests for the
  MVP story while remaining API-client-only. The product path has no persistent
  local worker identity store such as `.bus/worker/config.json`.
- The `bus workers ...` dispatcher form does not require worker-specific code
  in the public `bus` dispatcher. The dispatcher already resolves the first
  word to `bus-<command>` on `PATH`; with the feature-branch `bus-workers`
  binary on `PATH`, a smoke run of `bus workers --version` through the real
  dispatcher reached `bus-workers dev`. The worker CLI e2e now also runs a
  create/message/messages/stop lifecycle through the real dispatcher form
  `bus workers ...` against the API stub, while keeping the public dispatcher
  generic and free of private worker-module coupling.
- `bus-api-provider-workers` must remain an API/controller and projection
  surface, not the durable identity owner.
- Local CLI/API/provider/Event request shaping, App Server runner planning,
  host-process execution scaffolding, status projection, stop/logs/attach
  guidance, and the first `bus.workers.message.*` guidance Event path exist on
  the isolated feature branches.
- App Server WebSocket message delivery plumbing exists for the local
  host-process implementation, including bounded no-text/error evidence and
  idempotent worker-message projection when Events are replayed.
- The local product path now has a passing combined real-Codex proof for the
  first MVP lifecycle: `bus-workers create` can omit `--id`, the workers API
  provider generates a UUID identity, the request selects
  `gpt-5.3-codex-spark`, the App Server runner starts a long-running
  `appserver` / `codex-appserver` Codex App Server with sandboxing, the worker
  reaches `running`/`ready`, accepts task guidance through
  `bus-workers message`, returns projected assistant response evidence through
  `bus-workers messages`, exposes logs/attach evidence through the product
  path, and stops through the product path. The proof now runs through a real
  `bus-api-provider-events` memory backend with generated local JWT auth, not
  only the hermetic relay. This proof depends on
  `bus-integration-workers` seeding each isolated worker `CODEX_HOME` from the
  configured host Codex auth/config home before App Server startup.
- Repository/worktree ownership now has an Events-level product-path proof
  through the repos contract: `bus-integration-workers` publishes
  `bus.repos.ensure.request` for both worker workspaces, a real
  `bus-integration-repos` command backed by the repos processor/manager
  materializes them and returns safe `bus.repos.status.snapshot` evidence, and
  the UUID-named worker then reaches create/message/respond/stop through the
  product path. The repos-backed product e2e now also checks the actual Git
  branch refs in the configured repositories: `codex/workers/{worker_uuid}` for
  the product worktree and `worker/{worker_uuid}` for the worker identity
  worktree.
- The first generic Events addressing slice exists on the isolated feature
  branches: stream replay can be bounded with `limit` and `since` / `until`
  envelope timestamp ranges, filtered by generic platform metadata such as
  `bus.environment.id`, `bus.recipient.id`, `bus.parent.recipient.id`,
  `bus.service.kind`, and `bus.service.instance.id`, and PostgreSQL storage
  has indexed columns for those addressing dimensions plus event timestamp.
  This is intentionally generic Events API behavior, not a worker-specific
  transport.
- `bus-events` now has the shared platform metadata constants and Events API
  client listen options for generic metadata, limit, and timestamp-range
  filters, so the contract is not only a provider-local convention.
- Workers controller and integration events now stamp the generic addressing
  metadata they know. Worker create/control requests and integration
  status/message responses can carry the worker UUID as `bus.recipient.id`,
  plus environment, service-kind, and generated service-instance provenance
  where available, so worker projections can use the generic Events replay
  path.
- The workers API projection listener can pass generic metadata filters,
  `limit`, and `since` / `until` timestamp bounds to the Events stream, which
  gives the workers read side a concrete path to targeted projection
  hydration.
- `bus-api-provider-workers` now has a request-aware projection refresh path.
  Read endpoints for one worker can replay a bounded no-follow Events slice
  with `bus.recipient.id={worker_uuid}` and optional environment metadata
  before reading the projection, instead of relying only on broad worker Event
  replay.
- `bus-api` now wires that request-aware refresh hook when it mounts the
  workers provider. The repos-backed product e2e restarts `bus-api` after a
  worker has reached `running` and produced a message response, then proves a
  fresh in-memory projection can hydrate status and message history from
  Events through `bus.recipient.id`, `bus.environment.id`, `limit=100`, and
  `follow=false` query parameters. The real-Codex product proof also queries
  the real Events provider directly with the generated worker UUID as
  `bus.recipient.id` and confirms status and message response replay.
- `bus-integration-workers` startup hydration now replays canonical worker
  create requests as durable identity/configuration facts and status snapshots
  as lifecycle/runtime facts. The replay merge preserves non-secret create
  intent such as model, profile, runner provider, worker home reference, task
  reference, and workers-owned metadata while applying later status evidence.
- UUID worker identity defaulting now exists in the API-backed create path:
  callers may omit `--id`, `bus-api-provider-workers` generates the UUID and
  defaults `worker_home_ref` to `repos://workers/{worker_uuid}`, and
  `bus-integration-workers` derives the worker identity branch from a
  configurable prefix that defaults to `worker/`.
- `bus-api-provider-workers` now rejects malformed operator create requests
  more narrowly before publishing canonical Events: invalid supplied worker
  ids, unsupported worker types, invalid profile strings, duplicate or invalid
  routing identifiers, worker-home references outside `repos://workers/`, and
  direct-runner create requests that try to carry a container image fail
  closed with bounded API errors. `bus-integration-workers` also rejects
  canonical create Events whose worker id is unsafe before adding them to the
  control catalog.
- The workers API provider now accepts the documented optional `labels`
  create payload field, validates it as bounded structured string metadata,
  and passes it through on the canonical create Event. It also validates
  worker ids, environment ids, and message ids on control/message paths without
  rejecting operator text because it mentions or carries secret-like values.
- Worker labels now survive the local worker projection path instead of being
  create-only write data: `bus-integration-workers` carries labels in worker
  snapshots and replay hydration, and `bus-api-provider-workers` parses,
  merges, and clones labels in its in-memory worker projection.
- `bus-worker` / `bus-workers` API-backed create now exposes structured
  non-secret labels with repeated `--metadata-label key=value` flags, sends
  them as the canonical create payload `labels` object, and displays returned
  status labels as `label.{key}` rows. CLI help and version output now use the
  plural `bus-workers` / `bus workers` product surface, describe the product
  path as API-client-only, and keep the legacy local registry mode scoped to
  scaffold compatibility instead of claiming product ownership of
  `.bus/worker/config.json`. The `bus-worker` README no longer tells the
  normal product-path integration startup to pass `--workers-file`; it
  documents that file input as local scaffold/preflight compatibility only.
  The `bus-integration-worker` README now makes the same distinction: normal
  long-running service examples start from Events without `--workers-file`,
  while catalog files remain limited to offline preflight, `none` lifecycle,
  and legacy fixture compatibility.
- `bus-workers list` now keeps the API provider's projected worker view
  instead of collapsing list results to legacy identity-only rows. Text output
  includes the reporting environment id, status, lifecycle phase, active task
  ref, model, runner kind/provider, group ids, and worker-home reference; JSON
  output preserves the same projected status/view fields for supervisor
  tooling. The local scaffold list mode remains unchanged.
- API-backed `bus-workers show` now also uses the projected worker view rather
  than the legacy identity-only shape, so one-worker reads preserve
  environment id, status, lifecycle phase, active task ref, model, runner
  kind/provider, runtime/log/worktree references, labels, and bounded
  non-secret metadata consistently with `status`. The local scaffold `show`
  mode remains unchanged.
- API-backed `bus-workers create` now preserves the workers API provider's
  accepted projected worker view instead of decoding the response as a
  legacy identity-only worker. Text output still begins with
  `created worker <id>` for compatibility, then reports returned non-secret
  creation facts such as status, worker-home reference, environment id, model,
  task ref, lifecycle phase, runner kind/provider, and labels when present.
  JSON output preserves the same accepted worker view for supervisor tooling.
- API-backed `bus-workers message` and `bus-workers messages` now expose the
  bounded message delivery metadata needed for operator proof in text mode:
  `delivery`, `operation`, `thread_id`, `turn_id`, `runtime_event`,
  `runtime_error`, and `session_backend`. Message history rows print those
  facts as `message_metadata` rows keyed by `message_id`. Arbitrary or
  secret-shaped metadata remains JSON-only and is not printed in text output,
  so token-file-like fields do not leak into operator text logs.
- Worker API and integration Events now use the shared `bus-events` platform
  metadata constants for environment, recipient, service kind, and service
  instance addressing. `bus-api-provider-workers` generates a service-instance
  UUID when the handler is built, and `bus-integration-workers` uses an
  automatically generated process-local service-instance UUID when one is not
  supplied by an embedding host. Focused tests now cover both explicit
  service-instance ids and the no-configuration generated UUID path. Repos
  ensure requests produced by `bus-integration-workers` now carry the same
  generic service kind and service instance metadata as worker status and
  message response Events, so provider-adjacent Events remain attributable to
  the managing service without adding worker-specific fields to the Events API.
  The isolated worker modules now test against the `bus-events-contract`
  worktree through a review-only local workspace overlay, while their
  mergeable module `replace` paths still point at the normal sibling
  `../bus-events` module. This exercises the metadata contract before
  promotion without baking isolated worktree names into module files.
- Events-backed status projection hydration and an opt-in scheduler claim
  command proof exist, but scheduler ownership is outside first MVP
  acceptance.

Open blockers for first-scope acceptance: none.

The final first-scope blocker was the durable Events backend proof. After
PostgreSQL 18 was installed through Homebrew, a disposable local PostgreSQL
cluster was initialized under `/private/tmp`, the Events provider e2e was run
with `BUS_EVENTS_POSTGRES_E2E_DSN` pointing at that cluster, and
`bus-api-provider-events` completed with `e2e OK (bus-api-provider-events:
passed 1, skipped 0)`. That run exercised the PostgreSQL provider stop/start
step against the same DSN and replayed an Event published before restart.

Container and VM runners remain extension targets behind the same internal
`bus-integration-workers` provider interface. Remote worker hosts,
multi-environment relay, remote credential-source proof, and service-owned
Events relay are tracked by neighboring goals and are not blockers for this
initial local sandboxed Codex worker goal.

## Dependencies

The first-scope local worker dependencies are complete enough for this goal's
accepted MVP. The following neighboring contracts supplied the slices needed by
local sandboxed Codex workers, while their broader goals can continue without
blocking this accepted scope:

- The worker-needed `bus-events` / `bus-api-provider-events` slice now exists
  on the promoted parent branches: Events can be replayed with bounded
  generic metadata filters for environment, service, recipient, parent
  recipient, and event time range, with PostgreSQL indexes for the durable
  provider path. Broader Events relay/sync/provider hardening remains
  neighboring work, but it is not a local MVP blocker once this generic
  addressing slice is promoted. A worker UUID remains only one
  ordinary recipient/resource id under that generic Events contract; Events API
  must not hardcode worker semantics.
- The worker-needed repos slice now has product-path proof through
  `bus-integration-repos`: worker create materializes the product and
  worker-identity worktrees through repos Events and reaches
  create/message/respond/stop. The full [repos goal](/docs/goals/repos.md) may
  continue independently, but the local repos slice needed by workers has been
  reviewed, promoted, and included in the promoted-checkout proof.
- Explicit `bus workers assign` can be implemented and tested before idle
  claiming is complete. Task-side assignment remains owned by `bus-task`; both
  entry points should publish or route to the same `bus.workers.assign.request`
  contract when the target is a specific worker.

Idle worker task claiming, queue/capacity behavior, and scheduler-owned status
belong to the [tasks goal](/docs/goals/tasks.md) and the
[service-owned task scheduler goal](/docs/goals/service-owned-task-scheduler.md).
They may create or assign workers through the same canonical worker contract
later, but a service-owned scheduler/task-claiming loop is not an acceptance
requirement for the initial local sandboxed Codex worker product.

Remote worker hosts, service-owned Events relay, multi-environment worker
reads, and remote credential-source proof are tracked by
[service-owned Events relay](/docs/goals/service-owned-events-relay.md),
[multi-environment task and worker coordination](/docs/goals/multi-environment-task-worker-refactor.md),
and [remote credential source selection](/docs/goals/remote-credential-source-selection.md).
Those goals may reuse the workers Event contract, but they are not blockers for
accepting the local sandboxed Codex worker product path.
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

## Accepted Worker Contract

The accepted local MVP contract is that `bus workers list` calls the workers API
provider and lists visible workers from that provider's projection. It does not
read or maintain a `bus-worker` local identity registry. The response includes
enough information for a supervisor to understand where each worker lives and
what it is doing. In the first local sandboxed Codex scope, list responses
preserve the reporting worker environment id; multi-environment response
merging belongs to the remote/relay goals.

The accepted product surface supports:

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
files. `bus-worker` must not create or update an environment-specific
`.bus/worker/config.json` identity store; it is an API client only.
`bus-api-provider-workers` must not become the durable identity store either:
it is an API controller and bounded read projection over worker Events.
`--workers-file` in the current integration command is bootstrap input for
local development and preflight only.

The accepted persistent source for worker identity, configuration, desired
lifecycle, and audit history is the canonical Bus Events API history.
`bus.workers.*` Events record facts such as worker creation, display
name changes, model/profile configuration changes, desired runner provider,
sandbox policy, task assignment, desired lifecycle transitions, and status
snapshots. `bus-integration-workers` owns applying those Events in the
environment that can actually run the worker, and the service rebuilds
its projection from Events history rather than from a private local database or
metadata file. This keeps multi-environment sync aligned with the normal
Events API sync path instead of requiring every worker service to implement and
replicate its own persistent store.

Because worker identity/configuration is event-sourced, the accepted Events API
path supports targeted projection replay through generic recipient and parent
addressing metadata. `bus-integration-workers` and
`bus-api-provider-workers` can request bounded ranges of Events for one worker
UUID instead of replaying every `bus.workers.*` Event and filtering in process.
This is expressed as normal Events recipient querying, not worker-specific
transport: account scope comes from the JWT, authorization can restrict visible
Events, requests can filter by event names or prefixes, canonical recipient
UUID, optional parent/service/environment metadata, timestamp range, and
bounded `limit`. PostgreSQL-backed Events store indexed addressing fields and
event timestamps for this accepted local projection path. Broader Events relay,
cross-environment sync, and service deployment hardening remain in the
neighboring relay and multi-environment goals.

The Events API addressing model should reflect normal Bus topology without
becoming worker-specific. Bus deployments have environments identified by
UUID, long-running services inside those environments identified by service
instance UUID, and service-managed runtime or domain resources identified by
their own UUIDs. The simple delivery rule should be that an Event can be
addressed to one recipient UUID without using a separate module-specific send
API. Parent/ownership metadata then explains where that recipient currently
belongs. In this goal, a `bus-integration-workers` service instance can be a
recipient, and each worker under that service can also be a recipient. A
worker can later move to another service instance or environment when the
managing service publishes new generic ownership/parentage facts; the worker
UUID stays stable while its parent service/environment changes. The same
Events API model should also work for other services and resources. Useful
generic dimensions include origin
environment, current/source environment, destination environment, producing
service kind, producing service instance id, recipient id, recipient kind or
module-owned type label, parent recipient id, parent service instance id, and
optional group/capability labels. Authorization may use token claims to filter
visible Events automatically, and service-level tokens should be able to
request an explicit environment/service/recipient range only when their scopes
allow it. The Events API should own the canonical `bus.*` metadata field
names, validation, indexing, and auth semantics for these dimensions; fields
owned by a module should use that module's prefix, such as `workers.*` for
workers-owned metadata. Service instances should self-bootstrap their own
UUIDs and any required non-secret identity material, such as public keys if
that becomes part of the service identity contract, without requiring
deployment-time configuration. Deployment should only need ordinary service
configuration and credentials; identity metadata should be generated
automatically, then advertised through generic Events/service metadata rather
than hand-authored config files.

The configured worker identity repository remains important, but it is the
worker-editable Git workspace, not the service metadata database.
`bus-integration-workers` must use the repos configuration/contract to address
that repository, for example by a configured repos `repo_id` whose default
deployment may point at `agents/worker`. Repos-owned Git refs, worktrees, and
status snapshots are authoritative evidence for materialized repository state
and can be used for reconciliation: the worker branch, current revision,
dirty/locked indicators, and implementation branch provenance can confirm
whether the worker identity branch and product branch exist and are safe to
use. The intended worker display name, model settings, runner provider,
sandbox policy, and desired lifecycle come from Events history, not from files
inside the worker-editable worktree. Only one environment should run a given
worker at a time, even if identity data, Events, and Git refs are synchronized
between environments later.

The canonical worker identity id should be a UUID generated by the identity
owner when the operator does not provide one. The worker identity branch is
derived from that UUID by joining it to a configurable branch prefix. The
prefix defaults to `worker/`, so the normal identity branch is
`worker/{worker_uuid}`. Because the branch rule is deterministic,
`bus-integration-workers` can discover existing workers through
`bus-integration-repos` by listing or planning branches in the configured
worker identity repository under that prefix instead of maintaining a separate
registry file. The local worker identity worktree path is derived from the UUID
and the environment's worker root by the repos/materialization layer; it is a
materialization detail, not canonical identity.

Durable worker metadata that changes over time should be modeled as Events
rather than as a service-owned file in the worker worktree. The first Events
projection needs enough persistent facts to rebuild worker identity and
configuration after restart or environment sync: schema/version, worker UUID,
display name or label, creation time and creating environment id, worker
identity repo id, branch prefix, product repo id, product implementation
branch, intended runner kind/provider, intended model/profile and non-secret
model options, sandbox policy, optional active or intended task reference,
desired lifecycle state, and non-secret labels/capability/group hints. The
worker identity worktree may still contain worker-editable files such as
`AGENTS.md`, memory, task notes, and memo logs, but those files are the
worker's editable workspace. They should not be required for the service to
know which display name or model settings are currently intended.

Worker-scoped persistent Events must carry the same canonical
recipient/destination address that the generic Events API can index for
targeted replay. For the first workers contract this recipient id is derived
from the UUID identity, not from branch names, worktree paths, labels, or
display names. Existing request payloads keep `id={worker_uuid}` as the
canonical worker payload identity; the addressing metadata exists so generic
Events storage can locate one recipient's timeline quickly without hardcoding
worker payload semantics.

Worker Events should also carry generic environment and service-instance
provenance when it is known. For example, a status snapshot produced by
`bus-integration-workers` should identify the reporting environment UUID, the
service kind, the service instance UUID, and the worker recipient/resource UUID
through Events-owned metadata. Those fields are not worker-only concepts: they
describe where an Event originated, which service produced or owns the Event,
and which recipient/resource timeline the Event belongs to.

Persistent Events and identity/workspace status should avoid absolute
worktree, logs, scratch, and `CODEX_HOME` paths. Those paths are
environment-local runtime materializations. They may appear in status
snapshots, bounded diagnostics, or operator debug output, but the durable
identity/config projection should be reconstructable from Events plus the
configured repos status. Logs remain useful as local runtime evidence, such as
App Server stdout/stderr diagnostics, but their durable reference should be a
logical `logs_ref` or derived runtime path rather than an authoritative
identity field.

Each worker should get an isolated worktree and implementation branch
automatically. Repository and worktree policy should use the repos goal rather
than being duplicated in the worker integration service. The canonical
repository rules are in the [repos goal](/docs/goals/repos.md): create a
worker-owned worktree
from the configured source repository, use a unique implementation branch per
worker/task assignment, report dirty/locked/active states conservatively, and
never reset or delete a worker worktree as part of normal lifecycle control.

## Worker Runner Providers

Worker runner providers are the runtime implementations that actually start and
control Codex/App Server. They are replaceable implementation details behind
`bus-integration-workers`, not separate product APIs that every caller needs to
understand.

The first accepted stable worker control surface must support the `appserver`
runner kind. It should reserve the same canonical request/status fields for
later container and VM providers so those providers can be added without
changing worker callers:

- `appserver`: run a Codex App Server worker in the selected environment. The
  first local implementation may run that App Server as a host process with no
  Docker, Podman, VM, or nested virtualization. Isolation comes from the
  Bus-managed worktree and implementation branch, a worker-specific
  `CODEX_HOME`, logs and scratch directories, the configured Codex sandbox,
  and the host user's normal toolchain such as `git`, `go`, `make`, Bus
  binaries, and module-local test scripts. This is the preferred first runner
  for local macOS proof and for environments where virtualization is
  unavailable or unnecessary. The product worktree is the primary Codex
  workspace; worker identity, logs, and scratch paths are additional writable
  roots, and each live App Server worker needs a deterministic non-conflicting
  local endpoint or session reference.
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
The required extension point is inside `bus-integration-workers`: an internal
runner provider registry or equivalent interface that maps worker
create/control requests to provider-specific lifecycle operations, redacts
provider output, and converts provider-specific state back into the canonical
worker status view.

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
small host-process adapters, or delegate to another integration module when
that module owns the lower-level runtime. In particular, the container
provider should delegate container lifecycle mechanics to
`bus-integration-containers` or a stable container integration boundary, while
the Codex App Server provider should own host process/session launch and
worker-local filesystem preparation. A later VM provider should plug into the
same registry without changing the worker Event contract.

Provider acceptance is staged. The first accepted implementation should prove
`appserver` / `codex-appserver` through command-backed host execution and the
normal worker API/Event path. The same registry and status contract must
already make room for additional providers, but `container`, `docker`,
`podman`, or `vm` must not be reported as working merely because the request
fields exist. Until
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

Worker-scoped Events that are durable identity, configuration, lifecycle,
status, or message facts must also carry generic Events addressing metadata so
Events API replay can select them without inspecting payload JSON. The exact
metadata keys should be owned by the Events API, not by workers. The canonical
source/origin environment field remains `bus.origin.environment.id`;
`bus.environment.id` is only the current/local environment or compatibility
filter field and must not replace origin provenance. Other platform
addressing fields include `bus.destination.environment.id`,
`bus.service.kind`, `bus.service.instance.id`, `bus.recipient.id`, and
`bus.parent.recipient.id` when the Events contract standardizes those names.
Only platform-standard fields should use the `bus.*` prefix. Worker-owned
metadata should use the workers module prefix, such as `workers.id`,
`workers.kind`, or another `workers.*` key if a separate module-owned field is
needed. In this goal, the generic recipient id is the worker UUID, but that is
data in a generic addressing model rather than worker-specific Events API
behavior. The same worker UUID stays in payload field `id` for the workers
contract; the metadata is for generic Events indexing, auth filtering, relay,
and projection hydration. Events that intentionally are not addressed to one
recipient, such as broad list discovery, do not need this recipient id.

The canonical worker payload identity field is `id`, matching the current
`bus-worker`, API-provider, and integration-provider code. For durable worker
identities, `id` should be a UUID; human-readable names belong in `label` or
metadata instead of the identity. If a future schema wants `worker_id`, it must
be introduced as an explicit migration or alias rather than silently replacing
`id`. The canonical status field is `status`, not `state`, for the current
product slice.

The first interoperable payload contract must include these names and fields:

- `bus.workers.create.request`: required string fields `id`, `label`, `type`,
  and `profile`; optional string fields `environment_id`, `model`, `module`,
  `branch`, `runner_kind`, `runner_provider`, `image`, `sandbox`,
  `prompt_file`, `prompt`, `worker_home_ref`, and `task_ref`; optional string
  arrays `capability_tags`, `eligible_environments`, and `group_ids`;
  optional object field `labels`.
  `task_ref` on a worker create request is worker association evidence for the
  selected worker environment. It is not a task-thread launch command and does
  not move task ownership into the workers provider.
  Operator-facing create input may omit `id`; in that case the API/provider or
  identity owner must generate a UUID before publishing the canonical
  `bus.workers.create.request` Event, include that generated `id` in the
  Event payload, and return it to the caller. Durable identity branch names are
  derived from the worker identity branch prefix and this UUID; the branch
  prefix is integration configuration and defaults to `worker/`. Integration
  services consuming `bus.workers.create.request` Events must reject a missing
  or invalid `id`.
  For create mutations, the API/provider must select exactly one target worker
  environment before publishing: either explicit `environment_id` or exactly
  one eligible environment selected by documented local policy. Ambiguous
  create requests must fail closed instead of being broadcast.
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
  promoted local product-path proof covers stop for the first accepted MVP:
  the operator can request stop through `bus workers`, the request is published
  through the Workers API/Event path, `bus-integration-workers` stops the
  Codex App Server runner, and projected status reaches `stopped`.
- `bus.workers.assign.request`: required string fields `id` and `task_ref`;
  optional string fields `environment_id`, `assignment_id`, and `reason`.
- `bus.workers.message.request`: required string fields `id` and `text`;
  optional string fields `environment_id`, `message_id`, and `task_ref`.
  This is the first worker guidance channel for operator-to-worker task
  details. `text` must be bounded, non-secret guidance suitable for Events;
  private or long prompts need a later `prompt_ref` / task-thread reference
  resolved inside the worker environment. If a client omits `message_id`, the
  API provider must generate a stable non-secret id, use it as the Event
  correlation id, return it in the accepted request response, and require the
  integration response/history row to use that same id.
- `bus.workers.message.response`: required string fields `environment_id`,
  `id`, `message_id`, and `status`; optional string fields `worker_id`,
  `direction`, `role`, `text`, and `runtime_ref`; optional object field
  `metadata` for bounded non-secret delivery evidence. The Codex App Server
  provider should report delivery evidence such as delivery method, operation
  (`turn/start` or `turn/steer`), thread id, turn id, and endpoint reference,
  while keeping the App Server protocol details private to `bus-agent` and
  `bus-integration-workers`. If the App Server turn completes,
  interrupts, exits, or reaches the configured evidence timeout without
  assistant text, the response should distinguish completed/no-text evidence
  from failed runtime evidence and include only a bounded redacted diagnostic
  such as `runtime_event` or `runtime_error`. Projections must treat repeated
  response Events for the same worker
  environment and `message_id` as an upsert, not a new message row, because
  API read-refresh may replay the same Events many times.
  Allowed message response `status` values for the first product slice are
  `accepted`, `delivered`, `responded`, `completed`, `no_text`, and `failed`.
  `accepted` means the worker API/provider accepted the operator guidance
  before runtime delivery evidence is available. `delivered` means the
  integration service handed the guidance to the live runner or App Server.
  `responded` means bounded assistant or worker response text is available in
  the Event. `completed` means the runtime completed the turn without an error
  and may have only metadata evidence. `no_text` means the runtime completed or
  reached the evidence timeout without assistant text but with non-secret
  delivery evidence. `failed` means delivery or runtime evidence failed with a
  bounded redacted diagnostic. Projections should keep the newest Event for
  each `(environment_id, id, message_id)` key and may show earlier statuses in
  audit history through raw Events replay.
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
  `app_server_url` must be a token-free loopback or logical endpoint
  reference. If an endpoint requires auth material or would embed credentials,
  status should expose only `logical_endpoint`, `runtime_ref`, or another
  non-secret attach reference instead.
  `worktree_path` and `logs_path` are accepted local direct-runner evidence
  fields, while `worktree_ref` and `logs_ref` preserve the durable-reference
  direction for repos/artifact-owned locations. `container_id` is future-only
  for container runners and belongs to the worker runner providers goal;
  non-container runners use provider-neutral `runtime_ref` or bounded metadata.
  Accepted direct-runner metadata includes `codex_home`, `scratch_path`,
  `sandbox`, `session_backend`, and `writable_roots` when available; because
  `metadata` is string-to-string, `writable_roots` is encoded as a
  comma-separated string until a later typed status field exists. Remote
  provenance metadata belongs to the multi-environment and relay goals, not the
  accepted local worker contract.
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
The first worker contract reserves `appserver` and `container` runner kinds,
with `vm` reserved for a later runner. Reservation is not the same as
execution support: an environment may accept only the providers it has
registered, and unsupported kind/provider pairs must fail closed rather than
falling back to a different runner. `runner_provider` is a non-secret provider
id such as `codex-appserver`, `docker`, `podman`, or a later VM provider id.
Redaction rule:
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

Validation must fail closed and publish or return a bounded structural error
instead of guessing. Invalid create/control requests should not be silently
normalized into a different worker:

- reject missing or invalid `label`, `type`, or `profile` on
  operator-facing create, and reject invalid `id` when one is supplied;
- reject canonical `bus.workers.create.request` Events with missing or invalid
  `id`, because any operator-facing id generation must happen before Event
  publication;
- reject `type` values outside `human`, `automaton`, and `agent`;
- reject `profile` values with whitespace, `@`, or `#`;
- reject `capability_tags`, `eligible_environments`, and `group_ids` that do
  not match the normalized identifier rules, and reject duplicates after
  normalization instead of preserving ambiguous values;
- reject `worker_home_ref` values with whitespace or references outside the
  accepted integration-owned worker identity namespace;
- reject `labels` or `metadata` with invalid keys, non-string values, values
  over the documented size limit, or too many keys;
- reject unsupported `runner_kind` / `runner_provider` pairs with a bounded
  failed worker snapshot or controller error, rather than falling back to a
  different runner;
- reject provider-specific fields that are incompatible with the selected
  runner, such as a Codex App Server request that requires a container image
  as its execution source.
- reject message requests without a target worker id, without bounded text, or
  with text that is too large for the Events channel.

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
should map to `bus.workers.assign.request` once they cross the API/Event
boundary. A worker create request may include `task_ref` only as association
evidence for the worker service; it is not a task-thread launch command. The
first local sandboxed Codex worker version does not need workers to auto-pick
approved tasks. It does need bidirectional communication so the operator or
task-side UI can provide task details to the selected long-running worker and
receive enough response, status, logs, or attach evidence to keep guiding it.
Idle workers may claim an approved available task only after the task and
service-owned scheduler goals have accepted the canonical claimability, queue,
capacity, and scheduler-owned status contracts.

Public Codex App Server workers use `runner_kind=appserver` and
`runner_provider=codex-appserver`. Older direct-runner names are compatibility
or internal lifecycle details and should not be expanded in the public worker
API surface.

## Accepted Criteria And Evidence Map

This goal is accepted because the promoted implementation and proof satisfy
these criteria:

- `bus workers` is the documented product CLI for worker identity and control;
- the local API provider publishes and projects canonical `bus.workers.*`
  requests/evidence;
- the Events API can efficiently replay bounded environment/service/
  recipient/destination-scoped history by canonical generic addressing
  metadata and event range, with an indexed durable backend path suitable for
  rebuilding one worker projection when the recipient/resource is a worker
  UUID;
- the integration provider consumes those Events and controls real local
  worker lifecycle through a runner-provider interface;
- the `appserver` runner kind can be selected and executed through canonical
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
  `appserver` / `codex-appserver`, an isolated product worktree and branch,
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
  integration consumption, worker lifecycle execution, actual bidirectional
  message delivery for task details and worker response evidence, supplemental
  logs/attach evidence, status projection, stop, and non-secret evidence.

## Post-Promotion Acceptance Audit

As of BusDK commit `a7a00be`, the first-scope local Codex-worker
implementation was promoted from the isolated `codex/workers-direct` worktrees
into the parent module branches and the BusDK superproject. The promoted
checkout was rerun through the local product-path verification set. The later
gated PostgreSQL Events backend restart proof also passed after PostgreSQL 18
was installed locally and a disposable cluster was started for the proof run.
Subsequent BusDK service-stack commits, through `971e287`, make the accepted
worker use case easier to run locally with `bus services up`; they do not add a
new first-MVP worker acceptance blocker.

`bus workers` product CLI evidence is covered by `bus-worker` unit tests,
`bash tests/e2e.sh`, README updates, plural `bus-workers` binary output, and
the mounted `bus-api` product e2es that drive `bus-workers create`, `message`,
`messages`, `logs`, `attach`, `status`, and `stop`.

The dispatcher path does not require worker-specific code in the public `bus`
module. The dispatcher already resolves the first command word to a
`bus-<command>` executable on `PATH`, so `bus workers ...` resolves to
`bus-workers ...` when the plural worker binary is installed. This has been
checked with the current `bus` dispatcher and the isolated feature
`bus-workers` binary before promotion, and with the promoted `bus-workers`
binary after promotion. The worker CLI e2e now discovers the real public
dispatcher when available and proves create/message/messages/stop through
`bus workers ...`.

Canonical local API/provider/Event projection evidence is covered by
`bus-api-provider-worker` tests and the product e2es. The API provider
publishes canonical `bus.workers.*` Events, validates create/control/message
requests, generates UUID worker ids when omitted, preserves projected create,
list, show, status, logs, attach, and message fields, refreshes one-worker
projections from bounded recipient-scoped Events replay, and redacts
secret values only at logging/output boundaries instead of rejecting worker
communication based on content heuristics.

Generic Events API addressing evidence is covered by the
`bus-events-contract` and `bus-api-provider-events` tests. Events support
bounded `limit`, `since`, and `until` replay with generic metadata filters for
environment, destination environment, service kind, service instance,
recipient, and parent recipient. PostgreSQL stores indexed columns for those
addressing fields and event timestamp. Workers use those fields as ordinary
recipient/resource metadata rather than hardcoding worker semantics into the
Events API.

Integration-provider and runner-interface evidence is covered by
`bus-integration-worker` tests and product e2es. The integration provider
hydrates from create/status Events, consumes create/pause/resume/assign/stop/
message requests, emits status/message/list evidence with generic addressing
metadata, supports generated service-instance UUIDs without configuration, and
routes execution through provider interfaces so the first `appserver` /
`codex-appserver` provider does not force container or VM assumptions on
callers.

Local Codex App Server runner evidence is covered by lifecycle tests and the
gated real-Codex product e2e. The runner creates isolated product and worker
identity worktrees, derives the worker identity branch from the configurable
branch prefix defaulting to `worker/`, seeds isolated `CODEX_HOME` from the
configured host Codex home, starts a long-running sandboxed Codex App Server,
delivers bounded operator guidance, returns response/delivery evidence, exposes
logs/attach information, and stops the worker through the product path. The
repos-backed product e2e also inspects fake Codex startup evidence under the
isolated `CODEX_HOME` and asserts that the App Server launch argv contains
`model=gpt-5.3-codex-spark`, `sandbox_mode=workspace-write`, and `--add-dir`
entries for the worker identity, logs, and scratch workspaces. It also checks
that the fake Codex process starts from the product worktree, so the proof is
not limited to projected metadata.

Repos-owned worktree materialization evidence is covered by
`bus-integration-repos` tests and
`tests/e2e/071-workers-product-repos-materializer.sh`. In that proof,
`bus-integration-workers` publishes `bus.repos.ensure.request` for both
product and worker-identity workspaces, `bus-integration-repos` materializes
the worktrees, returns repos status evidence, and the worker proceeds through
create/message/respond/stop. The worker-side repos client uses per-request
unique correlation ids, so persistent Events replay cannot satisfy a new
workspace ensure request with an older status snapshot for the same branch and
worktree. The repos roundtrip assertion now verifies that the worker-identity
ensure request uses the deterministic branch `worker/{worker_uuid}`, matching
the default configurable worker identity branch prefix rule. It also checks
that repos ensure Events, repos status snapshots, worker snapshots, and worker
message response Events carry generic environment, service kind, service
instance, and recipient metadata where applicable, with UUID-shaped service
instance ids. The `bus-integration-repos` command now listens for repos
requests through Events API unicast delivery with the shared
`bus-integration-repos` service group and its generated service instance UUID
as the consumer id, so multiple repos service instances can compete for the
same generic request stream without every instance processing the same
request. The repos-backed product e2e now verifies that subscription shape in
the live Events stream query log, not only in command-level unit tests. The
same e2e now also verifies
bidirectional guidance content: the operator message text is echoed by the
fake Codex App Server as worker response text, and that response text is still
visible after `bus-api` restarts and hydrates the worker message projection
from Events. It also exercises product `logs` and `attach` output for the
repos-backed direct worker, checking worker id, logical logs ref, process
runtime ref, App Server URL, product worktree, worker identity worktree,
isolated `CODEX_HOME`, and that text output does not expose token material.

Container and VM behavior remains out of this first acceptance scope. The
current contract keeps `runner_kind`, `runner_provider`, and provider-private
mechanics behind `bus-integration-workers`; no Docker, Podman, container image,
or VM field is required for the `direct` local Codex product path.

State-transition and environment-identity evidence is covered by focused tests
and e2es for pause, resume, assign, stop, list, show, status, and bounded
projection refresh. The control-path audit includes `bus-worker`
`TestAPICommandsUseExpectedHTTPMethodsAndBodies` and `tests/e2e.sh` for CLI
request shaping, `bus-api-provider-worker`
`TestWorkersControlPublishesEnvironmentIDForPauseResumeAssign`,
`TestWorkersAPIProductPathProjectsDirectWorkerLifecycle`, and
`TestWorkersAPIProductPathUsesIntegrationWorkerDirectLifecycle` for request
publication and projection, `bus-integration-worker`
`TestWorkerControlRequestsPublishStatusSnapshots`,
`TestWorkerLifecycleReceivesControlRequests`, and
`TestRunnerSelectingLifecycleDelegatesControlByWorkerRunner` for integration
consumption/provider delegation, and `bus-api`
`tests/e2e/068-workers-provider-direct-events.sh` for mounted product Events
through `bus-api`. The real-Codex and repos-backed product e2es cover the
MVP-required stop path against a live worker. List/status/read paths preserve
`environment_id`, and worker ids are environment-qualified in projection
storage where needed.

Promoted-checkout test evidence includes `go test ./...` in `bus-events`,
`bus-api-provider-events`, `bus-integration-repos`, `bus-worker`,
`bus-api-provider-worker`, `bus-integration-worker`, and `bus-api`; `bash
tests/e2e.sh` in `bus-worker`, `bus-api-provider-worker`, and
`bus-integration-worker`; `bash tests/e2e.sh` in
`bus-api-provider-events` with the memory backend; `bash
tests/e2e/068-workers-provider-direct-events.sh`; `bash
tests/e2e/069-workers-product-direct-integration.sh`;
`BUS_WORKERS_REAL_CODEX_PRODUCT_E2E=1 bash
tests/e2e/070-workers-product-real-codex.sh`; and `bash
tests/e2e/071-workers-product-repos-materializer.sh`. Documentation and diff
hygiene checks also pass after the post-promotion goal update with
`bus lint docs/goals/workers.md` and `git diff --check`.

Durable Events backend proof was completed after promotion by running `make
e2e` in `bus-api-provider-events` with
`BUS_EVENTS_POSTGRES_E2E_DSN=postgres://bus_events@127.0.0.1:<ephemeral-port>/bus_events?sslmode=disable`
against a disposable PostgreSQL 18 cluster. The run completed with
`e2e OK (bus-api-provider-events: passed 1, skipped 0)`, covering PostgreSQL
publish/listen, unicast acknowledgement, provider restart against the same
DSN, replay of a pre-restart Event, and dead-letter behavior.

Before promotion, a 2026-05-31 refresh reran the full isolated-worktree test
set with the review-only `worktrees/workers-direct/go.work` overlay for module
tests. That evidence is historical now, but it explains the review sequence
that led to the promoted commits. The gated real-Codex product proof passed with
`BUS_WORKERS_REAL_CODEX_PRODUCT_E2E=1`, exercising the local Codex runtime
through create, ready status, logs/attach, bidirectional guidance, Events
recipient replay after `bus-api` restart, and stop. A follow-up
pre-promotion review tightened repos ensure correlation ids and reran
`go test ./pkg/workersintegration`,
`go test ./cmd/bus-integration-workers`,
`bash tests/e2e/071-workers-product-repos-materializer.sh`, and the gated real
Codex product e2e successfully. A subsequent review also made
`bus-integration-repos` stamp its own service kind and generated service
instance id on repos response/status/error Events, then reran
`go test ./...` in `bus-integration-repos`, the repos-backed product e2e, and
the gated real Codex product e2e successfully. The next hardening pass made
the `bus-integration-repos` command consume repos request Events through
unicast service-group delivery while reusing the same generated service
instance UUID for response metadata and consumer identity; `go test
./cmd/bus-integration-repos ./pkg/reposintegration`, `go test ./...` in
`bus-integration-repos`, the repos-backed product e2e, and the gated real
Codex product e2e passed afterward. The repos-backed product e2e was then
tightened to assert the repos service's live Events stream query uses
`delivery=unicast`, `group=bus-integration-repos`, and a UUID-shaped
`consumer`; the strengthened e2e passed. A later product-path assertion pass
also checked the fake Codex launch evidence for worker identity/logs/scratch
`--add-dir` writable roots and product-worktree current working directory,
then reran the repos-backed product e2e successfully. The worker CLI e2e was
then tightened so it discovers the real public `bus` dispatcher when available
and proves create/message/messages/stop through `bus workers ...`; `bash
tests/e2e.sh` passed with that dispatcher lifecycle proof. The
`bus-api-provider-events` PostgreSQL e2e was also tightened to stop and
restart the Events API provider against the same DSN, then replay an event
published before restart; this proof is gated by `BUS_EVENTS_POSTGRES_E2E_DSN`.

## Post-Promotion Handoff

Promotion has already happened in dependency order. The parent module branches
now include the worker-needed Events contract, Events provider, repos
integration, worker CLI, workers API provider, workers integration provider,
`bus-api` product wiring, and this docs goal. The BusDK superproject commit
`a7a00be` recorded those worker submodule pointers, and later BusDK commits
added the local Services stack that can start the required worker services from
`services.yml`.

No first-scope product blocker remains for local sandboxed Codex workers.
Unfinished work outside this accepted MVP has been routed to neighboring goals
instead of remaining as acceptance work here:

- automatic task-picking, atomic task claims, queue/capacity behavior, and
  scheduler-owned worker launch belong to the
  [service-owned task scheduler goal](/docs/goals/service-owned-task-scheduler.md)
  and the task contracts in the [tasks goal](/docs/goals/tasks.md);
- remote environment operation, multi-environment worker reads, and worker
  request/evidence routing belong to the
  [multi-environment task and worker coordination goal](/docs/goals/multi-environment-task-worker-refactor.md);
- service-owned Events relay and durable relay status belong to
  the [service-owned Events relay goal](/docs/goals/service-owned-events-relay.md);
- remote credential-source proof belongs to
  the [remote credential source selection goal](/docs/goals/remote-credential-source-selection.md);
- systemd/user-service deployment and broader service operations belong to
  the [systemd user deployment goal](/docs/goals/systemd-user-deployment.md);
- container-backed and VM-backed worker runners belong to
  the [worker runner providers goal](/docs/goals/worker-runner-providers.md).

## Appendix: Compact Implementation History

This appendix is a compact changelog for the accepted local workers MVP. Older
implementation notes that described unaccepted remote, scheduler, container, VM,
or relay work have been routed to the neighboring goal files named in the
Post-Promotion Handoff.

### 2026-05-31 Scope Narrowing

The workers goal was narrowed to local sandboxed Codex workers. Remote worker
hosts, cross-environment Events relay, remote credential-source proof,
container runners, VM runners, and automatic idle-task claiming were made
adjacent goals rather than acceptance requirements here. The accepted worker is
a real long-running Codex App Server runtime using this environment's Codex
runtime and sandbox with the raw model id `gpt-5.3-codex-spark`.

### Codex App Server Runner And Product Path

The first accepted public runner pair is `appserver` / `codex-appserver`. It
creates isolated product and worker-identity worktrees, derives the worker
identity branch from the worker UUID, seeds isolated `CODEX_HOME`, starts a
sandboxed Codex App Server, accepts operator guidance through
`bus workers message`, exposes response/status/logs/attach evidence, and stops
through the product path.

### Events And Repos Proof

Worker state is reconstructed from canonical `bus.workers.*` Events rather than
from local worker files. Events replay supports bounded generic addressing
filters for worker-recipient projections, and PostgreSQL-backed Events proof
covered provider restart and replay. Repos-owned worktree materialization is
accepted for the local worker path through `bus-integration-repos` and
`bus.repos.ensure.request` / `bus.repos.status.snapshot` Events.

### Dispatcher And Services Stack

The public dispatcher form `bus workers ...` resolves to the plural
`bus-workers` product CLI. Later local Services work added a top-level
`services.yml` and `profiles/` layout that can start PostgreSQL, Events API,
repos integration, workers integration, and `bus-api` for the accepted local
worker use case with `bus services up`.

# Multi-Environment Task/Worker Refactor Handoff

## Purpose

This handoff captures the state of the long-running conversation about the
BusDK multi-environment task and worker refactor. It is written so a new
conversation thread can resume the same goal without needing the original chat.

The active objective is to make `bus-task` the generic multi-environment
task/thread system, move proactive worker behavior into worker-owned modules,
keep runtime/provider execution in `bus-agent`, preserve local and remote
worker environments in one Bus deployment, document the new architecture, and
verify and commit the finished changes.

The goal is not complete. A lot of foundation work has landed, and the local
Spark worker lane is now usable, but the full end state still needs more
module-by-module implementation and proof.

Update from the supervisor-host continuation: this macOS supervisor checkout
does not have local Docker and should not try to prove Docker-backed workers
locally. The current target topology is local Bus control/task review on the
supervisor host, with Docker-backed workers running on
`coding-agent@dev.hg.fi` and Events evidence relayed or tunneled between the
two sides until a service-owned relay replaces the temporary proof path.

Update on 2026-05-29: the operator explicitly asked to use the
`coding-agent@dev.hg.fi` environment for remote Codex/App Server container
workers with the raw model id `gpt-5.3-codex-spark`. Do not treat the old
"approval-gated" note as a product-level blocker. The remaining gates are
operational: the remote worker image must exist, the remote checkout must be
clean enough to create task worktrees, and normal sandbox/SSH escalation must
be approved when the local supervisor tool asks for it.

Bootstrap sub-goal added on 2026-05-29: before depending on the unfinished
`bus-workers`/`bus-api-provider-workers`/`bus-integration-workers` control
plane, build and use a minimal manual Spark worker launcher for development
acceleration. This bootstrap lane must not depend on `bus-task`, Bus Events,
workerroute, Events proxying, or any worker provider implementation. It should
only create an isolated Git worktree and implementation branch on
`coding-agent@dev.hg.fi`, start a Docker container from the existing Codex
worker image, run Codex App Server with `gpt-5.3-codex-spark`, and expose a
manual attach/control path for the supervisor. It must support multiple
parallel workers by using unique worker names, isolated worktrees, isolated
`CODEX_HOME` directories, isolated containers, and race-safe remote startup.
Each worker should also get a worker-local `AGENTS.md` containing its task and
supervisor constraints, with the BusDK checkout mounted below it at
`/workspace/projects/busdk` inside the container. Worker-local prompts,
metadata, notes, and evidence should live under a per-worker temp root such as
`tmp/workers/{worker}`, with `/workspace/logs` mounted inside the container for
scratch notes and command evidence. Once this manual lane can run parallel
implementation workers, use it to finish the product control-plane modules
faster; only after those slices are available should e2e/integration testing
return to the foreground.

Manual Spark worker proof update on 2026-05-29: the bootstrap launcher now
starts live-guided Codex App Server containers on `coding-agent@dev.hg.fi`
instead of `codex exec` workers. The command surface is
`scripts/manual-dev-hg-spark-worker.sh start|prompt|attach|logs|status|stop`.
`start` creates the isolated remote worktree, branch, worker `AGENTS.md`,
worker-local logs, worker-local `CODEX_HOME`, App Server container, and
remote-only WebSocket port. `prompt` and `attach` connect the supervisor to the
container through the live TUI using `gpt-5.3-codex-spark`, which is the right
shape for guided work. A real-work test launched three parallel workers for
the workers integration, API provider, and CLI slices. All three produced code
and unit-test evidence in their assigned module worktrees, which proves the
manual lane is usable for parallel implementation. Supervisor review is still
required before promotion: worker-produced diffs are not accepted merely
because a worker reports passing tests.

Accepted parallel worker implementation update on 2026-05-29: the first
unit-test-only implementation phase has now accepted and pinned four worker
lanes. `bus-worker` has the API-backed `bus workers` CLI path for list/show,
create, pause/resume/status, assignment, and token/API URL handling.
`bus-task` surfaces worker assignment metadata and claimability contracts.
`bus-integration-worker` aligns the App Server lifecycle plan/exec boundary
with the manual worker shape. `bus-api-provider-worker` now has a file-backed
durable workers projection selected by `--projection-file` or
`BUS_WORKERS_PROJECTION_FILE`, while keeping the memory projection default for
ephemeral tests. Focused and full unit tests passed for each accepted lane.
This closes the first parallel implementation slice, but it does not complete
the product goal: bus-api mounting, service-owned local/remote Events relay,
remote container lifecycle proof through `bus.workers.*`, proactive task
claiming, and integration/e2e testing remain open.

Launcher correction from that proof: live worker sessions must start with
`-C /workspace/projects/busdk/$module` so code lands inside the assigned
module. The first proof also showed why the supervisor must inspect both the
superproject status and the submodule status for each remote worktree before
accepting or merging worker output.

Smallest product path from the manual proof: do not design a second worker
launcher. The first `bus-integration-workers` remote worker lifecycle should be
the remote half of `manual-dev-hg-spark-worker.sh` moved behind a small Go
launcher interface and driven by `bus.workers.*` Events. The local side should
remain thin: `bus workers ...` calls the local `bus-api-provider-workers`
service; that provider publishes canonical Events and maintains a bounded
read projection; the remote `bus-integration-workers` service consumes the
proxied Events, creates/stops/resumes/assigns Codex App Server containers using
the same worktree, `AGENTS.md`, logs, `CODEX_HOME`, model, and port allocation
rules as the manual script, then publishes `bus.workers.status.snapshot` and
`bus.workers.list.response` evidence. This keeps the first productized version
almost identical to the manual path while replacing SSH supervision scripts
with Bus Events and provider ownership.

Follow-up implementation update on 2026-05-29: the local
`bus-integration-worker/pkg/workersintegration` scaffold now has the first App
Server lifecycle boundary. `WorkerLifecycle` is called from
create/pause/resume/assign handlers, and `AppServerLifecycle` builds a
redacted launch recipe that mirrors the manual dev-hg Spark launcher paths,
worker-local `prompt.md`, worker `AGENTS.md`, `meta.env`, mounts, model, port,
`CODEX_HOME`, token-file handling, and Docker command shape. The
`bus-integration-workers` command defaults to `--lifecycle appserver-plan`, so
create status snapshots include non-secret `container_id`, `worktree_path`,
`logs_path`, and `app_server_url` metadata. It also has an opt-in
`--lifecycle appserver-exec` mode backed by `LocalAppServerLaunchRunner`,
which writes prepared files, runs argv-style local commands, reuses existing
worktree/token markers, redacts sensitive command output, and maps
pause/resume to Docker stop/start. `bus-api-provider-worker` now preserves
those lifecycle fields in its bounded projection. This is still not full
product completion: free ports are not allocated by the service, existing
branch/worktree reuse still needs the manual launcher's behavior, the
`appserver-exec` path has not yet been proven on `coding-agent@dev.hg.fi`, and
the container lifecycle has not yet been driven end to end through proxied
`bus.workers.*` Events.

Events relay/sync update on 2026-05-29: `bus-events` sync filters now include
the canonical multi-environment control-plane names needed by this goal.
Local-to-remote sync can replay `bus.workers.create.request`,
`bus.workers.pause.request`, `bus.workers.resume.request`,
`bus.workers.assign.request`, `bus.workers.list.request`, and canonical
`bus.task.*` lifecycle events while keeping legacy `bus.dev.task.*`
compatibility. Remote-to-local sync can replay `bus.workers.status.snapshot`,
`bus.workers.list.response`, and canonical task evidence. Focused unit coverage
asserts that worker create/list requests are requested from the local side,
worker status/list evidence is requested from the remote side, and the synced
events receive the correct per-environment sync-state metadata. This is not the
full service-owned relay proof yet: continuously running local and remote
`bus-events` services, credentials, and end-to-end proxied worker control still
need to be verified.

Events API ACL update on 2026-05-29: the current
`bus-api-provider-events` checkout has default ACL coverage and handler tests
for canonical `bus.workers.*` events. Worker create/update requests require
`workers:write`, pause/resume/assign requests require `workers:control`,
status/list evidence requires `workers:read`, unknown worker events require
`workers:admin`, and broad `events:send`/`events:listen` scopes are rejected
for protected worker names. The same slice also protects canonical
`bus.task.*` events with `task:*` scopes. Focused verification passed for
`go test ./pkg/eventsapi ./cmd/bus-api-provider-events` with sandbox-local Go
caches after downloading the missing PostgreSQL driver dependency.

Remote worker image update on 2026-05-29: the actual
`bus-integration-task:local-image-smoke` image on `coding-agent@dev.hg.fi` was
rebuilt with Codex CLI `0.135.0` using checksum-pinned Linux musl release
archives. Runtime verification on the remote host returned `codex-cli
0.135.0` and image id
`sha256:a2ad4d75d426f5211076197b372dc3ff3e431a21eeecc8d248bf84632a2c07ae`.
Checked-in image defaults were also updated from `0.134.0` to `0.135.0` so
future image rebuilds do not regress the remote worker runtime.

Operator correction on 2026-05-29: the intended product topology is not a
direct repository-local `bus-worker` command as the final worker UX. The target
is:

1. The module family pattern stays consistent across Bus products:
   `bus-{name}` is the product/CLI module, `bus-api-provider-{name}` is the
   API/controller provider for `bus-api`, and `bus-integration-{name}` is the
   event/integration provider for the `bus-integration` runner.
2. A local `bus-events` service and a remote `bus-events` service on
   `coding-agent@dev.hg.fi` run continuously.
3. Those Events services automatically proxy/relay eligible Events in both
   directions so local control-plane requests reach the remote worker
   environment and remote worker evidence returns locally without manual
   import/export.
4. A `bus-workers` product module provides the plural `bus workers` CLI.
5. `bus workers ...` talks to a locally running `bus-api-provider-workers`
   service through the `bus-api` provider layer, rather than writing the worker
   registry directly as the normal product path.
6. The local workers API provider publishes `bus.workers.*` Events for worker
   create/list/state/control operations.
7. A `bus-integration-workers` service running on `coding-agent@dev.hg.fi` as
   a provider for the `bus-integration` layer consumes those proxied
   `bus.workers.*` Events.
8. That remote integration service manages actual worker containers. Each
   worker container runs Codex/App Server with its configured model, can be
   running or paused, and can either be assigned through `bus task ...` or
   claim approved available tasks when idle.
9. The supervisor then supervises and guides assigned workers through the task
   stream while local status uses the returned Events evidence.

The existing singular `bus-worker`, `bus-api-provider-worker`, and
`bus-integration-worker` checkouts are current implementation scaffolds. They
must not be treated as final until the plural product surface, provider-service
path, `bus.workers.*` event flow, local/remote Events proxying, and remote
container worker lifecycle are implemented and proven.

Target event namespaces are `bus.task.*` for task lifecycle and `bus.workers.*`
for worker lifecycle/control. Existing `bus.work.*`, `bus.dev.task.*`, and
singular `bus.worker.*` names are legacy, compatibility, or bootstrap surfaces
until each reference has been audited and either removed, renamed, or explicitly
documented as compatibility.

## Original Product Direction

The refactor started from a naming and ownership clarification.

`bus-task` should be the user-facing generic task/thread surface. It should not
be a development-only or Codex-only command. Tasks need approval, priority,
blockers, dependencies, assignment metadata, deterministic queue state, and
enough non-secret routing metadata for workers to pick them up later in the
right environment.

Worker identity and worker-oriented orchestration should move out of
task-specific integration code. Durable worker identity belongs behind the
plural `bus workers` product/API surface, currently scaffolded in
`bus-worker`. Reusable integration behavior for claims, routing, capacity,
worker starts, replay selection, health, consumer loops, and scheduler
decisions belongs behind the workers integration service, currently scaffolded
in `bus-integration-worker`.

`bus-integration-task` should become thinner. It can bridge `bus.task.*` event
streams to task execution, but it should not remain the hidden owner of worker
identity, queue selection, worker routing, claim arbitration, capacity, or
runtime launch policy.

`bus-agent` remains the runtime/provider execution layer. Provider execution,
Codex App Server protocol handling, App Server buffering, and backend runtime
details belong there, not in task or worker identity modules.

The product must keep first-class support for these environments in one Bus
deployment:

- local workers
- ssh-docker workers
- hosted workers
- ChatGPT/Codex subscription workers
- API-key workers

The operator also chose the user-facing name `repos` for Git-backed repository
features:

- `bus-repos` for user-facing repo concepts and CLI
- `bus-integration-repos` for Git-backed storage integration
- `bus-api-provider-repos` for API/controller integration

The user-facing product should say `repos`, not `git`, because Git is the
implementation technology rather than the user-facing project-management tab.

## Important Operating Lessons

Several operator corrections became durable project guidance during this
thread.

First, always write important repeated lessons into the relevant `AGENTS.md`
instead of trusting chat memory. Corrections about naming, model ids,
architecture priority, logging, or process should become durable guidance in
the same work session.

Second, troubleshoot by turning the lights on. Enable verbose logging first.
If evidence is too thin, add DEBUG/TRACE-capable logs in the owning module
before making broad behavior changes. Verify root causes with proof instead of
assuming from symptoms.

Third, simplify before building. Before creating a feature, abstraction,
workflow, or support system, ask whether the goal can be met by removing a
requirement, narrowing the problem, reusing a smaller existing primitive, or
accepting a temporary manual step. Less system is preferred when it honestly
solves the current need.

Fourth, keep the core substrate minimal. Project-specific practices such as
Bus Notes, PLAN-driven closeout, local reporting rituals, and supervisor
bookkeeping should be optional overlays unless source-backed proof shows the
core worker/task/event substrate truly depends on them.

Fifth, local Spark worker work should use the exact raw model id:

```text
gpt-5.3-codex-spark
```

Do not normalize this model name as part of the current refactor. Passing the
configured model id through exactly is the current rule. Alias or normalization
logic can be a later UX feature, but it is not on the critical path.

## Current Architecture State

`bus-task` already owns much of the generic task/thread surface. Current
capabilities include task creation, approval/ready transitions, assignment
metadata, priority, blockers, dependencies, deterministic queue selection, and
monitor snapshots with task queue metadata. The monitor path has also gained an
incremental projection cache so worker-facing queue reads do not need to replay
all task history on every poll.

`bus-integration-worker` is no longer only a skeleton in practice. It now owns
many reusable worker packages, including worker claim ordering, claim
verification, routing, replay selection, worker-start request shaping, queue
decisions, health/stale-worker checks, consumer loops, and scheduler runtime
helpers. Its public docs still need more cleanup so they tell the same story as
the code.

`bus-integration-task` has been progressively slimmed. Many worker-side rules
were extracted out of `cmd/bus-integration-task/main.go` and
`pkg/devtaskintegration` into `bus-integration-worker`, but the command still
contains too much top-level orchestration glue. It remains the bridge from
task events to execution, and it currently owns the App Server task prompt
contract used by local Spark workers.

`bus-worker` has started becoming real as scaffolding. The earlier committed
slice created a first durable identity contract in `bus-worker` with validation
and normalization tests. The current dirty `bus-worker` checkout now adds the
first repository-local CLI/registry implementation: `bus-worker create`,
`list`, `show`, `group list/show/create`, and `status` store non-secret worker
identity and group records under `.bus/worker/config.json` with deterministic
text and JSON output. This is now classified as an interim local identity
scaffold, not the final `bus workers` product path.

`bus-api-provider-worker` is also now a scaffold for the target plural
`bus-api-provider-workers` surface. The accepted checkout builds a
`bus-api-provider-workers` binary and has a narrow `pkg/workersapi` HTTP
handler that maps local API requests to canonical `bus.workers.*` Events:
list, create, pause, resume, and assign requests publish through the Events
API using the supplied token. The list request is shaped for multiple worker
environments: it carries a correlation id, names
`bus.workers.list.response` as the response event, and the provider scaffold
can merge returned worker list/status Events from more than one environment
into a bounded read projection. The standalone provider also has an Events
stream listener that replays/follows `bus.workers.list.response` and
`bus.workers.status.snapshot` from `bus-api-provider-events` into that
projection. The projection now has both an in-memory default and a compact
file-backed durable mode selected by `--projection-file` or
`BUS_WORKERS_PROJECTION_FILE`, with unit coverage for persistence, deterministic
ordering, merge behavior, malformed files, and command selection. This is
useful forward motion toward the local API-provider path, but it is not the
finished provider: the checkout path is still singular, bus-api provider
registration/mounting is not done, and only the first remote
`bus-integration-workers` list-response consumer exists so far.

`bus-integration-worker` is now also a scaffold for the target plural
`bus-integration-workers` service. The current dirty checkout builds a
`bus-integration-workers` binary and has a narrow `pkg/workersintegration`
package that consumes `bus.workers.list.request`,
`bus.workers.create.request`, `bus.workers.pause.request`,
`bus.workers.resume.request`, and `bus.workers.assign.request` through the
shared `bus-integration` runtime. It publishes this environment's correlated
`bus.workers.list.response` with environment metadata and flat
`bus.workers.status.snapshot` payloads that the workers API provider can
merge. The status snapshots now preserve non-secret lifecycle metadata for
planned Codex App Server containers, including container id, worktree path,
logs path, and App Server URL. A static JSON catalog, bounded in-memory control
catalog, and non-executing App Server lifecycle plan builder are available as
bootstrap input, which is enough to close the first multi-environment
list/control/status loop with the workers API provider. This is still not the
finished remote worker service: live container state, proactive task claiming,
durable status evidence, and actual Codex/App Server container launch remain
open.

The final path must call the local `bus-api-provider-workers` service,
publish/consume `bus.workers.*` Events, and drive remote worker containers
through `bus-integration-workers` on `coding-agent@dev.hg.fi`. The current
`bus-worker` status surface is still a bounded registered-identity snapshot,
not live task telemetry. This is still not the finished worker product:
worker-home logical references now have a documented repo-kind contract with
the `bus-repos` family, but worker-home provisioning,
active-work/performance views, API/provider surfaces, cross-module adoption,
plural CLI naming, state control, and remote container lifecycle remain open.

`bus-agent` received an App Server buffering fix so diagnostic bursts do not
drop assistant text during local Spark worker runs. Runtime/provider execution
should continue to stay there.

The repos family modules were initialized and planned, but repo automation is
not on the immediate critical path for getting workers productive. They should
not block the worker v1 unless the current slice explicitly needs repository
storage behavior.

## Local Events and Task Substrate

The local Events API was repaired during the thread. The important fixes were:

- `bus-api-provider-events` now serves conditional append over HTTP.
- Published `bus.task.*` lifecycle events seed the conditional latest-state
  used by worker claiming.
- Local host-worker smoke scripts fail if the source-run Events API exits
  early.
- Disposable local Events smokes enable TRACE by default.

The core local task proof script is:

```bash
scripts/test-local-task-events-proof.sh
```

It proved a disposable local Events API can create a task, approve it, list it
as ready, replay it through `show`, and expose it through
`monitor --format json`.

The local host-worker smoke script is:

```bash
scripts/test-local-host-worker-smoke.sh
```

It proved a local worker can see ready work, claim atomically, start execution,
emit progress, and finish to `bus.task.done` on a fresh source-run local Events
provider.

## Local Spark Worker Lane

The local Spark worker lane is now usable enough for real work, with an
important caveat.

The proven lane is:

```text
agent backend: codex-appserver
model: gpt-5.3-codex-spark
sandbox: full
worktree: supported
commit promotion: not currently used on this lane
```

The useful environment shape for local Spark smoke runs has been:

```bash
BUS_LOCAL_HOST_WORKER_SMOKE_AGENT_BACKEND=codex-appserver
BUS_LOCAL_HOST_WORKER_SMOKE_MODEL=gpt-5.3-codex-spark
BUS_TASK_CODEX_SANDBOX=full
BUS_TASK_TRACE=true
```

The local macOS `workspace-write` App Server path is still a separate substrate
bug. The evidence points at the source `CODEX_HOME/tmp/arg0` cache lacking the
Linux sandbox helper expected by the stricter workspace-write setup. Do not
block useful local Spark work on that bug. Treat it as a follow-up substrate
issue.

Commit-enabled isolated worktree workers currently require the stricter write
sandbox path or a trusted lifecycle policy. Because the proven local Spark lane
uses `BUS_TASK_CODEX_SANDBOX=full`, the practical local worker lane for now is:

```text
worktree=true
commit=false
```

That means workers can produce reviewable work in isolated worktrees, but the
supervisor still needs to inspect and promote accepted diffs manually or through
later tooling.

## Current Remote Worker Bootstrap Lane

Because this supervisor host has no local Docker, the current practical worker
bootstrap is a tiny wrapper around the SSH-Docker/App Server task path:

```bash
scripts/start-dev-hg-spark-worker-task.sh MODULE BRANCH PROMPT_FILE
```

The wrapper starts a task for `coding-agent@dev.hg.fi` with:

```text
agent backend: codex-appserver
model: gpt-5.3-codex-spark
profile: codex-spark
sandbox: full
worktree: true
commit: false
start-only: true
default image: bus-integration-task:local-image-smoke
```

It is a bootstrap launcher, not the final `bus workers` product path. It should
only be used for small implementation-plus-unit-test slices while the plural
workers control plane is being built. Do not ask these workers to run e2e or
integration tests yet; those should wait until the implementation slices are
available for supervisor review.

The first split worker prompt files for this lane are under the supervisor
logs directory:

```text
logs/worker-prompts/20260529-1958-bus-integration-workers-control.md
logs/worker-prompts/20260529-1958-bus-api-provider-workers-control.md
logs/worker-prompts/20260529-1958-bus-workers-cli-scaffold.md
```

Before relying on the remote checkout, preserve and clean any dirty state on
`coding-agent@dev.hg.fi`. A backup of the dirty remote state found during this
continuation was written on the remote host at:

```text
/home/coding-agent/coding-agent/git/busdk/remote-dirty-backups/20260529-170345
```

That backup includes old-name edits in `bus-dev`, `bus-events`,
`bus-integration-dev-task`, `bus-remote`, and the superproject smoke scripts.
The useful smoke-script ideas are already represented in the current local
launcher path; the old-name module diffs should be treated as historical
reference unless a maintainer deliberately ports them into the current
`bus-task`/`bus-integration-task`/plural-workers architecture.

## Spark Worker Focus Problem

The current immediate worker problem is not launch, claim, auth, worktree prep,
Codex process startup, thread creation, or App Server turn startup. Those have
all been proven.

The problem is worker focus inside the model turn.

Local Spark workers were reaching the App Server turn but behaving too much
like broad supervisors. Narrow recipient-local tasks drifted into:

- `PLAN.md`
- `README.md`
- broad repository scans
- "no change needed" conclusions
- generic verification instead of the named requested fix

This was especially visible with a concrete `bus-task` issue:

```bash
bus-task/bin/bus-task new --help
bus-task/bin/bus-task assign --help
```

Both commands still printed the top-level help banner instead of
subcommand-specific help. Workers were asked to fix that exact behavior, but
they drifted into broader scans before touching the narrow CLI surface.

Several fixes landed to address this:

- `bus-integration-task` now has a reduced `minimal-implement` prompt profile
  separate from `minimal-smoke`.
- `minimal-smoke` remains for read-only or proof-only tasks.
- `minimal-implement` tells workers to edit files when needed and not silently
  downgrade implementation tasks into read-only verification.
- `minimal-implement` now tells workers to start with exact named files,
  failing commands, stale text, or acceptance surfaces.
- It also tells workers not to broaden into README, PLAN, or unrelated
  directories unless those named surfaces are insufficient.
- The task prompt builder now has a `prioritizeTaskText` mode for
  `minimal-implement`, presenting `Primary requested work:` before broader
  metadata.
- Root `AGENTS.md` now includes `Recipient-Scoped Worker Focus` so ordinary
  implementation workers do not inherit broad supervisor duties by default.
- `bus-integration-task/AGENTS.md` now mirrors that guidance.

This prompt/guidance work is committed as:

```text
bus-integration-task add791c Tighten recipient worker prompt focus
root 7088b3c Checkpoint recipient worker focus guidance
```

The focused verification run for that slice was:

```bash
go -C bus-integration-task test ./pkg/devtaskintegration ./cmd/bus-integration-task
git diff --check
```

A follow-up should run one new sharply scoped Spark worker proof after this
prompt-ordering change, because the final behavioral proof has not yet been
completed.

Update from the supervisor-host continuation: the concrete `bus-task` help bug
has now been fixed locally in the dirty `bus-task` checkout. `run/task.go`
delegates early help handling to subcommand help when possible, `run/run.go`
now has `new` and `assign` help surfaces, and `run/run_test.go` covers both
commands. The focused checks passed with `go test ./run`, `git diff --check`,
`make build`, and rebuilt `./bin/bus-task new --help` / `./bin/bus-task assign
--help` invocations. This removes the help bug as the next implementation
target, but it does not prove Spark worker focus because the fix was made by
the supervisor while the external-model worker proof remained approval-gated.

## Recent Clean Checkpoint

The last requested cleanup checkpoint committed the full current superproject
state at that moment.

Submodule commits:

```text
bus-worker 76b6ad9 Start bus-worker identity contract
bus-integration-task add791c Tighten recipient worker prompt focus
logs 8d58f54 Record Spark worker focus debugging
```

Root commit:

```text
7088b3c Checkpoint recipient worker focus guidance
```

The checkout was clean immediately after that commit.

After that checkpoint, the operator reorganized setup around
`agents/supervisor/`. That work appears to be a separate conversation goal and
may leave root changes such as `.gitmodules`, `agents/supervisor`, `docs`, and
`logs`. Do not confuse those later supervisor-root changes with the
multi-environment task/worker refactor itself. Always inspect the current Git
state before resuming.

## Known Working Commands

Use these as starting evidence, not as proof that the full goal is done.

Local task substrate:

```bash
scripts/test-local-task-events-proof.sh
```

Local host worker substrate:

```bash
scripts/test-local-host-worker-smoke.sh
```

Focused `bus-integration-task` prompt/guidance tests:

```bash
go -C bus-integration-task test ./pkg/devtaskintegration ./cmd/bus-integration-task
```

Worker identity contract tests:

```bash
go -C bus-worker test ./...
```

Task module focused tests used repeatedly:

```bash
go -C bus-task test ./run
```

Focused task help regression proof in the current dirty `bus-task` checkout:

```bash
go -C bus-task test ./run
make -C bus-task build
bus-task/bin/bus-task new --help
bus-task/bin/bus-task assign --help
```

Docs lint is sometimes slow or prone to `bus-lint` hangs in this environment.
When it completes, treat it as useful evidence. When it hangs, kill stale
process chains honestly and do not claim a passing lint result.

## Known Unfinished Product Work

The plural workers product path is still not a finished product. The current
dirty `bus-worker` checkout has the first direct binary scaffold for:

- `bus worker list`
- `bus worker show`
- `bus worker create`
- `bus worker group list/show/create`
- `bus worker status` for registered identity snapshots
- durable repository-local worker registry storage

That scaffold is useful implementation evidence, but it is not the target
architecture by itself. The current dirty `bus-api-provider-worker` checkout
also has the first request-to-Events provider scaffold for the plural
`bus-api-provider-workers` runtime surface. The unfinished product path is:

- a `bus-workers` product module exposing the plural `bus workers` CLI
- a local `bus-api-provider-workers` API/controller service registered through
  `bus-api`; the current scaffold can emit list/create/pause/resume/assign
  `bus.workers.*` request Events and merge multi-environment list/status
  responses from the Events stream through memory or file-backed durable
  projections, but still needs bus-api mounting
- a remote `bus-integration-workers` service on `coding-agent@dev.hg.fi`
  consuming proxied worker Events; the current scaffold can answer
  `bus.workers.list.request` from a static environment catalog and can apply
  create/pause/resume/assign requests to an in-memory control catalog, but it
  does not yet claim tasks or launch real worker containers
- remote Codex/App Server worker containers created, paused, resumed, assigned,
  and observed through those Events
- worker-home repository provisioning through the `bus-repos` family
- active-work status and performance stats
- cross-module adoption of the plural API/provider/integration surfaces

`bus-integration-workers` still needs to become the clear owner of the remote
long-lived worker service loop. The singular `bus-integration-worker` checkout
already owns many useful packages, but the final product needs one
service-owned provider that continuously watches proxied worker/task Events,
accounts for capacity, handles stale workers, claims atomically, starts
runtimes only after claim ownership is proven, and reports clear outcomes.

Update from the supervisor-host continuation: `bus-integration-worker` README,
module `AGENTS.md`, PLAN, and SDD now describe the current package ownership
instead of calling the module a skeleton. They name the existing worker-owned
claim, route, replay, queue, health, consumer, worker-start, and scheduler
packages while keeping the stable service-loop contract open. `go test ./...`
passed in `bus-integration-worker` after this documentation alignment.

Follow-up update: the worker-owned service-loop contract is now documented in
the `bus-integration-worker` README and SDD. The contract is the bounded
monitor/reconcile/start cycle already represented by `pkg/workerscheduler`:
publish monitor progress, run optional task-specific review, reconcile queue
and capacity, report stale workers, preflight launches, start the filtered
batch, publish refill progress, and run self-check health.

Current-state inspection found that `bus-integration-task` already wires its
supervisor path through `workerscheduler.RunObservedCycle`. Focused
`bus-integration-task` package tests prove stale-worker reporting, queue
refill, worker-side selector rules, preflight-blocked launches, and
`refill_started` evidence through that worker-owned cycle. A command-level
`--supervisor-once` test also proves a monitor snapshot can publish a
`bus.task.worker.start.request` through the path; it passes when local loopback
`httptest` binding is allowed. A live no-Docker/no-model local smoke now also
exercises this service-owned cycle against a disposable source-run Bus Events
provider: `scripts/test-local-worker-service-cycle-smoke.sh` creates a ready
task, runs `bus-integration-task --supervisor-once` with `bus task monitor
--format json`, verifies one refill request, and replays
`monitor_complete`, `refill_started`, `self_check_ok`, and
`bus.task.worker.start.request` Events for the created work ref. This is still
not product completion: the remote Spark/App Server worker proof and mixed
environment capacity/routing proof remain open. Event naming in the scaffold is
currently split by owner:
`bus-integration-worker` defaults to `bus.worker.supervisor.*` progress/health
events, while `bus-integration-task` explicitly configures the existing
`bus.task.supervisor.*` names as task-bridge compatibility events. The target
worker lifecycle/control namespace remains `bus.workers.*`, so the
`bus.worker.*` progress/health names still need an explicit rename or
compatibility decision.

`bus-integration-task` still needs slimming. It should keep task-thread
projection, task event translation, and task-specific review/reopen semantics,
but remaining worker launch and scheduler glue should continue moving to
worker-owned packages.

`bus-task` still needs polish and broader proof on its generic CLI contract.
The previously documented `new --help` and `assign --help` gap is fixed in the
current dirty `bus-task` checkout, with focused tests and rebuilt-binary
verification. It still needs normal review, commit/pin promotion, and a
separate live worker proof that demonstrates Spark workers can complete a
similarly narrow implementation task without supervisor-side repair.

Remote ssh-docker Spark worker execution is still operationally rough. Earlier
live runs reached remote image launch points but failed on image pull/GHCR
access. The scripts now support `--install-image`, `--build-image`, `--image`,
and `--local-tag`, but the remote external-model Spark proof is not complete.

The remote no-model SSH-Docker substrate proof is now complete for
`coding-agent@dev.hg.fi`: `bus-ssh-docker-smoke#7.1` was started from the
supervisor host, published through the clean remote Events store, launched the
`bus-integration-task:supervisor-9039320` Docker worker on the remote host,
prepared an isolated `bus-task` worktree in a full remote clone, ran
`agent_backend=self-test`, and emitted terminal `bus.task.done`. That proof did
not exercise the external Spark/App Server model path, so it does not satisfy
the completion criterion that remote ssh-docker Spark workers complete a tiny
real task.

Mixed local plus remote worker queue proof is not complete. Capacity behavior
across local, ssh-docker, hosted, subscription, and API-key environments still
needs a completion matrix.

The repos modules remain mostly planning and skeleton work, but they now define
the first repo-kind contract needed by this refactor: `source`,
`worker-home`, `task-context`, and `shared-content`, with non-secret logical
refs such as `repos://workers/<worker-id>`. Provisioning, sync, API resources,
and full `bus repos` CLI behavior remain unfinished.

Docs and rename cleanup are improved but not finished. Remaining stale
`bus dev task`, `bus dev work`, `bus-integration-dev-task`, `BUS_DEV_TASK`,
`bus.dev.task.*`, `bus.work.*`, and singular `bus.worker.*` references should
be audited carefully, because some may be legacy compatibility references while
others are stale user-facing text.

## Recommended Next Steps

Start a fresh thread by inspecting current state:

```bash
git status --short
git -C bus-task status --short
git -C bus-integration-task status --short
git -C bus-integration-worker status --short
git -C bus-worker status --short
git -C docs status --short
```

Do not use `bus dev work status` as the authoritative board snapshot in this
checkout. The bundled tool now reports that `bus dev work` was removed; use
`bus task` status/list/monitor commands against the configured Events endpoint
for live task evidence, and treat any remaining runbook text that points at
`bus dev work` as stale unless it is explicitly documenting legacy
compatibility.

Read these files first:

```text
AGENTS.md
bus-task/AGENTS.md
bus-integration-task/AGENTS.md
bus-integration-worker/AGENTS.md
bus-worker/AGENTS.md
docs/docs/goals/multi-environment-task-worker-refactor.md
logs/20260529-14-agent-memo.md
```

Worker wording matters here. There are two different proof lanes:

- No-model infrastructure workers: these exercise Bus Events, ssh-docker,
  image startup, task monitor/refill loops, and terminal `bus.task.done`
  publication without asking a Codex model to inspect or modify the checkout.
  These do not require external-model disclosure approval.
- Model-backed Codex App Server workers: these start or connect to a Codex App
  Server worker lane and send the selected task prompt plus relevant private
  repository context to `gpt-5.3-codex-spark`. The worker may already be a
  Codex App Server process, but launching a task through it still crosses the
  model-disclosure boundary from this supervisor checkout.

So the old "approval" wording in this handoff was not a Bus task approval,
release approval, or a second worker architecture gate. It was the local
execution/sandbox guard asking whether this session was allowed to run an SSH
worker command that would send focused task and private checkout context to the
configured Codex/App Server model service. The operator has since explicitly
asked to launch these workers on `coding-agent@dev.hg.fi`; proceed through the
normal sandbox escalation path when the tool asks, and record the exact worker
refs and evidence.

Then run one narrow Spark worker proof using the updated `minimal-implement`
profile. On this supervisor host, prefer the `coding-agent@dev.hg.fi`
SSH-Docker path rather than the local host-worker script, because local Docker
is unavailable. The old `bus-task new --help` / `assign --help` task is no
longer useful as the implementation target except as a regression check; pick a
fresh tiny recipient-local task with named files, an exact failing command or
stale help surface, focused tests, and no need for broad README/PLAN scans.

For this supervisor-host topology, the remote proof should use the bootstrap
launcher above, or `scripts/test-ssh-docker-image-smoke.sh` directly, with the
clean remote Events endpoint or its service-owned successor,
`--remote-workdir` pointing at a full remote clone rather than a Git worktree,
`--agent-backend codex-appserver`, `--codex-model gpt-5.3-codex-spark`,
`--worktree=true`, and `--commit=false`. Use focused implementation prompts
with unit tests only. A continuation attempt earlier on 2026-05-29 was rejected
by the approval guard before the operator clarified and requested this exact
remote worker launch path; that stale rejection should not be treated as the
current blocker.

The success signal for this proof is that the script exits zero, `bus-task
show` includes a terminal `bus.task.done` event from the worker, the worker
closeout names the changed recipient files and tests run, and the isolated
worktree contains the focused task fix rather than only a broad scan or
"nothing to change" summary.

```text
Recipient: pick the smallest owning module for the fresh task
Profile: minimal-implement
Model: gpt-5.3-codex-spark
Sandbox: full
Worktree: true
Commit: false

Task: Start with the exact failing command, stale help text, or named files.
If the behavior is still wrong, implement the smallest recipient-local fix,
add focused tests, and run the smallest relevant deterministic checks.
```

If the worker still drifts into broad README/PLAN scans, treat that as a
remaining `bus-integration-task` prompt/worker-substrate bug rather than as a
`bus-task` implementation failure.

If the worker stays focused and produces a useful diff, review it manually,
run the required checks, promote the diff into the owning submodule, commit the
submodule, and pin the root.

The next strong lanes are:

1. Replace the temporary remote Events proxy/tunnel proof path with the
   intended service-owned local/remote `bus-events` relay/sync path.
2. Build the plural workers product path: `bus-workers` CLI,
   `bus-api-provider-workers` local API/controller provider,
   `bus.workers.*` Events, and `bus-integration-workers` remote integration
   provider.
3. Migrate or wrap the useful singular `bus-worker` identity/group scaffold
   behind the plural `bus workers` API/provider path.
4. Continue extracting remaining worker launch/scheduler glue from
   `bus-integration-task` into the workers integration provider.
5. Run the remote Spark worker proof through `coding-agent@dev.hg.fi` using the
   service-owned Events relay and workers integration provider.
6. Re-run local or mixed Spark proof with two parallel workers once narrow task
   focus and worker state control are reliable.

## Completion Criteria Still Required

The full goal should not be marked complete until current evidence proves all
of the following:

- `bus-task` is the generic multi-environment task/thread system.
- Approval, priority, blockers, assignment, and deterministic queue state work
  through tested user-facing and worker-facing paths.
- `bus-workers` owns the durable worker product/CLI surface for identity,
  groups, list/create/show, state control, assignment, and status.
- `bus-api-provider-workers` exposes the worker API/controller surface through
  `bus-api` and publishes canonical `bus.workers.*` Events.
- `bus-integration-workers` consumes proxied `bus.workers.*` and `bus.task.*`
  Events on `coding-agent@dev.hg.fi` and owns proactive worker claiming,
  worker-group routing, capacity, health/stale-worker handling, container
  lifecycle, and runtime launch decisions.
- Local and remote `bus-events` services run continuously and automatically
  relay eligible Events in both directions.
- `bus-integration-task` is slimmed to task-specific event bridge and task
  lifecycle/review semantics.
- `bus-agent` remains the runtime/provider execution owner.
- Local, ssh-docker, hosted, ChatGPT/Codex subscription, and API-key worker
  environments can coexist in one Bus deployment.
- Target event namespaces are canonical: `bus.task.*` for tasks and
  `bus.workers.*` for workers. Legacy `bus.work.*`, `bus.dev.task.*`, and
  singular `bus.worker.*` references are removed or explicitly documented as
  compatibility.
- Local Spark workers complete real implementation tasks reliably enough to
  use for parallel development.
- Remote ssh-docker Spark workers complete at least one tiny task.
- Mixed local plus remote capacity/routing is proven.
- Docs, SDD, README, CLI help, and plan files tell the same architecture story.
- The final root checkout and touched submodules are clean and committed.

## Cautions For The Next Thread

Do not infer completion from passing package tests alone. Many package tests
prove local contracts but not the full multi-environment product behavior.

Do not spend more work on model-name normalization right now. Use
`gpt-5.3-codex-spark` exactly.

Do not turn project process into core substrate requirements. Bus Notes,
PLAN-based closeout, and reporting rituals should remain overlays unless a
specific source-backed need proves otherwise.

Do not treat a worker reaching `done` as accepted progress. Supervisor review,
diff inspection, required checks, promotion, submodule commit, and root pinning
are separate gates.

Do not block local productive work on remote image distribution, GHCR access,
or macOS `workspace-write` parity. Those are real follow-ups, but the smallest
useful lane today is local Spark with `sandbox=full`, worktrees, and manual
supervisor review/promotion where local Docker/App Server worker execution is
available. In this supervisor-host environment, use `coding-agent@dev.hg.fi`
for Docker-backed worker execution instead of attempting local Docker.

Do not ignore root guidance being too supervisor-heavy for workers. The latest
fixes moved in the right direction, but the next live proof should decide
whether more separation is needed between supervisor identity and
recipient-worker prompts.

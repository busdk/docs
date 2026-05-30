# Manual Spark Worker Bootstrap Goal

## Goal

Provide a minimal manual worker launcher that lets the supervisor run parallel
Codex agent workers on macOS or another configured host while the full Bus
workers product control plane is still under construction.

This is a bootstrap development tool, not the final product architecture. It
should be kept small and should not depend on `bus-task`, Bus Events,
workerroute, provider services, service-owned relay, Docker, or
virtualization.

## 2026-05-30 Review Addendum

This goal was reviewed against the neighboring task, worker, repos, relay, and
deployment goals plus the current worker-related Bus module checkouts on
2026-05-30. No product implementation worktree or feature branch was created
for this review. The operator requested review-only work and allowed this goal
file to be updated in the main checkout.

No other goal must be completed before this bootstrap goal can proceed. The
manual launcher is intentionally a temporary acceleration path while the
product workers control plane, Events relay, scheduler, and repos primitives
continue separately. It should not be blocked on `docs/goals/workers.md`,
`docs/goals/repos.md`, `docs/goals/service-owned-events-relay.md`, or
`docs/goals/systemd-user-deployment.md`, but its accepted behavior should
remain compatible with the lifecycle shape those goals are converging on.

Current implementation baseline: `projects/busdk/scripts/manual-dev-hg-spark-worker.sh`
already exists in the BusDK superproject, not in a supervisor-root `scripts/`
directory. It currently starts Docker-hosted Codex App Server workers on
`coding-agent@dev.hg.fi` using `BUS_MANUAL_SPARK_*` configuration variables,
with defaults for the remote BusDK superproject checkout at
`/home/coding-agent/coding-agent/git/busdk/busdk` and worker scratch data under
`/home/coding-agent/coding-agent/git/busdk/tmp/workers`. The product
`bus-integration-workers` implementation already has an App Server lifecycle
planner/executor surface using `BUS_WORKERS_APPSERVER_*` settings; those names
belong to the product integration path, not the current manual script.

The current script proves much of the desired shape, including per-worker
remote worktrees, module branch checkout, worker-local `AGENTS.md`, prompt
mounting, logs, `CODEX_HOME`, Docker container startup, App Server port
selection, `prompt`, `attach`, `logs`, `status`, and `stop` commands. Remaining
acceptance gaps to preserve in this goal: tighten worker slug validation to the
documented lowercase slug contract, validate module and branch names before any
remote side effects, refuse cross-worker ownership conflicts instead of
force-removing containers, persist canonical metadata keys for the worker,
worktree, logs, `CODEX_HOME`, model, sandbox, and live process/session, and
make branch/base reuse checks explicitly match the reviewed BusDK module pin or
prior metadata for the same worker. The old `container_name` and
`app_server_port` metadata shape is historical-only after the host sandbox
refinement below.

## 2026-05-31 Worker Identity Refinement

The bootstrap launcher should use the BusDK `agents/worker` submodule as the
worker identity repository. Each manual worker must get its own branch and
worktree from that repository, separate from the product-code worktree used for
the assigned Bus module.

The worker identity branch is where the worker's editable operating rules,
durable memory, and memo logs live. The launcher may seed that branch with the
assigned task prompt and supervisor constraints, but it must not treat the
worker identity checkout as a disposable generated file. During the task, the
worker may edit its own `AGENTS.md`, add small durable memory notes, and write
hourly memo logs under that identity worktree. Product/module code changes
still belong in the assigned module worktree and implementation branch.

## 2026-05-31 Host Sandbox Refinement

The bootstrap target is host-run Codex workers, not Docker-hosted App Server
containers. The launcher should run on macOS without nested virtualization and
should also be able to target another configured host over SSH when useful.
Each worker should be an ordinary Codex agent process or terminal session
started with an explicit sandbox policy, isolated `CODEX_HOME`, product
worktree, worker identity worktree, logs directory, and scratch directory.

This refinement supersedes the earlier container/image/port acceptance shape.
Docker can remain useful for later product integration tests, but it is not a
dependency of this manual bootstrap. The manual script should not inspect
Docker images, reserve container ports, start containers, mount directories
into containers, or use container names as worker identity. Its isolation
comes from Git worktrees, worker-specific branches, worker-specific
`CODEX_HOME`, process/session ownership metadata, and the Codex sandbox.

Implementation lane for this refinement: product script work is isolated in
the BusDK superproject worktree
`/Users/jhh/git/busdk/agent-supervisor/worktrees/manual-go-worker-script/busdk`
on branch `codex/manual-go-worker-script`. The primary file under change is
`scripts/manual-dev-hg-spark-worker.sh`. Do not merge this branch or promote
its BusDK pointer until the operator explicitly confirms the work.

## Required Behavior

The concrete launcher contract is:

```bash
cd /Users/jhh/git/busdk/agent-supervisor/projects/busdk
scripts/manual-dev-hg-spark-worker.sh start WORKER MODULE BRANCH PROMPT_FILE
scripts/manual-dev-hg-spark-worker.sh prompt WORKER [PROMPT_FILE]
scripts/manual-dev-hg-spark-worker.sh attach WORKER
scripts/manual-dev-hg-spark-worker.sh logs WORKER
scripts/manual-dev-hg-spark-worker.sh status [WORKER]
scripts/manual-dev-hg-spark-worker.sh stop WORKER
```

`start` prepares the remote product worktree, the worker identity repository
worktree, metadata, and Codex agent session, then prints the worker
slug, implementation branch, product worktree path, worker identity branch,
worker identity worktree path, logs path, process or session id, and attach
instructions. `prompt` sends or refreshes the task prompt for an existing
worker without changing either worktree. `attach` opens the live terminal or
Codex agent session for that worker. `logs` prints or follows the worker-local
log files without exposing secrets. `status` reports the metadata record plus
live process/session state. `stop` stops the worker process or terminal
session but preserves the product worktree, worker identity worktree, and logs
unless a later explicit cleanup command owns removal.

Arguments:

- `WORKER`: lowercase slug using letters, digits, and `-`, unique for the
  worker lane, for example `workers-api-events-1`.
- `MODULE`: BusDK module directory name under the remote checkout, such as
  `bus-api-provider-worker`; it must not contain `/`, `..`, or shell
  metacharacters.
- `BRANCH`: implementation branch to create or reuse for that worker, usually
  `codex/<worker>` or another reviewed branch name. It must pass
  `git check-ref-format --branch` and must be passed to SSH/Git commands as an
  argv value, not interpolated into a remote shell string. When the branch is
  absent, create it from the module repository commit pinned by the reviewed
  BusDK superproject `HEAD`, not from the superproject commit itself. When the
  branch already exists, validate that it points at that same reviewed module
  base or at the previous recorded worker metadata for the same `WORKER`;
  otherwise refuse and require an explicit recovery action.
- `PROMPT_FILE`: supervisor-host file containing the worker task. For a local
  worker, the launcher copies it into the worker metadata directory directly.
  For a remote SSH worker, the launcher copies it to the configured host.

The host running the worker must have the Codex CLI available, Codex
authentication/configuration available to the worker account, and a BusDK
checkout clean enough to create worktrees for the requested module and for
`agents/worker`. The default host should be the local macOS supervisor host.
Remote SSH hosts such as `coding-agent@dev.hg.fi` are optional targets, not the
only supported environment.

The expected local checkout root is
`/Users/jhh/git/busdk/agent-supervisor/projects/busdk` unless overridden by
the launcher configuration. The expected worker root is a host-local scratch
directory under the BusDK checkout, such as `tmp/workers/{worker}`, unless
overridden. Host, worker root, Codex command, model, sandbox, auth home,
session backend, and base ref should be read from manual launcher flags or
environment/config variables such as `BUS_MANUAL_SPARK_HOST`,
`BUS_MANUAL_SPARK_WORKER_ROOT`, `BUS_MANUAL_SPARK_CODEX`,
`BUS_MANUAL_SPARK_MODEL`, `BUS_MANUAL_SPARK_SANDBOX`,
`BUS_MANUAL_SPARK_AUTH_HOME`, `BUS_MANUAL_SPARK_SESSION_BACKEND`, and
`BUS_MANUAL_SPARK_BASE_REF`. For acceptance, the model must resolve to the raw
model id `gpt-5.3-codex-spark`; overrides are only for explicit recovery or
diagnostic runs and should not be used for the normal proof.

The worker session must also be a usable development environment. The launcher
should preserve or explicitly construct a safe tool environment that exposes
the expected host development tools to Codex, including `git`, `go`, `make`,
module-local scripts, and Bus binaries or tool paths needed by the assigned
module. This should be done with explicit `PATH`, working-directory, and
environment setup rather than by hiding the worker inside a container image.
The sandbox limits where the worker can write; it should not prevent ordinary
read/execute access to installed compilers, test tools, and project scripts
needed for focused implementation and unit tests.

Before `start`, the supervisor should be able to run focused preflight checks
equivalent to:

```bash
git -C /Users/jhh/git/busdk/agent-supervisor/projects/busdk status --short
git -C /Users/jhh/git/busdk/agent-supervisor/projects/busdk/agents/worker status --short
CODEX="${BUS_MANUAL_SPARK_CODEX:-codex}"
"$CODEX" --version
go version
git --version
make --version
```

The first command should show no conflicting dirty state for the target module
or superproject worktree creation. The worker identity repository status
should show no conflicting dirty state for worker identity worktree creation.
The Codex and development-tool version commands should confirm the agent
runtime and basic implementation tools are installed and usable by the account
that will run the worker.

The launcher should create a worker with:

- a unique worker name;
- an isolated product worktree on the selected host for the assigned BusDK
  product/module code;
- a dedicated implementation branch;
- an isolated worker identity worktree created from the `agents/worker`
  submodule repository;
- a dedicated worker identity branch, normally `worker/{worker}`;
- an editable worker-local `AGENTS.md` in the worker identity worktree
  containing the worker's operating rules, task constraints, and durable
  memory;
- worker memo logs under the worker identity worktree, normally
  `logs/{YYYYMMDD}-{HH}-agent-memo.md`;
- the BusDK product worktree exposed to Codex as the primary workdir;
- the worker identity checkout exposed to Codex as an allowed writable
  directory;
- a worker-local logs/scratch directory under a path such as
  `tmp/workers/{worker}`;
- an isolated `CODEX_HOME`;
- a host-run Codex agent process using the raw model id `gpt-5.3-codex-spark`;
- an explicit Codex sandbox policy, normally `workspace-write`, with writable
  roots limited to the product worktree, worker identity worktree,
  worker-local logs, and worker-local scratch paths;
- access to the selected host's development tools, including Go tooling, Git,
  Make, module-local scripts, and Bus binaries needed by the assigned task;
- a manual attach/control path so the supervisor can guide the worker live.

It must support parallel workers safely. Unique names, worktrees, branches,
processes or terminal sessions, logs, and `CODEX_HOME` directories should prevent one
worker from overwriting another.

The uniqueness rule is mandatory: `WORKER` must be a stable slug and every
derived path or runtime name must include it. The launcher must refuse to start
if the worker slug, implementation branch, product worktree path, worker
identity branch, worker identity worktree path, logs path, `CODEX_HOME`,
or process/session name is already owned by a different live worker. Reusing
an existing worker slug is allowed only for idempotent `status`, `logs`,
`prompt`, `attach`, or explicit recovery flows. Live ownership should be
recorded under the worker root, for example
`tmp/workers/{worker}/meta.env` plus a small JSON metadata file. The
metadata must include `worker`, `module`, `branch`, `worktree_path`,
`worker_identity_branch`, `worker_identity_worktree_path`, `logs_path`,
`codex_home`, `process_id` or `session_id`, `model`, `sandbox`, `created_at`,
and `owner=manual-spark-worker-bootstrap`. A start operation may reuse a
resource only when the recorded metadata matches the requested worker and the
live process/session check agrees.

## Supervisor Use

Use this launcher for small implementation-plus-unit-test tasks while the
product `bus workers` control plane is incomplete. Do not ask these bootstrap
workers to run broad e2e or integration suites during the first parallel
implementation phase.

Worker output is not accepted automatically. The supervisor must inspect the
diff, run relevant checks, promote accepted changes into the owning checkout,
commit the submodule, and pin the superproject.

The minimum review path for a worker result is:

```bash
MODULE=bus-api-provider-worker
git status --short
git -C "$MODULE" status --short
git -C "$MODULE" diff --stat
git -C "$MODULE" diff --check
```

Then run the focused unit tests named in the worker prompt. If accepted, apply
or merge the worker diff into the owning module checkout, commit the module,
commit the BusDK submodule pointer, and commit the supervisor pointer or memo
changes as needed. Do not promote a worker result from its terminal summary
alone.

## Relationship To Product Workers

The product workers goal should reuse this launcher shape rather than invent a
second lifecycle model. The future `bus-integration-workers` lifecycle should
eventually drive the same concepts through `bus.workers.*` Events:

- worktree and branch creation;
- worker identity branch and worktree creation from `agents/worker`;
- editable worker-local `AGENTS.md`, memory, and memo logs;
- logs and metadata directories;
- isolated `CODEX_HOME`;
- host-run Codex process/session, model, sandbox, and control path;
- pause/resume/assign/status operations.

Once the product worker control plane can create and operate equivalent
workers through Bus Events and API providers, this manual launcher should
become a recovery/debug tool instead of the main development path.

## Acceptance Criteria

This goal is accepted when:

- the launcher can start more than one Spark worker in parallel on the
  configured host;
- each worker has its own product worktree, implementation branch, worker
  identity branch, worker identity worktree, process or terminal session, logs,
  and `CODEX_HOME`;
- each worker can edit its own operating rules, durable memory, and memo logs
  in its worker identity worktree without modifying another worker's identity
  checkout;
- at least one worker runs on macOS without Docker, nested virtualization, or a
  container runtime, using only the Codex agent and its explicit sandbox;
- the supervisor can attach to and guide each worker live;
- at least one worker completes a focused implementation plus unit-test task;
- worker-produced diffs can be reviewed and promoted manually;
- the launcher behavior is documented well enough to map directly onto the
  product workers lifecycle.

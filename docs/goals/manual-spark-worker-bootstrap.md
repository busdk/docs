# Manual Spark Worker Bootstrap Goal

## Goal

Provide a minimal manual worker launcher that lets the supervisor run parallel
Codex/App Server workers on `coding-agent@dev.hg.fi` while the full Bus
workers product control plane is still under construction.

This is a bootstrap development tool, not the final product architecture. It
should be kept small and should not depend on `bus-task`, Bus Events,
workerroute, provider services, or service-owned relay.

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
directory. It starts Docker-hosted Codex App Server workers on
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
force-removing containers, persist canonical metadata keys such as
`worker`, `worktree_path`, `logs_path`, `codex_home`, `container_name`, and
`app_server_port`, and make branch/base reuse checks explicitly match the
reviewed BusDK module pin or prior metadata for the same worker.

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
worktree, metadata, container, and App Server session, then prints the worker
slug, implementation branch, product worktree path, worker identity branch,
worker identity worktree path, logs path, container name, port, and attach
instructions. `prompt` sends or refreshes the task prompt for an existing
worker without changing either worktree. `attach` opens the live guided App
Server/TUI control path. `logs` prints or follows the worker-local log files
without exposing secrets. `status` reports the metadata record plus live
container/process state. `stop` stops the container but preserves the product
worktree, worker identity worktree, and logs unless a later explicit cleanup
command owns removal.

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
- `PROMPT_FILE`: local supervisor-host file containing the worker task. The
  launcher copies it into the worker metadata directory on the remote host.

The supervisor must have SSH access to `coding-agent@dev.hg.fi`, the remote
host must have Docker or a compatible container runtime, the configured Codex
App Server worker image must be available on that host, and the remote BusDK
checkout must be clean enough to create a worktree for the requested module
and for `agents/worker`.
The expected remote checkout root is
`/home/coding-agent/coding-agent/git/busdk/busdk` unless overridden by the
launcher configuration. The expected remote worker root is
`/home/coding-agent/coding-agent/git/busdk/tmp/workers` unless overridden.
Image, sandbox, worker root, auth home, base ref, and starting port are read
from manual launcher environment/config variables such as
`BUS_MANUAL_SPARK_IMAGE`, `BUS_MANUAL_SPARK_SANDBOX`,
`BUS_MANUAL_SPARK_REMOTE_ROOT`, `BUS_MANUAL_SPARK_AUTH_HOME`,
`BUS_MANUAL_SPARK_BASE_REF`, and `BUS_MANUAL_SPARK_PORT_START`. For acceptance,
the model must resolve to the raw model id `gpt-5.3-codex-spark`; the existing
`BUS_MANUAL_SPARK_MODEL` override is only for explicit recovery or diagnostic
runs and should not be used for the normal proof. The later product integration
path uses `BUS_WORKERS_APPSERVER_*` names. The remote `coding-agent` user must
be able to run the container runtime without an interactive password prompt.

Before `start`, the supervisor should be able to run focused preflight checks
equivalent to:

```bash
ssh coding-agent@dev.hg.fi git -C /home/coding-agent/coding-agent/git/busdk/busdk status --short
IMAGE="${BUS_MANUAL_SPARK_IMAGE:-bus-integration-task:local-image-smoke}"
ssh coding-agent@dev.hg.fi docker image inspect "$IMAGE"
ssh coding-agent@dev.hg.fi docker ps --format '{{.Names}}'
```

The first command should show no conflicting dirty state for the target module
or superproject worktree creation. The image inspect command should find the
configured worker image. The container runtime command should complete without
an interactive password prompt.

The launcher should create a worker with:

- a unique worker name;
- an isolated remote Git worktree for the assigned BusDK product/module code;
- a dedicated implementation branch;
- an isolated worker identity worktree created from the `agents/worker`
  submodule repository;
- a dedicated worker identity branch, normally `worker/{worker}`;
- an editable worker-local `AGENTS.md` in the worker identity worktree
  containing the worker's operating rules, task constraints, and durable
  memory;
- worker memo logs under the worker identity worktree, normally
  `logs/{YYYYMMDD}-{HH}-agent-memo.md`;
- the BusDK checkout mounted inside the container below
  `/workspace/projects/busdk`;
- the worker identity checkout mounted inside the container below a stable path
  such as `/workspace/agent-worker`;
- a worker-local logs/scratch directory under a path such as
  `tmp/workers/{worker}`;
- an isolated `CODEX_HOME`;
- a Codex/App Server container using the raw model id
  `gpt-5.3-codex-spark`;
- a manual attach/control path so the supervisor can guide the worker live.

It must support parallel workers safely. Unique names, worktrees, branches,
containers, ports, logs, and `CODEX_HOME` directories should prevent one
worker from overwriting another.

The uniqueness rule is mandatory: `WORKER` must be a stable slug and every
derived path or runtime name must include it. The launcher must refuse to start
if the worker slug, implementation branch, product worktree path, worker
identity branch, worker identity worktree path, logs path, `CODEX_HOME`,
container name, or App Server port is already owned by a different live worker.
Port allocation must use a lock or probe-and-reserve step on the remote host
before the container starts. Reusing an existing worker slug is allowed only
for idempotent `status`, `logs`, `prompt`, `attach`, or explicit recovery
flows. Live ownership should be recorded under the remote worker root, for
example `tmp/workers/{worker}/meta.env` plus a small JSON metadata file. The
metadata must include `worker`, `module`, `branch`, `worktree_path`,
`worker_identity_branch`, `worker_identity_worktree_path`, `logs_path`,
`codex_home`, `container_name`, `app_server_port`, `model`, `image`,
`sandbox`, `created_at`, and `owner=manual-spark-worker-bootstrap`. A start
operation may reuse a resource only when the recorded metadata matches the
requested worker and the live container/process check agrees.

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
git -C projects/busdk status --short
git -C "projects/busdk/$MODULE" status --short
git -C "projects/busdk/$MODULE" diff --stat
git -C "projects/busdk/$MODULE" diff --check
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
- App Server container image, model, sandbox, and endpoint;
- pause/resume/assign/status operations.

Once the product worker control plane can create and operate equivalent
workers through Bus Events and API providers, this manual launcher should
become a recovery/debug tool instead of the main development path.

## Acceptance Criteria

This goal is accepted when:

- the launcher can start more than one remote Spark worker in parallel;
- each worker has its own product worktree, implementation branch, worker
  identity branch, worker identity worktree, container, logs, and `CODEX_HOME`;
- each worker can edit its own operating rules, durable memory, and memo logs
  in its worker identity worktree without modifying another worker's identity
  checkout;
- the supervisor can attach to and guide each worker live;
- at least one worker completes a focused implementation plus unit-test task;
- worker-produced diffs can be reviewed and promoted manually;
- the launcher behavior is documented well enough to map directly onto the
  product workers lifecycle.

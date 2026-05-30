# Manual Spark Worker Bootstrap Goal

## Goal

Provide a minimal manual worker launcher that lets the supervisor run parallel
Codex/App Server workers on `coding-agent@dev.hg.fi` while the full Bus
workers product control plane is still under construction.

This is a bootstrap development tool, not the final product architecture. It
should be kept small and should not depend on `bus-task`, Bus Events,
workerroute, provider services, or service-owned relay.

## Required Behavior

The concrete launcher contract is:

```bash
cd /Users/jhh/git/busdk/agent-supervisor
scripts/manual-dev-hg-spark-worker.sh start WORKER MODULE BRANCH PROMPT_FILE
scripts/manual-dev-hg-spark-worker.sh prompt WORKER
scripts/manual-dev-hg-spark-worker.sh attach WORKER
scripts/manual-dev-hg-spark-worker.sh logs WORKER
scripts/manual-dev-hg-spark-worker.sh status WORKER
scripts/manual-dev-hg-spark-worker.sh stop WORKER
```

`start` prepares the remote worktree, metadata, container, and App Server
session, then prints the worker slug, branch, worktree path, logs path,
container name, port, and attach instructions. `prompt` sends or refreshes the
task prompt for an existing worker without changing its worktree. `attach`
opens the live guided App Server/TUI control path. `logs` prints or follows
the worker-local log files without exposing secrets. `status` reports the
metadata record plus live container/process state. `stop` stops the container
but preserves the worktree and logs unless a later explicit cleanup command
owns removal.

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
checkout must be clean enough to create a worktree for the requested module.
The expected remote checkout root is
`/home/coding-agent/coding-agent/git/busdk` unless overridden by the launcher
configuration. Image, model, sandbox, worker root, and starting port should be
read from launcher flags or environment/config variables such as
`BUS_WORKERS_APPSERVER_IMAGE`, `BUS_WORKERS_APPSERVER_MODEL`,
`BUS_WORKERS_APPSERVER_SANDBOX`, `BUS_WORKERS_REMOTE_ROOT`, and
`BUS_WORKERS_APPSERVER_START_PORT`. The remote `coding-agent` user must be
able to run the container runtime without an interactive password prompt.

Before `start`, the supervisor should be able to run focused preflight checks
equivalent to:

```bash
ssh coding-agent@dev.hg.fi git -C /home/coding-agent/coding-agent/git/busdk status --short
IMAGE="${BUS_WORKERS_APPSERVER_IMAGE:-bus-integration-task:local-image-smoke}"
ssh coding-agent@dev.hg.fi docker image inspect "$IMAGE"
ssh coding-agent@dev.hg.fi docker ps --format '{{.Names}}'
```

The first command should show no conflicting dirty state for the target module
or superproject worktree creation. The image inspect command should find the
configured worker image. The container runtime command should complete without
an interactive password prompt.

The launcher should create a worker with:

- a unique worker name;
- an isolated remote Git worktree;
- a dedicated implementation branch;
- a worker-local `AGENTS.md` containing the task and supervisor constraints;
- the BusDK checkout mounted inside the container below
  `/workspace/projects/busdk`;
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
if the worker slug, branch, worktree path, logs path, `CODEX_HOME`, container
name, or App Server port is already owned by a different live worker. Port
allocation must use a lock or probe-and-reserve step on the remote host before
the container starts. Reusing an existing worker slug is allowed only for
idempotent `status`, `logs`, `prompt`, `attach`, or explicit recovery flows.
Live ownership should be recorded under the remote worker root, for example
`tmp/workers/{worker}/meta.env` plus a small JSON metadata file. The metadata
must include `worker`, `module`, `branch`, `worktree_path`, `logs_path`,
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
git -C projects/busdk status --short
git -C projects/busdk/<module> status --short
git -C projects/busdk/<module> diff --stat
git -C projects/busdk/<module> diff --check
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
- worker-local `AGENTS.md`;
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
- each worker has its own worktree, branch, container, logs, and `CODEX_HOME`;
- the supervisor can attach to and guide each worker live;
- at least one worker completes a focused implementation plus unit-test task;
- worker-produced diffs can be reviewed and promoted manually;
- the launcher behavior is documented well enough to map directly onto the
  product workers lifecycle.

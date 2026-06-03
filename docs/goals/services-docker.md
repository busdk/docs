# Services Docker Deployment Handoff

## Goal

This goal is about making Bus service profiles runnable inside a Docker
container with `bus services up`.

The systemd user deployment goal covers hosts where Bus infrastructure is
installed as one or a few `systemd --user` units. This Docker goal covers the
parallel packaging path: a local, remote, dev-hg, H100, or customer host can run
one Bus services container image, and that container starts and supervises the
selected Bus API, Events, integration, provider, relay, scheduler, and support
processes from an explicit `services.yml` stack.

The requested end state is:

- `bus services up` can run as the container entrypoint or PID 1 process.
- One Bus services image can host multiple Bus processes in one container when
  an operator selects that packaging model.
- The container stays in the foreground, forwards `SIGTERM`/`SIGINT`, reaps
  child processes, shuts down children in dependency order, and exits non-zero
  when required services fail.
- Service definitions come from mounted `services.yml`, profile directories,
  config directories, token files, and credential-source labels.
- The image and Compose file do not embed raw tokens, provider secrets, private
  keys, broad `.env` contents, or process-global `BUS_API_TOKEN` as the normal
  credential path.
- Docker or Podman may still be an external worker/container runtime dependency
  for selected services, but the default Bus control-plane shape is the
  `bus services up` supervisor inside the Bus services container.

This handoff exists so a future thread can implement the Docker service-profile
path without reconstructing the architecture from chat history.

## Operator Direction Captured

The operator forked this from the systemd goal and asked for a new goal file:

```text
docs/docs/goals/services-docker.md
```

The requested implementation target is support for executing:

```bash
bus services up
```

from inside a Docker container. The motivating example is containerizing
multiple Bus processes inside a single container image, with `bus services`
acting as the service supervisor.

The operator also asked for Git worktrees and feature branches to avoid
affecting other local or remote development. This planning/editing pass was
created in a docs worktree:

```text
branch:   codex/services-docker-goal
worktree: /Users/jhh/git/busdk/agent-supervisor/worktrees/docs-services-docker-goal
```

No product code was changed in this pass.

## Current Evidence

Local repository inspection found that `bus-services` already has the public
stack vocabulary:

```bash
bus services up
bus services down
bus-services stack validate --file services.yml
bus-services stack plan --file services.yml
bus-services stack up --file services.yml
bus-services stack down --file services.yml
```

`bus-integration-services` already owns the runtime integration boundary for
Bus-managed Services. It can plan, start, stop, and inspect a stack directly:

```bash
bus-integration-services stack plan --file services.yml
bus-integration-services stack up --file services.yml
bus-integration-services stack ps --state-dir .bus/services
bus-integration-services stack down --file services.yml
bus-integration-services serve --file services.yml
```

The current direction is therefore not to invent a second supervisor. The
Docker goal should make the existing `bus services up` path usable as a
container foreground process, backed by `bus-integration-services` where that
module owns runtime mechanics.

Remote proof environment evidence gathered on 2026-06-03 from
`coding-agent@dev.hg.fi`:

```text
docker client=29.5.2 server=29.5.2
docker compose=5.1.4
```

That host is a suitable Docker/Compose proof target for the live implementation
stage. This docs-only pass did not create a remote worktree or mutate the
remote host.

## Current Tracker State

`bus-services/PLAN.md` has open items for the Services contract, CLI skeleton,
provider integration boundaries, and PostgreSQL service design. Its
`AGENTS.md` says `bus-services` owns the user-facing Services CLI and client
UX, not durable runtime state or provider mechanics.

`bus-integration-services/PLAN.md` has open items for the generic runtime
provider interface, integration command skeleton, runtime-kind contract tests,
and PostgreSQL service integration proof. Its README already describes native
runtime services being started as local processes with pid, log, and status
files under `.bus/services`.

The Docker support should be tracked primarily in these module plans:

- `bus-services`: CLI flags, entrypoint UX, status output, help, and stack
  command behavior for container foreground mode.
- `bus-integration-services`: runtime-owned foreground supervision, child
  process lifecycle, signal handling, status, logs, dependency order, and
  shutdown behavior.
- `bus-integration-containers`: any Docker/Podman mechanics for services that
  themselves use a container runtime.
- `bus-operator-deploy`: optional image build/install/refresh support for the
  Bus services container image on remote hosts.

Do not implement Docker process supervision inside unrelated modules such as
`bus-events`, `bus-api`, or individual provider modules.

## Target Container Shape

The preferred default image should contain:

- the `bus` dispatcher;
- the `bus-services` CLI;
- `bus-integration-services`;
- the selected Bus service binaries needed by the profile, such as
  `bus-events`, `bus-api`, `bus-integration`, and selected standalone
  integration/provider binaries when the profile chooses separate processes;
- default profile metadata and help/OpenCLI metadata;
- no raw tokens, customer secrets, or site-specific `.env` values.

The container should mount:

- `/etc/bus/services.yml` for the stack;
- `/etc/bus/profiles` for site or project profile overrides;
- `/etc/bus/config` for non-secret config files and credential-source labels;
- token files or secret files through explicit paths such as `/run/secrets`;
- `/var/lib/bus/services` for pid/status/frozen-stack state;
- `/var/log/bus` for bounded service logs or log references;
- data volumes required by selected services.

The normal command should remain recognizable as Bus:

```bash
bus services up --file /etc/bus/services.yml --profile-dir /etc/bus/profiles
```

The implementation may add an explicit foreground/container flag such as
`--foreground` or `--container`, or it may make foreground behavior automatic
when `bus services up` is PID 1. The important contract is that Compose can run
one long-lived container and Docker stop/restart semantics map cleanly to Bus
service startup and shutdown.

## Required Command Behavior

`bus services up` inside Docker should:

- load the mounted stack file, env files, and profile directories;
- reject missing required config, token-file, credential-source, profile, or
  data-dir references before starting child processes;
- freeze the resolved stack into the state directory before starting children;
- start selected services in dependency order;
- keep only explicitly declared environment variables for child processes;
- keep token values out of command arguments, status output, logs, and frozen
  stack state;
- keep running in the foreground while required children are healthy;
- forward `SIGTERM` and `SIGINT` to children and wait for graceful shutdown;
- kill remaining children after a bounded timeout;
- reap exited children so the container does not accumulate zombies;
- exit non-zero if a required child exits unexpectedly or readiness fails;
- optionally keep optional services failed/degraded when the stack marks them
  optional;
- write script-friendly JSON and human-readable status.

`bus services ps` inside the same container should report:

- selected services and groups;
- status: starting, running, degraded, failed, stopped, optional-failed;
- pid and process-group identity where applicable;
- runtime kind/provider;
- dependency state;
- readiness endpoint state;
- last start time and last exit time;
- log path or bounded log reference;
- config path labels;
- token-file or credential-source labels;
- last actionable error without secret values.

`bus services down` should use the frozen stack when available so edited or
missing source config does not prevent cleanup of already-started processes.

## Compose Example

This branch includes a starter Compose file:

```text
docs/docs/goals/services-docker/compose.yml
```

The file is intentionally a goal fixture rather than completed product proof.
It shows the expected container contract: one `bus-services` container, mounted
stack/profile/config paths, persistent state/data/log volumes, and a foreground
`bus services up` command. A future implementation should be able to run:

```bash
docker compose -f docs/docs/goals/services-docker/compose.yml config
docker compose -f docs/docs/goals/services-docker/compose.yml up
```

against an image that implements this goal.

## Relationship To Other Goals

### Systemd User Deployment

This Docker goal is the container-packaging sibling of
`systemd-user-deployment.md`. Both goals want the same operator
outcome: one named service profile, or a very small number of explicit service
surfaces, starts the required Bus infrastructure without manually launching
each handler.

The difference is ownership of the outer supervisor. The systemd goal uses
`systemd --user` as the outer service manager. This goal uses Docker or Compose
to start one Bus services container, and `bus services up` supervises the Bus
processes inside that container.

### Service-Owned Events Relay

The Docker service profile should be able to run the Events relay as one of
its managed services when the selected environment needs local-to-remote task
and evidence movement. Manual import/export, SSH sync loops, and `--sync-now`
remain bootstrap or recovery surfaces.

Live remote-worker acceptance for this Docker goal depends on relay status and
cursors being good enough that task Events and terminal evidence move without a
manual sync loop.

### Service-Owned Task Scheduler And Workers

The Docker profile should eventually start the service-owned scheduler and
worker lifecycle services that consume queued task work and launch Codex App
Server workers. `bus-services` should not become the scheduler owner; it should
start and observe the service that owns scheduling.

Full proof that the containerized profile replaces manual handler launches
depends on the scheduler, exact-ref worker safety, and App Server worker
lifecycle being complete enough for the selected remote.

### Remote Freshness

Remote freshness should be able to update or install the Bus services image,
mounted stack config, profile directories, token-file references, and data/log
volume layout before starting or restarting the Compose service. It should
report source, image, service, model, config, and credential-source identity
without secrets.

### Durable Task And Notes Evidence

The container profile must not hide memory-backed Events data loss. If a
selected profile uses memory-backed Events for a disposable smoke, that should
be explicit. Normal development profiles should use durable Events storage, and
restart paths should export or refuse before discarding visible task or Notes
Events.

## Suggested First Implementation Slices

Start with `bus-services` and `bus-integration-services`.

1. Add a foreground/container contract for `bus services up`.
   The command should either support an explicit `--foreground` flag or detect
   PID 1/container mode and remain in the foreground while the stack is up.

2. Make `bus services up` delegate foreground supervision to
   `bus-integration-services serve` or an equivalent library path, instead of
   launching a detached helper that immediately returns.

3. Harden `bus-integration-services` child supervision for PID 1 use:
   process groups, signal forwarding, graceful timeout, zombie reaping,
   unexpected child-exit policy, dependency-order shutdown, and frozen-stack
   cleanup.

4. Add container-safe state, log, and config defaults:
   `/var/lib/bus/services`, `/var/log/bus`, `/etc/bus/services.yml`,
   `/etc/bus/profiles`, `/etc/bus/config`, and `/run/secrets`.

5. Add status and health behavior usable by Docker health checks:
   `bus services ps --format json` should identify required service failures
   and readiness failures without printing secrets.

6. Add image/build documentation and fixture tests for a minimal image that
   contains the dispatcher, `bus-services`, `bus-integration-services`, and
   two tiny test service binaries or shell-compatible commands.

7. Run a live dev-hg Docker proof after deterministic tests pass. The proof
   should use a feature branch/worktree, build or select a Bus services image,
   run the Compose file, confirm `bus services up` stays in the foreground,
   inspect `bus services ps`, stop the Compose project, and verify child
   processes stopped cleanly.

## Verification Requirements

Minimum deterministic coverage:

- stack load from mounted absolute paths;
- profile-dir resolution inside a container filesystem;
- foreground `bus services up` process stays alive while services run;
- `SIGTERM`/`SIGINT` graceful shutdown;
- child process reaping;
- required child unexpected exit produces non-zero container exit;
- optional service failure reports degraded status without killing the stack
  when configured;
- dependency-order startup and shutdown;
- frozen-stack down after source config changes or disappears;
- state/log path defaults for container mode;
- Docker health-check friendly JSON status;
- token-file and credential-source labels in output;
- secret redaction for env files, token files, command output, logs, and frozen
  state;
- Compose config fixture parses successfully.

Minimum live proof on `coding-agent@dev.hg.fi`:

- create a remote worktree and feature branch for the proof;
- record Docker and Compose versions;
- build or select the Bus services runtime image;
- run `docker compose -f docs/docs/goals/services-docker/compose.yml up`;
- confirm the container command is `bus services up`;
- confirm at least two Bus child services start inside the container;
- confirm `bus services ps --format json` reports running services;
- stop the Compose project with Docker's normal stop path;
- confirm child processes are stopped and no stale pid/status files claim
  running services;
- record any manual step as a defect or follow-up.

## Suggested Commands For A Future Thread

From the BusDK superproject root, inspect current state:

```bash
git status --short
git -C bus-services status --short
git -C bus-integration-services status --short
git -C bus-integration-containers status --short
git -C bus-operator-deploy status --short
git -C docs status --short
```

Inspect current Services behavior:

```bash
bus-services/bin/bus-services --help
bus-services/bin/bus-services profiles
bus-services/bin/bus-services up --help
bus-integration-services/bin/bus-integration-services serve --help
```

Check the Compose fixture:

```bash
docker compose -f docs/docs/goals/services-docker/compose.yml config
```

Run live proof only after implementation and deterministic tests pass:

```bash
ssh coding-agent@dev.hg.fi 'docker version --format "client={{.Client.Version}} server={{.Server.Version}}"; docker compose version --short'
```

Do not run a mutating remote proof from the primary checkout. Create an
isolated remote worktree and branch first, then record the remote worktree path
and branch in this goal or in the implementation handoff.

## Current State At Handoff

The Docker services goal is defined, and the docs worktree contains a Compose
fixture showing the intended shape. The product implementation is not complete.

`bus-services` and `bus-integration-services` already have enough stack and
native-process vocabulary to make this a focused implementation goal rather
than a greenfield design. The missing product behavior is the Docker/PID 1
contract: foreground `bus services up`, signal handling, child supervision,
health/status, secret-safe mounted config, and a live Compose proof.

Do not mark this goal complete until repository code, tests, docs/help, the
Compose fixture, and a dev-hg or equivalent Docker proof show that one Bus
services container can start, report, and stop multiple Bus services through
`bus services up` without manual handler launches.

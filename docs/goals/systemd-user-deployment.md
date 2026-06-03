# Systemd User Deployment Handoff

## Goal

This conversation thread is about making Bus infrastructure on local and remote
worker environments start through `systemd --user` services instead of manual
handler launches.

Refined direction from 2026-06-03: the preferred systemd shape is one user
service that executes `bus services up` for a Bus Services stack. `systemd`
owns the outer service lifetime, while `bus-services` and
`bus-integration-services` supervise multiple Bus service processes inside
that one service. This is intentionally similar to Docker Compose from an
operator point of view, but it is not a Docker-only deployment model.

The requested end state is:

- A local or remote worker environment can start the required Bus API, Events,
  integration, provider, relay, scheduler, and worker-runtime handlers through
  one named user-level systemd unit whose `ExecStart` runs `bus services up`.
- The default service shape is one `bus-services` stack with entries for
  `bus-events`, selected `bus-integration-*` handlers, selected
  `bus-api-provider-*` handlers or a combined `bus-api` host, relay/scheduler
  services when enabled, and optional model/container runtime checks.
- Rootless Docker or Podman is a worker/container runtime dependency and image
  cache, not the default host for the Bus control plane.
- The systemd unit references explicit `services.yml`, profile directories,
  config files, token files, credential-source labels, or environment-file
  paths. It does not embed raw token values, provider secrets, or depend on a
  process-global `BUS_API_TOKEN` as the normal credential path.
- A fresh or non-persistent dev-hg, H100, UpCloud-style, or local worker host
  can be checked, installed, updated, started, and inspected without manually
  launching every handler.

This handoff exists so a future conversation can resume the same goal without
reconstructing it from chat history.

## Active Worktree

The 2026-06-03 goal-refinement artifacts are being prepared in an isolated docs
worktree:

```text
branch: codex/bus-services-systemd-goal
worktree: /Users/jhh/git/busdk/agent-supervisor/worktrees/docs-bus-services-systemd
base docs commit: 5be8b24
```

The primary BusDK checkout and remote `coding-agent@dev.hg.fi` checkout should
not be edited or merged for this goal until the operator confirms the work.

## Operator Direction Captured

The operator asked what the project actually needs to do for:

> Systemd user deployment for Bus infrastructure: A local or remote worker
> environment can start the required Bus API, Events, integration, and provider
> handlers as one or a few user services without manually launching each
> handler.

The operator then asked whether `coding-agent@dev.hg.fi` can use systemd
services. The answer from remote evidence was yes: the host supports
`systemd --user`, user lingering is enabled, and rootless Docker is active.
The specific Bus units are not installed yet.

The goal is planning and implementation toward a real service-owned readiness
path. It is not satisfied by manual SSH recipes, manually exporting tokens,
Docker Compose as the required production host, or one systemd daemon per
handler as the default architecture. Docker Compose may remain a development
fixture and comparison point, especially while other Docker development work is
running in parallel.

## Current Evidence

Remote evidence gathered on 2026-05-28 from `coding-agent@dev.hg.fi`:

```text
user=coding-agent
uid=1004
systemctl --user is-system-running: running
loginctl State=active
loginctl Linger=yes
RuntimePath=/run/user/1004
docker.service enabled=enabled
docker.service active=active
```

Rechecked on 2026-06-03 from the supervisor host with a non-mutating SSH
status command:

```text
user=coding-agent uid=1004
systemctl --user is-system-running: running
RuntimePath=/run/user/1004
State=active
Linger=yes
docker.service enabled=enabled
docker.service active=active
```

Bus's own status surface also succeeded:

```bash
bus-operator-deploy/bin/bus-operator-deploy service user-systemd status \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-dev-task
```

That was the service name used in the original remote evidence. Current
`bus-operator-deploy` implementation and plans use `bus-integration-task` for
the task integration unit, so future reruns should use the current service
name unless intentionally checking historical compatibility:

```bash
bus-operator-deploy/bin/bus-operator-deploy service user-systemd status \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-task
```

That command returned `ok: true`, classified the host as `linger-enabled`, and
reported `user_manager_active=yes` and `rootless_docker=yes`.

The same historical command reported that the old-name Bus units were not yet
installed:

```text
bus-events.service                 enabled=not-found active=inactive
bus-container-router.service       enabled=not-found active=inactive
bus-integration-dev-task.service   enabled=not-found active=inactive
```

Conclusion: `coding-agent@dev.hg.fi` can run user-level systemd services now.
The missing work is installing and configuring the Bus service units or the
future combined-runtime service profile with explicit config and token-file
paths.

Review update on 2026-06-03: the missing work should be reframed from
"install several Bus units" to "install one Bus Services systemd unit plus its
stack files". The existing separate-unit support remains useful compatibility,
but the target implementation should make `bus services up` the inner
multi-process service manager.

## Current Tracker State

The root tracker records this under `PLAN.md` in the current remote-worker
finish line. The relevant root text defines the systemd user deployment goal as
the normal readiness path for local, dev-hg, H100, and UpCloud-style worker
environments.

The owner for deployment mechanics is `bus-operator-deploy/PLAN.md`, under:

```text
Add an administrator-configured single-runtime Bus service profile for
user-level systemd hosts.
```

That item should remain the main implementation entry until the user-systemd
profile is real.

The product owner for the inner service stack is the Services module family:

- `bus-services` owns `bus services up|down|ps`, stack file UX, foreground
  systemd mode, and operator-facing output.
- `bus-api-provider-services` owns the Services API/controller surface and
  canonical non-secret service Events.
- `bus-integration-services` owns runtime integration, lifecycle
  reconciliation, child process supervision, and service status snapshots.
- `bus-operator-deploy` owns rendering, installing, updating, and inspecting
  the outer `systemd --user` unit and the stack/config/token files it points
  at.

The API provider side is tracked in `bus-api/PLAN.md`, under:

```text
Productize administrator-selectable multi-provider API hosting end to end.
```

That item is needed because the user-systemd profile should be able to start
one `bus-api` host that loads selected API providers from config, rather than
one API-provider daemon per module.

The integration side is mostly ahead of the deployment surface. `bus-integration`
already has a completed combined-host plan item: `cmd/bus-integration` can load
an explicit runtime config, start selected compiled integration registrations,
share an Events client and token source, and expose health readiness.
The stock `bus-integration` binary contains no provider registrations by
itself; a deployable combined worker-host profile still needs a concrete host
binary or registration set that imports the selected `bus-integration-*`
modules.

Review update on 2026-05-30: newer remote-worker planning has shifted task and
worker ownership from older `bus-integration-dev-task` wording toward
`bus-integration-task`, `bus-integration-worker`, and the plural workers
surface. Treat root `PLAN.md`, `bus-integration-task/PLAN.md`, and
`bus-integration-worker/PLAN.md` as the current authority for task scheduler
and worker-service ownership before implementing this goal.

## Current Implementation Baseline

`bus-operator-deploy` already has a first user-systemd slice for separate
allowlisted services. The current allowlisted definitions include:

- `bus-events.service`
- `bus-container-router.service`
- `bus-integration-task.service`

The existing command family is:

```bash
bus operator deploy service user-systemd plan
bus operator deploy service user-systemd status
bus operator deploy service user-systemd install
bus operator deploy service user-systemd update
```

Executable install and update already require explicit `--dry-run=false`,
OpenSSH target selection, and absolute config/unit directories. The current
renderer references config and token-file paths only; it does not embed raw
secret values in unit files.

This is useful, but it is not the final goal. The remaining architecture work
is a named Bus Services stack so the normal path is one systemd unit running
`bus services up`, not one unit per integration or provider.

## Target Service Shape

The preferred default profile should be something like `dev-worker`,
`remote-worker`, or another explicit configured profile name. The exact name is
less important than the contract. The outer systemd unit should look like this
in shape, with exact paths rendered by `bus-operator-deploy`:

```ini
[Service]
Type=notify
WorkingDirectory=/path/to/busdk
EnvironmentFile=/path/to/bus-services.env
ExecStart=bus services up --file /path/to/services.yml --foreground --systemd-notify
ExecReload=bus services reload --file /path/to/services.yml
ExecStop=bus services down --file /path/to/services.yml
Restart=on-failure
```

If `Type=notify` is not available for the first slice, `Type=simple` is an
acceptable stepping stone as long as `bus services up --foreground` stays in
the foreground and exits non-zero when required child services cannot be kept
healthy. `ExecStart` may be rendered as `bus-services stack up ...` only as a
compatibility spelling; the dispatcher-facing target is `bus services up`.

The profile should manage:

- An environment-local Events API service entry.
- Selected integration service entries, such as task workers,
  `bus-integration-services`, container integration, SSH runner behavior, relay
  workers, and other provider-adjacent event workers.
- Optional API/provider service entries, either as standalone provider entries
  or as one configured `bus-api` host when the provider-hosting work is ready.
- Rootless Docker or Podman as a dependency for container execution when the
  selected profile needs it.
- Model runtime readiness checks where the selected worker profile requires a
  local model endpoint.
- Token-file, credential-source, and config-file readiness checks.

Separate-process and container-backed handlers remain valid administrator
choices. They should be explicit modes, not the default readiness path for
dev-hg/H100-style worker hosts. They should still be represented as entries in
the Bus Services stack, so `bus services ps` and systemd status can report the
whole profile coherently.

## Profile Contract

The profile should be accepted from an explicit config file or a built-in named
profile. It should declare:

- the outer systemd unit name and description;
- the `services.yml` path, profile directories, env files, state directory,
  log directory, and working directory;
- enabled Bus Services stack entries;
- integration registrations or standalone integration command entries;
- API providers for the optional `bus-api` host, or standalone API provider
  service entries;
- health and readiness endpoints;
- systemd dependencies and ordering;
- restart policy;
- config file paths;
- token-file or credential-source paths;
- optional rootless Docker or Podman dependency;
- optional model runtime readiness expectations.

Generated unit files, stack files, and command output may reference config
files, token files, credential-source labels, and environment-file paths. They
must not print or embed raw tokens, provider secrets, private keys, or broad
`.env` contents.

## Required Command Behavior

`bus operator deploy service user-systemd plan|install|update|status` should be
able to render, install, update, restart, and report the named
`bus services` profile.

Plan mode should be non-mutating and show the exact systemd unit,
`services.yml`, env/profile/config/token paths, dependencies, and service
actions that would be used.

Install and update should:

- require explicit mutation approval, such as `--dry-run=false`;
- require concrete OpenSSH target selection;
- require absolute config and unit directories for executable remote writes;
- write changed unit files and changed Bus Services stack/config files;
- run `systemctl --user daemon-reload` when needed;
- enable the outer unit;
- start or restart the outer unit when the unit, stack, config, token-source
  labels, binary identity, or selected runtime inputs changed;
- avoid restarting already-current services unnecessarily;
- report actions in JSON and human-readable text.

Status should report:

- installed, enabled, active, failed, and missing outer unit state;
- linger-enabled versus login-session-scoped service lifetime;
- user-manager health;
- rootless Docker or Podman dependency state;
- `bus services ps` status for each stack entry;
- Events readiness;
- integration, relay, scheduler, worker, and optional Bus API readiness;
- config path labels;
- token-file or credential-source labels;
- last actionable error without token values.

## Bus Services Requirements

`bus-services` needs a systemd-ready mode before the target unit can be
accepted as more than a wrapper. The target behavior is:

- `bus services up --file <services.yml> --foreground` starts all selected
  services in dependency order and remains the foreground supervisor process.
- It forwards SIGTERM/SIGINT to child services, drains them in reverse
  dependency order, and exits with an actionable status.
- It writes non-secret child status snapshots for `bus services ps` and for
  `bus-operator-deploy service user-systemd status`.
- It supports log paths or journal labels for each child without dumping
  unbounded logs into Events or status output.
- It supports systemd notification when available: ready only after required
  child services pass readiness, watchdog updates while healthy, and degraded
  status when optional services fail.
- It keeps `bus services down` as an explicit stop/recovery command and maps
  cleanly to systemd `ExecStop`.
- It validates public stack configuration before mutation and refuses inline
  secrets in stack files.
- It can run inside a Docker Compose fixture for development without claiming
  Docker Compose is the production host.

The first implementation slice may keep existing stack semantics for normal
interactive use, but the systemd profile acceptance needs a foreground service
mode with tests for signal handling, dependency ordering, child restart policy,
readiness, status output, and secret redaction.

## Relationship To Other Goals

This goal depends on and reinforces several adjacent remote-worker goals.

### Service-Owned Task Scheduler

The user-systemd profile should eventually start or depend on the
service-owned scheduler that consumes queued task work and launches Codex App
Server workers up to configured capacity. That scheduler is described
separately in `service-owned-task-scheduler.md`, but the current
module owner is `bus-integration-task` with worker-side behavior moving into
`bus-integration-worker`.

The important boundary is that `bus-dev` should submit work and display status,
but the long-running environment-local service owns scheduling, capacity, stale
claim handling, and worker launch.

Dependency: a profile-rendering implementation in `bus-operator-deploy` can
start before the scheduler is complete, but the live proof that a worker task
starts without manual handler launches depends on the service-owned scheduler,
exact-ref worker safety, and worker App Server lifecycle being complete enough
for the selected remote.

The systemd-specific slice should not block on every scheduler feature. It can
ship a Bus Services stack that includes the scheduler service entry and reports
it as missing/degraded until the scheduler implementation is ready. The live
remote-worker acceptance remains blocked until the scheduler can actually
launch the intended worker.

### Remote Credential Source Selection

Systemd unit files should not depend on a supervisor shell's
process-global `BUS_API_TOKEN`. Credentials should come from explicit token
files, credential-source references, user config, deployment secret files, or
other designed secret sources.

Missing, unreadable, expired, or unsupported credentials should fail early with
diagnostics that name the safe source label and selected remote id/kind, never
the token value.

### Service-Owned Events Relay

Remote worker readiness also needs Events movement to be service-owned.
Manual export/import, SSH sync loops, or `--sync-now` should be recovery/debug
tools, not the normal daily path.

The user-systemd profile should eventually install or supervise the relay
service path when the selected environment requires local-to-remote task and
evidence synchronization.

Dependency: the live remote-worker proof for this goal depends on the
service-owned Events relay goal being complete enough that local task Events and
remote claim/progress/terminal evidence move without manual import/export,
SSH sync loops, or `bus-dev --sync-now` as the normal path.

### Remote Freshness

The service profile is only useful if the remote has the right source,
submodule pins, installed binaries, images, units, and config files. The
remote freshness command is described separately in
`remote-freshness-command.md`.

The intended relationship is:

1. Refresh source/tools/images/config.
2. Install or update the Bus Services stack files and outer user-systemd unit.
3. Start or restart the outer unit only when inputs changed.
4. Report source, tool, image, service, model, config, and credential-source
   evidence before worker dispatch.

### Docker Compose Development

Docker Compose development may be running at the same time as this work. The
systemd/Bus Services proof should avoid generic Compose project names, shared
volumes, and host ports that can collide with the existing root
`compose.yaml`. The example fixture for this goal lives at:

```text
docs/docs/goals/systemd-user-deployment/compose.yml
```

It uses a distinct Compose project name and is only a development harness for
the same `bus services up --foreground` command that the systemd unit should
run.

## Suggested Next Implementation Slices

Start with `bus-services` and `bus-integration-services`, then wire
`bus-operator-deploy`.

1. Add foreground/systemd mode for `bus services up`.
   It should run selected stack entries as supervised child processes, keep the
   parent process alive, handle signals, expose `ps` status, and avoid leaking
   secrets into output or status files.

2. Add stack entries/profiles for the minimum Bus worker-host profile:
   Events API, `bus-integration-services`, selected task/worker integration
   services, service-owned relay when configured, optional API provider host,
   and rootless Docker/Podman readiness checks.

3. Extend `bus-operator-deploy service user-systemd` so a named profile renders
   one outer unit plus `services.yml`, env files, profile dirs, config path
   references, token-source labels, and state/log directories. Keep the
   existing separate allowlisted unit rendering as an explicit compatibility
   mode.

4. Add profile-aware status parsing. Status should distinguish missing outer
   unit, inactive unit, failed unit, missing stack file, missing config file,
   missing token file, inactive rootless Docker dependency, unavailable Events
   API, unavailable integration readiness endpoint, unavailable scheduler/relay,
   and unavailable optional API provider host.

5. Add tests for built-in and file-backed profiles, `bus services` foreground
   mode, child dependency ordering, signal handling, systemd notify readiness,
   separate-unit compatibility mode, absolute-path gating, unit/stack-file
   secret redaction, OpenSSH script generation, status parsing, and missing
   config/token diagnostics.

6. Wire `bus-api` provider-hosting requirements into a deployable stack config.
   Do not block the first systemd proof on every API provider. The first proof
   can use no API service or one minimal provider set, as long as the stack
   contract supports adding the `bus-api` service.

7. Run a dev-hg or H100 live proof after tests pass. The proof should start
   from a fresh or restarted host, run status, install or update the profile,
   start services, confirm readiness, and run a worker task without manual
   handler launches.

## Suggested Commands For A Future Thread

From the BusDK superproject root, inspect current state first:

```bash
git status --short
git -C bus-operator-deploy status --short
git -C bus-services status --short
git -C bus-integration-services status --short
git -C bus-api-provider-services status --short
git -C bus-api status --short
git -C bus-integration status --short
git -C bus-integration-task status --short
git -C bus-integration-worker status --short
```

Recheck the remote user-systemd capability:

```bash
ssh coding-agent@dev.hg.fi 'printf "user=%s uid=%s\n" "$(id -un)" "$(id -u)"; systemctl --user is-system-running; loginctl show-user "$(id -un)" -p Linger -p State -p RuntimePath; systemctl --user is-enabled docker.service; systemctl --user is-active docker.service'
```

Recheck through the Bus deploy surface:

```bash
bus operator deploy service user-systemd status \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-task
```

Before running an actual install, verify the remote home/config paths and token
file paths. Executable install/update should use absolute paths.

Current separate-unit install shape, if the operator chooses to test it before
the Bus Services profile exists:

```bash
bus operator deploy service user-systemd install \
  --dry-run=false \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-task \
  --config-dir /absolute/path/to/.config/bus \
  --unit-dir /absolute/path/to/.config/systemd/user
```

Do not run that install command until the config and token files exist and the
operator is ready for remote mutation.

Target Bus Services unit shape, once implemented:

```bash
bus operator deploy service user-systemd install \
  --dry-run=false \
  --ssh-url coding-agent@dev.hg.fi \
  --profile dev-worker-services \
  --services-file /absolute/path/to/services.yml \
  --config-dir /absolute/path/to/.config/bus \
  --unit-dir /absolute/path/to/.config/systemd/user \
  --state-dir /absolute/path/to/.local/state/bus-services
```

Do not run that install command until the `bus services up --foreground`
implementation, stack files, token files, and remote path checks are ready.

## Verification Requirements

Planning-only closeout is not enough for the product goal.

Minimum deterministic coverage:

- render built-in Bus Services systemd profile;
- render file-backed Bus Services systemd profile;
- render one outer unit running `bus services up`;
- render `services.yml` and profile/env/config references;
- run `bus services up --foreground` in fixture mode;
- child dependency ordering;
- signal handling and reverse-order shutdown;
- child restart/degraded status policy;
- systemd notify readiness or explicit `Type=simple` fallback behavior;
- render separate service mode;
- dependency ordering;
- executable OpenSSH script generation;
- absolute-path gating for mutating remote writes;
- status parsing for installed, enabled, active, failed, inactive, and missing
  outer units;
- `bus services ps` parsing for child services;
- linger-enabled and login-session-scoped detection;
- rootless Docker dependency status;
- missing config file diagnostics;
- missing token-file or credential-source diagnostics;
- unit-file, stack-file, status-file, and output secret redaction;
- README/help/OpenCLI metadata for the new profile surface.

Minimum live proof:

- target dev-hg or H100 host has user systemd manager active;
- linger state is recorded;
- rootless Docker dependency is recorded if required;
- source/tool freshness is recorded;
- user-systemd profile install or update succeeds;
- the outer unit runs `bus services up`;
- status reports the expected Bus Services stack entries active or explicitly
  degraded with actionable reasons;
- a worker task starts without manually launching each handler;
- terminal task evidence returns to the local supervisor;
- any manual step is recorded as a defect or follow-up.

## Current State At Handoff

The planning goal is defined. The host capability question is answered:
`coding-agent@dev.hg.fi` can use user-level systemd services. The specific Bus
user services are not installed there yet.

The first implementation target is now the Services path:
`bus-services`/`bus-integration-services` need foreground multi-process
supervision for `bus services up`, and then `bus-operator-deploy` should render
one outer user-systemd unit plus stack/config files for that command.
`bus-integration` already has the combined host foundation, and `bus-api` still
needs the provider-host side for optional API provider services.
The remote-worker task proof also depends on the current `bus-integration-task`
and `bus-integration-worker` scheduler/lifecycle work, plus service-owned
Events relay, before the systemd profile can be accepted as the normal
no-manual-handler launch path.

Do not mark the product goal complete until the repository has code, tests,
docs/help, and live or equivalent fixture proof that a local or remote worker
environment can start required Bus infrastructure as one or a few user services
without manual handler launches.

## Deferred From Accepted Workers MVP

The accepted local workers MVP now has a native local Services stack that can
start PostgreSQL, Events API, repos integration, workers integration, and the
Bus API gateway with `bus services up`. Broader service operations remain here:

- installing and updating user-level service units;
- making local or remote worker environments restartable without manual handler
  launches;
- exposing service health and deployment status;
- binding service configuration to token files, config files, and non-secret
  credential-source labels rather than raw secrets.

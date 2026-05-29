# Systemd User Deployment Handoff

## Goal

This conversation thread is about making Bus infrastructure on local and remote
worker environments start through `systemd --user` services instead of manual
handler launches.

The requested end state is:

- A local or remote worker environment can start the required Bus API, Events,
  integration, and provider handlers as one named service profile or a small
  number of explicit user services.
- The default service shape is `bus-events`, one combined `bus-integration`
  runtime for selected integration and provider-adjacent handlers, and
  optionally one `bus-api` runtime for selected API providers.
- Rootless Docker or Podman is a worker/container runtime dependency and image
  cache, not the default host for the Bus control plane.
- Unit files reference explicit config files, token files, credential-source
  labels, or environment-file paths. They do not embed raw token values,
  provider secrets, or depend on a process-global `BUS_API_TOKEN` as the normal
  credential path.
- A fresh or non-persistent dev-hg, H100, UpCloud-style, or local worker host
  can be checked, installed, updated, started, and inspected without manually
  launching every handler.

This handoff exists so a future conversation can resume the same goal without
reconstructing it from chat history.

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
path. It is not satisfied by Compose-only starts, manual SSH recipes, manually
exporting tokens, or one daemon per handler as the default architecture.

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

Bus's own status surface also succeeded:

```bash
bus-operator-deploy/bin/bus-operator-deploy service user-systemd status \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-dev-task
```

That command returned `ok: true`, classified the host as `linger-enabled`, and
reported `user_manager_active=yes` and `rootless_docker=yes`.

The same command reported that the currently allowlisted Bus units are not yet
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

## Current Implementation Baseline

`bus-operator-deploy` already has a first user-systemd slice for separate
allowlisted services. The current allowlisted definitions include:

- `bus-events.service`
- `bus-container-router.service`
- `bus-integration-dev-task.service`

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
is a named combined-runtime profile so the normal path is one or a few services,
not one service per integration or provider.

## Target Service Shape

The preferred default profile should be something like `dev-worker`,
`remote-worker`, or another explicit configured profile name. The exact name is
less important than the contract.

The profile should manage:

- `bus-events.service` for the environment-local Events API.
- One combined `bus-integration` service for selected integration handlers,
  such as task workers, Docker/container integration, SSH runner behavior, and
  other provider-adjacent event workers that belong in integration land.
- Optionally one `bus-api` service for selected API providers.
- Rootless Docker or Podman as a dependency for container execution when the
  selected profile needs it.
- Model runtime readiness checks where the selected worker profile requires a
  local model endpoint.
- Token-file, credential-source, and config-file readiness checks.

Separate-process and container-backed handlers remain valid administrator
choices. They should be explicit modes, not the default readiness path for
dev-hg/H100-style worker hosts.

## Profile Contract

The profile should be accepted from an explicit config file or a built-in named
profile. It should declare:

- enabled Bus services;
- integration registrations for the combined `bus-integration` host;
- API providers for the optional `bus-api` host;
- health and readiness endpoints;
- systemd dependencies and ordering;
- restart policy;
- config file paths;
- token-file or credential-source paths;
- optional rootless Docker or Podman dependency;
- optional model runtime readiness expectations.

Generated unit files and command output may reference config files, token files,
credential-source labels, and environment-file paths. They must not print or
embed raw tokens, provider secrets, private keys, or broad `.env` contents.

## Required Command Behavior

`bus operator deploy service user-systemd plan|install|update|status` should be
able to render, install, update, restart, and report the named profile.

Plan mode should be non-mutating and show the exact units, config paths, token
paths, dependencies, and service actions that would be used.

Install and update should:

- require explicit mutation approval, such as `--dry-run=false`;
- require concrete OpenSSH target selection;
- require absolute config and unit directories for executable remote writes;
- write changed unit files;
- run `systemctl --user daemon-reload` when needed;
- enable selected units;
- restart changed or inactive units;
- avoid restarting already-current services unnecessarily;
- report actions in JSON and human-readable text.

Status should report:

- installed, enabled, active, failed, and missing unit state;
- linger-enabled versus login-session-scoped service lifetime;
- user-manager health;
- rootless Docker or Podman dependency state;
- Events readiness;
- combined integration readiness;
- optional Bus API readiness;
- selected integration/provider readiness where available;
- config path labels;
- token-file or credential-source labels;
- last actionable error without token values.

## Relationship To Other Goals

This goal depends on and reinforces several adjacent remote-worker goals.

### Service-Owned Task Scheduler

The user-systemd profile should eventually start the service-owned scheduler
that consumes queued task work and launches Codex App Server workers up to
configured capacity. That scheduler is described separately in
`docs/docs/goals/service-owned-task-scheduler.md`.

The important boundary is that `bus-dev` should submit work and display status,
but the long-running environment-local service owns scheduling, capacity, stale
claim handling, and worker launch.

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

### Remote Freshness

The service profile is only useful if the remote has the right source,
submodule pins, installed binaries, images, units, and config files. The
remote freshness command is described separately in
`docs/docs/goals/remote-freshness-command.md`.

The intended relationship is:

1. Refresh source/tools/images/config.
2. Install or update user-systemd profile units.
3. Start or restart affected services only when inputs changed.
4. Report source, tool, image, service, model, config, and credential-source
   evidence before worker dispatch.

## Suggested Next Implementation Slices

Start with `bus-operator-deploy`.

1. Add a profile representation for user-systemd services.
   It should support at least one built-in profile and a file-backed profile.
   The first built-in profile can be minimal: `bus-events` plus combined
   `bus-integration`, with optional `bus-api`.

2. Extend rendering so a profile can produce one combined `bus-integration`
   unit instead of separate integration units by default. Keep the existing
   separate allowlisted unit rendering as an explicit mode.

3. Add profile-aware status parsing. Status should distinguish missing unit,
   inactive unit, failed unit, missing config file, missing token file,
   inactive rootless Docker dependency, unavailable Events API, unavailable
   integration readiness endpoint, and unavailable optional API provider host.

4. Add tests for built-in and file-backed profiles, combined and separate
   service modes, dependency ordering, absolute-path gating, unit-file secret
   redaction, OpenSSH script generation, status parsing, and missing
   config/token diagnostics.

5. Wire `bus-api` provider-hosting requirements into a deployable config.
   Do not block the first systemd proof on every API provider. The first proof
   can use no API service or one minimal provider set, as long as the profile
   contract supports adding the `bus-api` service.

6. Run a dev-hg or H100 live proof after tests pass. The proof should start
   from a fresh or restarted host, run status, install or update the profile,
   start services, confirm readiness, and run a worker task without manual
   handler launches.

## Suggested Commands For A Future Thread

Inspect current state first:

```bash
git status --short
git -C bus-operator-deploy status --short
git -C bus-api status --short
git -C bus-integration status --short
```

Recheck the remote user-systemd capability:

```bash
ssh coding-agent@dev.hg.fi 'printf "user=%s uid=%s\n" "$(id -un)" "$(id -u)"; systemctl --user is-system-running; loginctl show-user "$(id -un)" -p Linger -p State -p RuntimePath; systemctl --user is-enabled docker.service; systemctl --user is-active docker.service'
```

Recheck through the Bus deploy surface:

```bash
bus-operator-deploy/bin/bus-operator-deploy service user-systemd status \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-dev-task
```

Before running an actual install, verify the remote home/config paths and token
file paths. Executable install/update should use absolute paths.

Current separate-unit install shape, if the operator chooses to test it before
the combined profile exists:

```bash
bus-operator-deploy/bin/bus-operator-deploy service user-systemd install \
  --dry-run=false \
  --ssh-url coding-agent@dev.hg.fi \
  --service bus-events,bus-container-router,bus-integration-dev-task \
  --config-dir /absolute/path/to/.config/bus \
  --unit-dir /absolute/path/to/.config/systemd/user
```

Do not run that install command until the config and token files exist and the
operator is ready for remote mutation.

## Verification Requirements

Planning-only closeout is not enough for the product goal.

Minimum deterministic coverage:

- render built-in profile;
- render file-backed profile;
- render combined runtime mode;
- render separate service mode;
- dependency ordering;
- executable OpenSSH script generation;
- absolute-path gating for mutating remote writes;
- status parsing for installed, enabled, active, failed, inactive, and missing
  units;
- linger-enabled and login-session-scoped detection;
- rootless Docker dependency status;
- missing config file diagnostics;
- missing token-file or credential-source diagnostics;
- unit-file and output secret redaction;
- README/help/OpenCLI metadata for the new profile surface.

Minimum live proof:

- target dev-hg or H100 host has user systemd manager active;
- linger state is recorded;
- rootless Docker dependency is recorded if required;
- source/tool freshness is recorded;
- user-systemd profile install or update succeeds;
- status reports the expected Bus services active;
- a worker task starts without manually launching each handler;
- terminal task evidence returns to the local supervisor;
- any manual step is recorded as a defect or follow-up.

## Current State At Handoff

The planning goal is defined. The host capability question is answered:
`coding-agent@dev.hg.fi` can use user-level systemd services. The specific Bus
user services are not installed there yet.

The first implementation target is `bus-operator-deploy`: add profile-driven
user-systemd rendering, install/update, and status for a combined-runtime
worker-host profile. `bus-integration` already has the combined host foundation.
`bus-api` still needs the provider-host side for optional API provider services.

Do not mark the product goal complete until the repository has code, tests,
docs/help, and live or equivalent fixture proof that a local or remote worker
environment can start required Bus infrastructure as one or a few user services
without manual handler launches.

# Remote Freshness Command Handoff

## Goal

This conversation is about making the remote worker lane trustworthy enough that
a supervisor can dispatch real work to dev-hg, H100, or another configured
remote without manual environment repair.

The specific goal captured in this handoff is the remote freshness command:

> A worker environment can update root/submodules, build/install changed tools,
> rebuild/reload worker images only when needed, and record source, tool, and
> image identity.

This goal is part of the larger remote-worker lane. A configured environment
should run normal Bus services, consume queued development tasks, launch Codex
App Server workers up to configured capacity, return durable task and Notes
evidence, and give the local supervisor enough source/tool/image/service
identity to decide whether the remote is safe to use.

## Current Tracker State

The owning implementation tracker is
`bus-operator-deploy/PLAN.md`, under the item named:

```text
Add a development-host refresh command for accepted BusDK source, tool,
and worker-image updates.
```

The root tracker also points at this goal from the H100/offload checklist. The
root wording says `bus-operator-deploy` should provide the command that updates
root/submodules, builds or installs changed tools, rebuilds or reloads worker
images only when needed, restarts affected worker services only when inputs
changed, and records source/tool/image identity before dispatch.

The current bootstrap helper is:

```bash
scripts/remote-checkout-update.sh
```

That helper can fetch/fast-forward a superproject checkout, hydrate selected
submodules to checked-in pins, refuse dirty checkouts, and report root plus
submodule SHAs. It is acceptable bootstrap compatibility, but the target product
shape is a Bus-owned command that composes this behavior with tool, image, and
service freshness.

## Command Shape

The target command should be scriptable and idempotent. The plan currently
allows either:

```bash
bus operator deploy worker dev refresh ...
```

or an extension of:

```bash
bus operator deploy worker dev setup ...
```

The important requirement is not the exact spelling. The surface must have
distinct status, plan or dry-run, and mutating apply behavior. It should reuse
the existing Git freshness helper and worker image plan/archive/install
boundaries instead of inventing another SSH execution model.

## Source Freshness Contract

The command should resolve the target remote, checkout path, root branch, root
ref or root SHA, and selected submodules from remote/deploy config plus explicit
flags.

It should refuse dirty root or submodule checkouts unless a deliberate operator
policy says otherwise. The normal update path is fast-forwarding or detaching to
the requested root and hydrating selected submodules to checked-in pins.
Branch-head submodule updates must require an explicit option because checked-in
submodule pins are the normal authoritative state.

The output must report before and after root SHA, branch or detached ref,
selected submodule pin/head pairs, and whether each selected submodule changed,
was already current, was uninitialized, or was refused.

## Tool Freshness Contract

The command should build and install Bus tools only when needed. A build is
needed when source changed, a required binary is missing, or a configured
version/identity check is stale.

The configured build action can be `make build install` or an equivalent command
from deploy/remote config. Output must record each installed tool name, path,
version or help identity when available, and whether the build/install step ran
or was skipped.

The command must not treat a narrow smoke as proof of broad tool freshness
unless the smoke checks the tools that worker launch actually needs. For the
remote worker lane, that normally includes the relevant `bus` dispatcher path,
`bus-dev` or task command surface, `bus-events`, worker integration binaries,
and any App Server or model-runtime wrapper the remote profile requires.

## Image Freshness Contract

The command should inspect the configured worker image before rebuilding or
loading it. The identity facts are image tag, image id or digest, platform, and
source/build input identity.

Rebuild or reload only when:

- the image is missing;
- the platform is incompatible;
- source inputs changed;
- configured image build inputs changed;
- policy explicitly requests a forced rebuild.

Cross-host private image movement should reuse the existing
`worker image plan`, `worker image archive`, and `worker image install` surfaces
in `bus-operator-deploy`. GHCR or another registry may be an operator-selected
source, but the first private/dev path should not require GHCR visibility or
publishing private software.

## Service Freshness Contract

The command should reload or restart user services only when a binary, image,
service unit, config file, token-file reference, or other relevant input
changed.

The status output should distinguish:

- restarted;
- reloaded;
- already current;
- skipped by policy;
- failed;
- blocked by missing config or missing credential source.

This should compose with the user-systemd service work in `bus-operator-deploy`.
The target worker-host service shape is one named user service profile, or a
small number of services, rather than a manual start command for every handler.
The default shape discussed in this thread is `bus-events`, one combined
`bus-integration` runtime for selected integration/provider handlers, and
optionally one `bus-api` runtime for selected API providers.

## Evidence Contract

The command must emit JSON and human-readable text. The evidence should be good
enough for a supervisor to decide whether it is safe to dispatch work.

Required non-secret evidence:

- remote id and remote kind;
- command mode: status, dry-run/plan, or apply;
- before and after root SHA and branch/ref;
- selected submodule pin/head pairs;
- dirty-check results;
- build/install decisions;
- installed tool names, paths, and version/help identities;
- worker image tag, id or digest, platform, and source identity;
- service reload/restart/skip decisions;
- rollback or recovery hints;
- credential source labels, never token values.

The command must not print raw token values, private keys, broad `.env` contents,
provider secrets, or secret command-line arguments. Credentials should come from
existing OpenSSH/Git/Docker configuration, token files, user config, deployment
secret files, OS credential storage, or stdin-aware secret mechanisms where
explicitly designed.

## Verification Requirements

The plan requires fixture coverage for at least these cases:

- stale root;
- stale submodule;
- already-current checkout;
- dirty checkout refusal;
- build-needed;
- build-skipped;
- missing binary;
- image missing;
- image current;
- image rebuild;
- service restart;
- service skip;
- redacted output.

It also requires at least one local no-network apply fixture using temporary Git
repositories and fake build/image/service commands.

Live closeout requires an operator-run dev-hg or H100 smoke that records the
identity manifest before dispatching worker tasks.

## Related Goals Discussed In This Thread

Remote freshness is not useful by itself. It is one required piece of the
trustworthy remote worker lane.

### Service-Owned Task Scheduler

A service must consume queued task work and start App Server workers up to
capacity. It must avoid replaying stale claims, bind launches to the intended
work ref, and expose current queue/worker/capacity status. This is tracked in
`bus-integration-task/PLAN.md` under the service-owned scheduler and task
integration ownership items.

### Credential Source Selection

Controller credentials, remote Events credentials, and worker runtime
credentials must come from explicit token files or configured credential
sources as the normal path. `BUS_API_TOKEN` is only a fallback. Expired or
missing credentials should fail before worker/model startup with safe,
actionable diagnostics.

The root tracker currently marks the coordinated credential-source contract as
completed, with verification across `bus-dev`, `bus-events`,
`bus-integration-task`, `bus-remote`, and `bus-integration-ssh-runner`.

### User-Systemd Deployment

Remote readiness should not depend on manually launching each handler. The
target is a user-systemd service profile that can start the required Bus
infrastructure as one or a few services. Unit files should reference explicit
config files and token-file or credential-source paths, not raw secrets.

### Durable Task And Notes Evidence

Normal development services should not use memory-backed Events storage for
retained task history. If a memory-backed service is still used for bootstrap or
disposable smokes, visible task and Notes Events must be exported before restart
or replacement.

Worker Notes should flow through `bus.notes.*` Events, move through Events
sync/relay with origin metadata and cursors, materialize into durable Notes
storage, and remain queryable by module, task, session, tag, source, and origin.

### First-Class Artifact Transfer

Remote patch/log/evidence transfer should use task attachments rather than
`scp` or ad hoc shared paths. `bus dev task new --attach`, `bus dev task say
--attach`, `bus dev task show --format json`, and `bus dev task extract` are
the intended small-artifact path. Large artifacts remain a separate future
block/object-store problem.

### Trustworthy Remote Worker Lane

The final lane is a configured local, dev-hg, H100, or UpCloud-style
environment where Bus services launch Codex App Server workers for queued work,
bind each launch to the intended task ref, use explicit credential boundaries,
preserve durable Events/Notes evidence, and return enough task, artifact, model,
commit, and status evidence for local review without manual correction.

## Known Current State And Cautions

The repository was already dirty when this handoff was requested. At the start
of this handoff pass, root status showed modified `.gitmodules`, an added
`agents/supervisor` entry, changes under `docs`, and modified logs. Those
changes were not part of the remote freshness goal. A future thread should
inspect current Git state before staging or committing.

The docs tree already contained an unrelated handoff:

```text
docs/docs/goals/supervisor-identity-root.md
```

This file intentionally uses a separate name:

```text
docs/docs/goals/remote-freshness-command.md
```

Do not overwrite the supervisor identity handoff when continuing remote worker
work.

## Recommended First Steps In A New Thread

Read these files first:

```bash
sed -n '1,380p' PLAN.md
sed -n '110,230p' bus-operator-deploy/PLAN.md
sed -n '95,150p' bus-events/PLAN.md
sed -n '123,230p' bus-integration-task/PLAN.md
sed -n '1,260p' scripts/remote-checkout-update.sh
```

Then inspect current worktree state:

```bash
git status --short
git -C docs status --short
git -C bus-operator-deploy status --short
git -C bus-integration-task status --short
git -C bus-events status --short
```

Then decide whether the next action is planning cleanup or implementation.
If implementing, start in `bus-operator-deploy` and keep the first slice
focused on a dry-run/status/apply contract with fake local fixtures. Do not
begin by adding remote-specific H100 shell behavior unless it is composed under
the product command and emits the required identity manifest.

## Completion Definition

This goal is complete only when the current code proves that a worker
environment can be refreshed through a Bus-owned command that:

1. updates root and selected submodules to the requested accepted state;
2. builds/installs changed or missing tools and skips current tools;
3. rebuilds/reloads missing, stale, or incompatible worker images and skips
   current images;
4. reloads/restarts affected services only when inputs changed;
5. emits source, submodule, tool, image, service, and credential-source identity
   evidence without secrets;
6. has fixture coverage for stale/current/dirty/build/image/service/redaction
   cases;
7. has at least one local no-network apply fixture;
8. has an operator-run dev-hg or H100 smoke that records the identity manifest
   before task dispatch.

Anything less is partial progress, not completion.

# Service-Owned Events Relay Handoff

## Goal

This goal is to make Events synchronization between local and remote BusDK
development systems a normal service-owned capability.

The intended end state is that local-to-remote development work does not depend
on a supervisor manually running `bus events export`, `bus events import`,
SSH sync scripts, or `bus task --sync-now` as the daily path. A configured
environment such as local Docker, dev-hg, H100, or an UpCloud-style worker host
should run a bounded Events relay service with durable checkpoints. That relay
forwards target-marked local task and Notes operation events to the remote
Events API, imports remote-originated claim, progress, terminal, and lifecycle
evidence back, and reports status clearly enough that `bus task` and a
supervisor can trust the route.

The operator clarified that this is high priority. Treat it as a gating
dependency for a trustworthy remote worker lane, not as medium-priority
transport cleanup.

## Why This Exists

The current remote-worker path has proved several important pieces: task Events
can be synced, remote workers can run useful work, H100/local-model workers can
produce evidence, and `bus-events` already has local/testable relay machinery.
The weak point is ownership of the sync loop. If a supervisor has to remember
which import/export or SSH sync command to run, the system is still not a
normal worker lane.

The immediate product problem is that local-issued work should reach the remote
Events service before a worker starts, and remote claim/progress/terminal
evidence should come back without manual intervention. The broader product
problem is that every later remote-worker feature depends on this route being
observable, restartable, and bounded. Scheduler capacity, credential-source
selection, systemd user deployment, durable task evidence, artifact transfer,
remote freshness, and live worker review all become unreliable if Events relay
is still a manual bridge.

## Current Baseline

`bus-events` already contains completed building blocks:

- bounded bidirectional sync for task routing
- export/import event envelopes
- origin environment and origin system metadata
- per-destination sync state
- duplicate handling and idempotent imports
- cursor state via `--state-file`
- a `bus events relay` command with bounded iteration or loop/service mode
- text/JSON status with forwarded/imported/skipped/pending counters and last
  error
- regression coverage for restart cursor resume and token non-leakage

The relevant completed item is in `bus-events/PLAN.md`:

```text
Promote Events sync from a CLI/bootstrap helper into an environment-local relay
service.
```

That item is only a local/testable slice. It explicitly says that the work did
not contact live H100 or dev-hg endpoints. The next thread should not treat the
checked item as full product completion.

The root tracker now has a high-priority section:

```text
High-Priority Service-Owned Events Relay Goal
```

The owning module tracker now has an unchecked item:

```text
Deploy service-owned Events relay for live remote worker routes end to end.
```

Use current Git state as authoritative before continuing, because these plan
files were edited during an active dirty worktree.

## Current Naming And Dependencies

Review on 2026-05-30 found that this goal was partly written against the older
`bus dev task` / `bus dev work` transition state. The current implementations
make `bus-task` the generic task/thread CLI owner, and `bus-dev` now tombstones
`bus dev task` and `bus dev work` in favor of `bus task`. Future implementation
work should use `bus task` and `bus.task.*` as the primary operator and event
surface unless a current plan explicitly requires legacy compatibility.

`bus-integration-task` is the current worker integration module. Do not use the
historical `bus-integration-dev-task` name for new work.

The `bus-events` relay implementation has also moved beyond a bare local test
command. Current source includes relay config-file parsing, source/destination
credential-source labels, route ids, durable state files, route locks, bounded
once/loop modes, and text/JSON relay status. The open work is service
deployment, route configuration from environment metadata, status consumption by
the current task surface, and live dev-hg/H100 proof.

Dependency: the `bus-events` service route/config/status work can proceed
first, but this goal cannot be fully accepted until the generic `bus task` state
machine and CLI contract is accepted enough for remote start/status/stats proof,
and until the remote worker scheduler/worker service can consume the relayed
`bus.task.*` stream and publish claim/progress/terminal evidence. Those are
tracked in the neighboring `bus-task` and `service-owned-task-scheduler` goals.

## MVP Use Case

The first MVP for this goal is a live two-environment Events sync route between
the local supervisor machine and `coding-agent@dev.hg.fi`.

The operator starts process-level Bus services on both systems with
`bus services up`. The local system runs a Bus Events API and any local
controller/API services needed for proof. The dev.hg.fi system runs its own Bus
Events API under the same `bus services up` process-level service model. The
local system then establishes the relay path to dev.hg.fi over an outbound SSH
connection from local to `coding-agent@dev.hg.fi`; dev.hg.fi does not need to
open an inbound control connection to the local machine.

The MVP is accepted when `bus services up` starts the Events API stack and the
configured service-owned relay route well enough that a configured remote is
kept in sync automatically. The relay must run as a background service: either
as a dedicated Bus Events Relay service or as a background relay capability
inside the Bus Events API process. A standalone `bus events relay` command may
remain the deterministic development, test, and recovery surface, but the
normal MVP path must not be a CLI command launched as the production relay.
Both systems have their Bus services up, one system has the other endpoint
configured as a remote, and live event sync happens in the background. The
proof should use synthetic or task-shaped `bus.task.*` Events before requiring
a real remote worker to run product code. At minimum, it should demonstrate:

- `bus services up` starts the local process-level Events API stack.
- `bus services up` starts the dev.hg.fi process-level Events API stack.
- `bus services up` starts or supervises the local-owned background relay
  service or Events API embedded relay when the dev.hg.fi remote is configured.
- the local and dev.hg.fi Events API clients use explicit token-file or
  configured credential-source references rather than depending on an inherited
  `BUS_API_TOKEN`;
- an intentionally stale inherited `BUS_API_TOKEN` does not override the
  configured relay credential sources;
- the local relay route reaches the remote Events API through SSH without
  manual export/import files;
- a local target-marked Event is forwarded to dev.hg.fi;
- a dev.hg.fi-originated response or evidence Event is imported back locally;
- the relay can stop and restart without losing cursors or replaying broad old
  history;
- route status reports the local and remote environment ids, cursors,
  forwarded/imported/skipped/pending counters, state file, SSH route identity,
  and non-secret credential-source labels.

The MVP does not require the full service-owned task scheduler, App Server
worker launch, Notes projection, artifact transfer, user-systemd profile, or
remote freshness command to be complete first. Those remain follow-on proofs
that consume the live Events sync route.

### Credential Source Selection Is In Scope

The MVP includes the current remote credential-source selection goal. The
local-to-dev.hg.fi route must not rely on whichever `BUS_API_TOKEN` happens to
be present in the supervisor shell, SSH command environment, or service
process.

For this goal, credential-source selection means:

- local Events API credentials, dev.hg.fi Events API credentials, and relay
  destination credentials are resolved from explicit token-file or configured
  credential-source inputs before any inherited environment token;
- missing, unreadable, empty, unsupported, or locally detectable expired
  credential sources fail before the relay reports the route as healthy;
- diagnostics and relay status show safe source labels, route id, environment
  ids, and remediation guidance without printing token values, JWT fragments,
  or private token-file paths;
- task-shaped Events, relay state files, logs, status snapshots, and API
  payloads carry only non-secret credential-source metadata;
- remote-side token-file or deployment-secret references are not opened by the
  local controller unless the route explicitly declares them as locally
  readable source files.

Static token files and configured deployment-secret sources are acceptable for
hermetic proof, bootstrap, and recovery, and the active implementation branches
already use them to prove source precedence and token redaction. They are not
the preferred live dev.hg.fi acceptance path by themselves. The live MVP should
use a service-owned `ssh-issued-token` credential source that initializes and
refreshes a scoped Events API token through the existing SSH trust path from
local to `coding-agent@dev.hg.fi`. In other words, SSH access is the bootstrap
trust and transport path for obtaining the remote Events credential; the relay
must not require the operator to pre-copy a long-lived remote API token into
the local shell before the route can become healthy.

That SSH-backed source should reuse `bus-integration-ssh-runner` rather than
opening a private SSH implementation in the relay module. The local-owned
relay may use SSH to run a Bus-owned remote auth/operator command, or an
equivalent Bus token-exchange surface, that mints a short-lived token scoped
for the dev.hg.fi Events route. The current implementation path for that
issuer is `bus operator token --format json issue events-relay` running on the
SSH target. Provider-backed mode should call the remote auth provider internal
token endpoint using a remote-side internal key or equivalent service
credential. Explicit local/offline signing is acceptable only when that remote
host intentionally owns the deployment signing secret for bootstrap or local
development proof.

The token lifetime must be configurable, with a default requested lifetime of
24 hours unless the auth-provider deployment explicitly chooses a shorter
secure maximum. The relay should pass that requested lifetime to the SSH issuer
without storing the token; the issuer/provider may cap or reject it according
to deployment policy. The relay must refresh before expiry, using a
configurable refresh-before window, so an otherwise healthy route does not
silently stop when a short-lived token expires. It should keep only the
in-memory token value needed for API calls, and persist/report only safe
metadata such as credential-source kind, source label, issue time, expiry
time, issuer route id, requested TTL, provider-capped TTL when known,
refresh-before window, last refresh attempt, and refresh status. Token values,
JWT fragments, SSH command stderr containing secrets, and private token-file
paths must never appear in Events, state snapshots, logs, status, or other
non-secret persisted output. Private runtime route config may reference
locally readable token-file paths when token-file credentials are explicitly
selected, but those paths must be redacted from reports and relay status.

The SSH-issued source must fail closed when SSH is unavailable, token issuance
fails, the issued token is already expired or unrefreshable, clock skew makes
expiry unsafe, the source kind is unsupported, or the route would fall back to
a stale inherited `BUS_API_TOKEN`. These failures should mark the relay route
unhealthy with actionable, non-secret diagnostics rather than silently
switching credential paths. Static token-file and deployment-secret sources
may remain supported fallback or emergency sources, but using them for final
live acceptance should be an explicit operator decision.

The historical
`docs/docs/goals/remote-credential-source-selection.md` handoff remains useful
baseline evidence for explicit source precedence, fail-closed diagnostics, and
token redaction. Treat it as baseline coverage, not as acceptance proof for
this route. It does not implement SSH-issued relay credentials, issuer
configuration on dev.hg.fi, or automatic credential refresh, so this relay MVP
must add and re-prove that behavior on the current local `bus services up` plus
dev.hg.fi `bus services up` route unless the operator explicitly approves a
static credential fallback for a particular proof run.

## Required Behavior

The normal remote task path should look like this from the operator's point of
view:

```bash
bus task start --environment h100-weekend @bus-module "Do real product work"
bus task status
bus task stats --all
```

The operator should not have to run a separate import/export loop. The relay
service should already be moving eligible events between the local/controller
Events API and the selected remote Events API.

The service should handle these flows:

- local task creation events move to the remote Events API
- remote worker claim/running/progress/terminal events move back locally
- approval, guidance, and task message events move to the environment that owns
  the active worker
- worker lifecycle and scheduler evidence moves back locally
- `bus.notes.*` operation and lifecycle events move through the same Events
  origin/cursor model once Notes-over-Events is enabled
- duplicate imports remain idempotent
- imported remote-origin events are not forwarded back to their origin
- restart resumes from durable checkpoints rather than replaying old unrelated
  history

## What Needs To Be Built

### Service Configuration

Define a deployable route configuration shape. Each route needs at least:

- local Events URL
- destination Events URL
- stable source environment id
- stable destination environment id
- origin system id when useful
- token-file or credential-source references for each side
- event filters
- durable state-file path
- iteration bounds
- retry/backoff policy
- lock or single-instance behavior

The configuration should come from `bus-remote` and environment metadata where
possible. Token values must not be embedded in route config, task Events, logs,
or command output.

The MVP route configuration should include enough credential-source metadata to
prove local and dev.hg.fi Events credentials are selected intentionally: source
kind, safe source label, local-readability boundary, and any remote-side label
needed to explain where the dev.hg.fi service gets its token without exposing
the token or private path.
For the preferred live route, this metadata should also describe the
SSH-backed issued-token source without storing the token itself: SSH remote
name or route label, token audience/scope label, configured lifetime, last
successful issue/refresh time, and expiry time.

External environments should be configured with a first-class remote model
similar in spirit to Git remotes: a stable remote name such as `dev-hg`, a
transport such as SSH, a target identity such as `coding-agent@dev.hg.fi`, the
remote Events API endpoint as seen from that host, the local or service-owned
connection endpoint when one is required, environment ids, credential-source
references, relay ownership, and relay/filter policy. SSH transport behavior
should reuse `bus-integration-ssh-runner` rather than adding a separate
OpenSSH implementation inside the Events relay service. If the MVP needs a
persistent local tunnel or remote-side HTTP adapter, add or expose that
reusable primitive in `bus-integration-ssh-runner` and consume it from
`bus-integration-events`. That remote declaration should be usable by Services
to derive the relay route, and by task/status commands to explain which
environment owns work. The exact owner can be split across `bus-remote` or
environment metadata for the remote registry, `bus-services` for service graph
composition, and `bus-integration-events` for the dedicated relay service
behavior, but the operator-facing model should feel like adding or selecting a
named remote rather than hand-writing a one-off relay command.

Each bidirectional Events relationship must be represented as an atomic route
pair, not as two independent routes that happen to point at each other. A route
pair is the single sync contract for two environment ids and a route purpose,
with one durable state namespace, one active relay owner, and exactly one
active two-way sync session at a time. Reciprocal remote declarations should
resolve to the same route-pair id rather than creating separate competing
sync loops.

The route-pair declaration should include a stable route-pair identity and an
owner environment id, such as `relayOwnerEnvironmentId`, or an equivalent
primary/secondary role that resolves to one environment id. Services should
start the active relay only when the current environment id matches that owner.
The other side may expose its Events API, health, and passive route status, but
must not start a competing active relay for the same route pair.

The design should stay smart and simple. It may support multiple connection
candidates for the same route pair, such as a preferred SSH tunnel and a
fallback direct or reverse path, but those candidates are alternatives under
one pair lock/state file. Only one candidate may be active. Failover is allowed
only by stopping or marking the previous candidate inactive before promoting
the next candidate against the same route-pair state. The MVP should prefer an
explicit owner and deterministic candidate priority over distributed election
or complex cross-host locking.

For the local-to-`coding-agent@dev.hg.fi` MVP, the local/controller environment
is the relay owner and dev.hg.fi is the secondary side. If both sides configure
the reciprocal remote, their declarations must converge on the same route-pair
id, owner environment id, endpoint set, candidate priority, and filters.
Conflicting reciprocal declarations must fail clearly as split-brain
configuration rather than silently starting two relays. A deterministic
fallback such as sorting environment ids may be acceptable for generated config,
but operator-visible proof for this MVP should use an explicit owner so the
primary/secondary role is inspectable.

### Service Ownership

Run the relay through the normal service surface for each worker environment.
For the MVP, both local and dev.hg.fi Events APIs should be started by
`bus services up` as process-level services. The relay itself must also be part
of that service graph for the MVP route as a long-running background service.
The acceptable service shapes are:

- a dedicated Bus Events Relay service process with its own service kind,
  health/status, and route-pair config, likely owned by the new
  `bus-integration-events` module; or
- a Bus Events API process that owns an embedded background relay worker and
  exposes relay health/status alongside the Events API.

The current preferred implementation direction is `bus-integration-events` for
the background service host and route-pair ownership contract. `bus-events`
should continue to own reusable event envelope, sync, cursor, dedupe, and
origin-loop-prevention primitives. `bus-api-provider-events` should keep HTTP
provider/auth/transport behavior; any non-HTTP background relay logic currently
living there should be extracted to `bus-integration-events` or a shared
Events library rather than duplicated.

If both environments have their services up and one environment has the other
endpoint configured as a remote, the Events relay should start or be supervised
as part of Services without a separate operator sync command. If both
environments have reciprocal remote config, Services must use the route owner
rule above: the owner runs the single active background relay for the route
pair, and the secondary side stays passive for that pair. Later service owners
may include a user-level systemd unit, a Compose service, or a combined Bus
integration/runtime host when that service shape is ready. Manual one-shot
commands should remain available only for deterministic tests, bootstrap, and
recovery.

The service must fail clearly when route configuration is incomplete. It should
name missing endpoint, state-file, credential-source, or environment-id fields
without exposing secret values.

### Relay Health And Status

Expose script-friendly JSON and human text status with:

- current local and remote cursors
- last successful iteration time
- last attempted iteration time
- forwarded/imported/skipped/pending counters
- pending truncation evidence
- source and destination environment ids
- credential-source labels
- state-file path
- route id
- service mode or loop mode
- last error
- whether another relay instance owns the route lock

`bus-task` should use this relay status in normal remote status/start flows. A
route with missing or stale relay checkpoints should be visible before work is
dispatched or before a worker is trusted as active.

### Replay And Loop Safety

A normal relay run must not replay thousands of old unrelated task Events.
Persisted cursors and target-state filtering should bound work after the first
successful iteration. If the relay reports pending counts from a bounded sample
rather than a full replay, status must say so explicitly.

The relay must preserve origin metadata and avoid loops. Events imported from a
remote environment must not be forwarded back to that same environment as new
local work. Duplicate delivery should remain safe and idempotent.

### Service Restart Semantics

Stopping and restarting the relay should resume from its durable state file.
The restart path should prove:

- no cursor loss
- no broad full-history replay
- no duplicate task claim or stale task resurrection
- status reports the same route identity before and after restart
- failure states are recoverable without manually editing the state file

### Live Proof

A live proof is required before calling the MVP complete. The first proof should
use the local supervisor machine plus `coding-agent@dev.hg.fi`:

1. Start the local process-level Bus services stack with `bus services up`.
2. Start the dev.hg.fi process-level Bus services stack with `bus services up`
   over SSH or an equivalent operator-approved remote command path.
3. Confirm local and dev.hg.fi Events endpoints and explicit credential-source
   references.
4. Confirm the relay can obtain or refresh the dev.hg.fi Events credential
   through the configured SSH-backed credential source, or record an explicit
   operator-approved static credential fallback for that proof run.
5. Start or verify the local-owned relay route over SSH to
   `coding-agent@dev.hg.fi`.
6. Publish a local target-marked task-shaped Event.
7. Observe the relay forward the Event to the dev.hg.fi Events API.
8. Publish or observe a dev.hg.fi-originated response/evidence Event.
9. Observe the relay import that Event back locally.
10. Restart the relay process or service.
11. Repeat or continue without replaying unrelated history.

The later full remote-worker proof should add remote worker claim/progress/
terminal evidence and confirm `bus task status` and `bus task stats --all` show
the remote identity and terminal result locally.

The proof should record task ref, route id, local and remote environment ids,
state-file path, before/after cursors, forwarded/imported/skipped/pending
counters, terminal status, and any manual intervention. If manual intervention
is needed, record it as an implementation defect rather than treating the proof
as complete.

### Live MVP Proof Result

The live local-to-dev.hg.fi MVP proof succeeded on 2026-06-03 using temporary
feature-branch binaries and process-level Services stacks on both systems.
This means the basic product question is no longer whether a Services-owned
relay can move Events both directions over SSH; it can. The remaining work is
to promote the dependent branches, make the remote freshness/install path
reproduce the tool set cleanly, and re-run the proof from accepted branches
rather than from temporary proof directories.

The proof used the local supervisor host as `env-local` and
`coding-agent@dev.hg.fi` as `dev-hg`. The local route owned the relay pair
`local_dev_hg_events`, started a local Events API and `bus-events-relay`
service with `bus services up`, and reached the dev.hg.fi Events API through
an outbound SSH connection and local forward. The dev.hg.fi side also started
its Events API with `bus services up`.

Credential-source selection was exercised by running the local Services stack
with an intentionally stale inherited `BUS_API_TOKEN` while the relay used the
configured local token file and a remote `ssh-issued-token` source. The remote
issuer command shape was
`bus-operator-token --format json issue events-relay --local --hs256-secret-file ...`
for the disposable proof deployment, with a requested lifetime of 86400 seconds
and refresh-before window of 3600 seconds. Token values and the proof signing
secret were not recorded in this goal.

The proof published local Event `ev_live_local_20260603_1908` with
`bus.sync.target.ids=dev-hg`; relay status showed it forwarded once, and a
dev.hg.fi Events API query with an issuer-minted token found it in the remote
stream with origin metadata for `env-local` and sync-state metadata for
`dev-hg`. The proof then published remote Event `ev_live_remote_20260603_1908`;
the local Events API found it after relay import. Relay status reported the
route healthy with one forwarded Event, one imported Event, the expected route
and environment ids, safe SSH-issued credential metadata, and no inherited
token leakage.

The restart proof killed only the local relay process, ran `bus services up`
again against the same local stack, and observed the replacement relay process
reuse the durable state. Status stayed healthy, cursors still referenced
`ev_live_local_20260603_1908` and `ev_live_remote_20260603_1908`, and the next
pass reported no duplicate forwarding/importing of those already-synced Events.
The temporary local and remote stacks were then stopped with `bus services
down`.

The live proof found two concrete product issues that belong to this goal's
implementation set. First, the `bus-events-relay` Services profile must pass
`HOME` and `SSH_AUTH_SOCK` into the native process so OpenSSH can use the same
agent-backed SSH identity that works in the operator shell. Second, the remote
freshness/install bundle for this proof must include the `bus-api` dispatcher
binary in addition to `bus`, `bus-services`, `bus-integration-services`,
`bus-integration-events`, `bus-operator-token`, `bus-api-provider-auth`, and
`bus-api-provider-events`; otherwise the Events API profile can be installed
without the binary it starts.

The proof also exposed operational sharp edges that should be treated as
freshness/tooling follow-up, not as relay design blockers. The dev.hg.fi BusDK
superproject had unrelated dirty submodule pointer state, preserved in remote
commit `ad7da200` before proof setup. The temporary source archive created on
macOS had to exclude AppleDouble `._*` files because those files broke embedded
profile loading. The remote checkout's mainline `bus-api` was too stale to
recognize the `events` provider, so the proof built `bus-api` from the current
branch-local source and provider modules instead of relying on the old remote
binary set.

### Current Remaining Work After Live Proof

This goal is not accepted complete yet. The live relay MVP proof succeeded, but
the implementation still needs branch review, promotion, and a clean proof from
accepted branches. The dependent feature work currently spans
`bus-integration-ssh-runner`, `bus-remote`, `bus-integration-services`,
`bus-services`, `bus-integration-events`, `bus-operator-token`,
`bus-api-provider-auth`, `bus-operator-deploy`, and dispatcher/provider
freshness for `bus-api` plus Events provider modules.

The current local feature branch bill of materials after the 2026-06-03 commit
and verification pass is:

- `bus-integration-ssh-runner` branch `codex/ssh-runner-tunnel`, commit
  `4366694`, for reusable OpenSSH local-forward support and clarified runner
  docs.
- `bus-remote` branch `codex/events-relay-remote-metadata`, commit
  `a50293a`, for SSH-issued credential timing plus route-owner/route-pair
  remote metadata.
- `bus-integration-services` branch `codex/services-command-healthcheck`,
  commit `f98e339`, for service integration health/status support and clearer
  operator versus integration-test lifecycle docs.
- `bus-services` branch `codex/events-relay-service-profile`, commit
  `bc02926`, for the Events relay service profile and required `PATH`, `HOME`,
  and `SSH_AUTH_SOCK` process environment forwarding.
- `bus-integration-events` branch `codex/integration-events-relay-service`,
  commit `36397bd`, for the new relay integration service skeleton and named
  remote consumption path.
- `bus-operator-token` branch `codex/events-relay-token-issuer`, commit
  `606ef55`, for tolerant relay issuer signing flags before `issue`.
- `bus-api-provider-auth` branch `codex/internal-token-ttl`, commit
  `8a84665`, for configurable internal service-token TTLs and clarified
  internal-token docs.
- `bus-operator-deploy` branch `codex/worker-dev-tool-install`, commit
  `ca00dff`, for the `--events-relay-tool-bundle` remote freshness/install
  bundle.
- `bus-task` branch `codex/task-relay-status`, commit `c26b27f`, for local
  task relay-status consumption.

Focused verification on 2026-06-03 covered the active branch set with clean
results:

- `bus-integration-ssh-runner`: `go test ./...` with temporary Go workspace
  `/private/tmp/bus-ssh-runner-gowork-20260603/go.work` passed when rerun
  outside the sandbox because the local-forward test binds `127.0.0.1`;
  `go vet ./...`, `git diff --check`, and `bus lint README.md PLAN.md`
  passed.
- `bus-integration-services`: `go test ./...` and `go vet ./...` passed with
  `/private/tmp/bus-integration-services-gowork-20260603/go.work`;
  `git diff --check` and `bus lint README.md PLAN.md` passed.
- `bus-api-provider-auth`: `go test ./...` and `go vet ./...` passed with
  `/private/tmp/bus-auth-provider-gowork-20260603/go.work`;
  `git diff --check` and `bus lint README.md PLAN.md` passed.
- `bus-task`: `go test ./...` and `go vet ./...` passed with
  `/private/tmp/bus-task-gowork-20260603/go.work`;
  `bus lint README.md PLAN.md` was already clean for the relay-status branch.
- `bus-integration-events`: `go test ./...`, `go vet ./...`, and
  `bus lint README.md PLAN.md` passed directly in the feature worktree.
- Earlier checks in this implementation pass also showed clean test/vet/lint
  results for `bus-remote`, `bus-services`, `bus-operator-token`, and
  `bus-operator-deploy` using their recorded temporary workspaces where the
  isolated worktree layout requires them.

Before this goal can be closed, the remote freshness/install path should
install the full relay proof tool bundle, including `bus-api`, into the
dispatcher-visible `dist-bin` without hand-composing a temporary source tree.
The current implementation path is `bus operator deploy worker dev setup
--events-relay-tool-bundle --tool-bin-dir ./dist-bin --tool-smoke-command
'bus services --help'`, which expands to the full module bundle and permits
extra `--tool-module` values for branch-local proof tools. The Services profile
fix for `HOME` and `SSH_AUTH_SOCK` must be reviewed and accepted because the
live proof showed SSH auth fails without it even when operator-shell SSH works.
The `bus-remote` SSH-issued credential timing
metadata and the `bus-integration-events` named-remote consumption of that
metadata must also be accepted together so the 24-hour token lifetime and
refresh-before behavior are represented in config and relay status.

The next proof should re-run the same local-to-dev.hg.fi scenario from accepted
branches or approved submodule pins. It should still use `bus services up` on
both systems, the local-owned `local_dev_hg_events` route pair, an intentionally
stale inherited `BUS_API_TOKEN`, SSH-issued remote Events credentials, one
local-to-remote task-shaped Event, one remote-to-local evidence-shaped Event,
and a relay restart from durable cursor state.

Full remote task scheduler and worker execution remain follow-on acceptance
work. They should consume the same Events route without learning special
environment-sync behavior, but they do not have to be complete to accept this
relay MVP once the accepted-branch relay proof is clean.

## Related Goals Discussed In This Thread

### Accepted Local Workers MVP

`docs/docs/goals/workers.md` is accepted only for local native Services plus
local sandboxed Codex Spark workers. It does not complete remote worker
operation. Any unfinished work where worker create/control/message/status
Events must cross environment boundaries belongs to this relay goal and the
multi-environment coordination goal, not to the accepted local workers MVP.

### Service-Owned Task Scheduler

A remote worker environment also needs a service-owned scheduler that consumes
queued task work and starts App Server workers up to configured capacity. This
is separate from Events relay, but relay is the prerequisite that lets tasks
arrive and evidence return without manual sync.

The scheduler should avoid stale replay claims, bind launches to the intended
task ref, expose queue/worker status, and fail with task-stream evidence when a
worker cannot start.

### Remote Credential Source Selection

Controller credentials, remote Events credentials, and worker runtime
credentials must come from explicit config or token files. A stale
process-global `BUS_API_TOKEN` must not control normal remote behavior. Relay
routes should carry source labels and token-file references only, never token
values.

### Systemd User Deployment

The relay service should fit the same deployment model as the rest of the Bus
infrastructure. A local or remote worker environment should be able to start
Events, integration handlers, provider handlers, and relay as one or a few user
services. Docker or Podman should remain worker/container runtime dependency,
not the primary Bus control-plane host by default.

### Durable Task And Notes Evidence

Normal development services must use durable Events storage. Memory-backed
Events services are acceptable for tests, self-tests, or intentionally
disposable smokes only. If a memory-backed service must be restarted during a
bootstrap path, visible task Events should be exported first.

Worker Notes should use the platform architecture. Notes API mutations should
append or consume `bus.notes.*` Events, relay should move those Events with the
same origin/cursor machinery, and the Notes projection should materialize into
durable BusData/Postgres or repository-file storage. Do not add a separate
Notes replication layer.

### First-Class Task Artifact Transfer

Task attachment support already has bounded small-file attachment and
extraction primitives for patches, logs, and evidence files. Remote review
should use task attachments rather than `scp` or shared filesystem paths. The
relay path must move those task Events reliably so attached evidence is
available locally.

### Trustworthy Remote Worker Lane

The full worker lane is not trustworthy until the relay, scheduler,
credentials, service deployment, durable evidence, artifact transfer, remote
freshness, and App Server worker backend all work together. A remote task should
be issued locally, run remotely, return evidence, and be reviewed locally
without environment-specific correction.

### Remote Freshness Command

Remote worker environments need a freshness command that updates root and
submodule pins, builds or installs changed tools, rebuilds or reloads worker
images only when needed, and records source, tool, and image identity. Relay
service deployment should be part of that readiness/freshness story so a stale
remote does not appear ready.

## Acceptance Criteria

This goal is complete only when all of these are true:

- `bus-integration-events` owns the dedicated background Events relay service
  path, or the goal explicitly chooses the embedded Bus Events API worker path
  instead.
- `bus-events` exposes or shares the reusable sync/cursor/dedupe primitives
  needed by the background relay, not only local command support.
- Relay route config is explicit, non-secret, and driven by remote/environment
  metadata where possible.
- External Events environments can be configured as named remotes, similar to
  Git remotes, with enough non-secret metadata for Services, relay, and task
  status surfaces to agree on the route.
- Each bidirectional environment relationship resolves to one atomic route
  pair with a stable route-pair id, explicit owner environment id or equivalent
  primary/secondary role, one durable state namespace, and at most one active
  two-way sync session.
- Reciprocal remote config converges on the same route pair, and duplicate or
  conflicting route-pair declarations fail clearly instead of starting
  competing active relays.
- If multiple connection candidates are configured for one route pair, Services
  selects at most one active candidate at a time and failover cannot run in
  parallel with the previous candidate.
- Relay runs as a background service for the MVP local-to-
  `coding-agent@dev.hg.fi` route: either a dedicated Bus Events Relay service
  process or an embedded Bus Events API relay worker. One-shot relay commands
  remain development/test/recovery tools only.
- Relay status exposes cursors, counters, route ids, last success/error, and
  credential-source labels.
- Restart resumes from persisted cursors without broad replay.
- Duplicate imports and remote-origin loop prevention are covered by tests.
- Token values are absent from relay output, state summaries, and forwarded
  event payloads.
- The MVP re-proves remote credential-source selection for the current route:
  explicit token-file or configured credential-source inputs beat stale
  inherited environment tokens, unsupported or broken selected sources fail
  early, and only safe credential-source labels appear in diagnostics/status.
- The live dev.hg.fi MVP uses a service-owned SSH-backed credential source to
  initialize and refresh a scoped remote Events token with configurable
  lifetime, default target 24 hours, or records an explicit operator-approved
  decision to use static token-file/deployment-secret credentials for that
  proof instead.
- SSH-issued or refreshed token values remain in memory only; persisted route
  config, status, logs, Events, and state summaries contain only non-secret
  source labels, issue/refresh/expiry metadata, and remediation guidance.
- Both local and dev.hg.fi Events API stacks can be started for proof with
  `bus services up`.
- With both stacks up and the dev.hg.fi remote configured, live sync starts in
  the background through Services without manually launching a separate
  import/export command or production CLI relay loop.
- The MVP live proof moves Events both directions between the local Events API
  and the dev.hg.fi Events API over an outbound SSH connection from local to
  `coding-agent@dev.hg.fi`, without manual export/import files.
- The current `bus task` remote status/start paths can consume relay status
  instead of requiring `--sync-now` as the primary operator path.
- A later full remote-worker proof shows local task creation, service relay to
  remote, remote worker evidence, relay back to local, and local status/stats
  without manual import/export.
- Any remaining manual SSH sync, import/export, or `--sync-now` usage is
  documented as bootstrap/recovery only.

## Files To Read First

Start with these files:

1. `PLAN.md`
2. `bus-events/PLAN.md`
3. `bus-events/internal/cli/sync.go`
4. `bus-events/internal/cli/cli.go`
5. `bus-events/README.md`
6. `bus-events/internal/cli/relay_config.go`
7. `bus-task/PLAN.md`
8. `bus-task/run/sync.go`
9. `bus-integration-task/PLAN.md`
10. `bus-remote/PLAN.md`
11. `bus-operator-deploy/PLAN.md`
12. `docs/docs/goals/remote-credential-source-selection.md`
13. `bus-dev/PLAN.md`
14. `logs/20260527-17-agent-memo.md`
15. `logs/20260529-14-agent-memo.md`

Use the current worktree and current remote state as authoritative. The memo
files are supporting context, not proof by themselves.

## Suggested First Commands

Run these commands from the BusDK superproject root. Inspect the current plan
and dirty state:

```bash
git status --short
git -C bus-events status --short
git -C bus-task status --short
rg -n "High-Priority Service-Owned Events Relay Goal|Deploy service-owned Events relay|bus events relay|--sync-now|state-file|credential_source|token-file" PLAN.md bus-events/PLAN.md bus-events bus-task bus-remote
```

Inspect the current relay command and tests:

```bash
make -C bus-events build
go -C bus-events test ./...
bus-events/bin/bus-events --help
bus-events/bin/bus-events relay --help
```

If only this handoff file is changed, run:

```bash
git -C docs diff --check -- docs/goals/service-owned-events-relay.md
bus lint docs/docs/goals/service-owned-events-relay.md
```

## Known Boundaries

Do not solve this by adding a new ad hoc SSH loop in `bus-task` or by reviving
`bus dev work` in `bus-dev`. Routine sync ownership belongs to the dedicated
`bus-integration-events` background service or an embedded Bus Events API
background worker with service health/status.

Do not put token values in relay route config, state summaries, task Events,
Notes Events, logs, or command output.

Do not let an inherited `BUS_API_TOKEN` be the normal credential path for the
MVP route. It may exist during proof only as a compatibility fallback candidate
that loses to the configured token-file or credential-source inputs.

Do not treat local relay command tests as sufficient proof. The 2026-06-03
temporary-source live proof covers service deployment, status integration,
restart resume, and the local-to-`coding-agent@dev.hg.fi` SSH route. The
remaining proof requirement is to repeat that same Services-owned route from
accepted branches or approved submodule pins after the dependent changes are
reviewed and promoted.

Do not implement the production MVP by running `bus events relay` as a CLI loop
under Services. The CLI may wrap, exercise, or recover the same relay engine,
but the accepted production shape is either a dedicated background relay service
or an embedded Bus Events API background worker with service health/status.

Do not solve route-pair ownership with complex distributed election as the
first design. Prefer explicit owner metadata, deterministic candidate priority,
per-route-pair local locks/state, and fail-closed split-brain diagnostics.
Multiple configured connection candidates are acceptable only as alternatives;
they must not create parallel sync sessions for the same environment pair.

Do not build a separate Notes replication path. Notes movement should use
`bus.notes.*` Events and the same relay origin/cursor machinery.

Do not call a Docker container, a queued SSH request, or a stale process an
active worker lane unless task Events show claim/progress/terminal evidence or
a precise relay/scheduler failure.

## Current State At Handoff

The relay goal is defined and prioritized, and implementation lanes are active
in isolated worktrees.

Active implementation lanes:

- owning module: `bus-integration-ssh-runner`
- branch: `codex/ssh-runner-tunnel`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-integration-ssh-runner-tunnel`
- scope: adds a reusable runner-owned SSH local-forward primitive with public
  `LocalForward`, `TunnelRequest`, `LocalForwardSession`, and
  `Runner.StartLocalForward` APIs. The OpenSSH target path uses system
  `ssh -N -L` while preserving OpenSSH aliases, keys, agents, ProxyJump, and
  host-key policy; the explicit address/user path uses the existing Go SSH
  private-key/known_hosts transport. This is the required transport dependency
  for the Events relay SSH candidate path.
- owning module: `bus-events`
- branch: `codex/service-owned-events-relay-mvp`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/worktrees/bus-events-service-relay-mvp`
- scope: reusable SSH-backed relay route config/status support for the local-to-
  `coding-agent@dev.hg.fi` route, including explicit credential-source labels
  and stale inherited `BUS_API_TOKEN` regression coverage; this is useful relay
  engine work, but it is not sufficient for the accepted production service
  shape until the relay runs as a dedicated background service or embedded Bus
  Events API background worker
- owning module: `bus-remote`
- branch: `codex/events-relay-remote-metadata`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-remote-events-relay`
- scope: adds first-class non-secret `events_relay` metadata to named remotes,
  including `owner_environment_id` for the single active route owner and an
  optional `route_pair_id` for pinning the durable route identity. The
  metadata is validated, shown in text/JSON `bus remote` output, kept out of
  runtime-only remote fields, and can now be set directly with
  `bus remote add --events-relay-owner-environment-id ...` and
  `--events-relay-route-pair-id ...` instead of hand-editing
  `.bus/remote/config.json` for the MVP route. It preserves the existing
  no-secret remote config contract. The branch now also accepts
  `ssh-issued-token` as a
  non-secret `credential_source.kind` so named remotes can point Events relay
  at a remote token issuer command without embedding token values.
- owning module: `bus-integration-services`
- branch: `codex/services-command-healthcheck`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-integration-services-command-healthcheck`
- scope: extends native process supervision so
  `runtime.healthcheck.command` is polled until success or timeout. This lets
  Services-managed relay processes use `bus-integration-events --health` as the
  readiness signal instead of depending on TCP-only health checks. The branch
  bounds each command attempt by the remaining healthcheck timeout so a hanging
  probe cannot freeze `bus services up`. It now injects
  `BUS_SERVICES_STACK_DIR` and `BUS_SERVICES_BUS_DIR` for stack/profile
  template expansion, freezes `.bus/remote/config.json` beside the frozen stack
  config when present, and runs command healthchecks in the service
  `runtime.working_dir`. That lets a Services-managed
  `bus-integration-events --remote ...` process and its `--health` command
  resolve the same named remote from the frozen stack directory instead of
  depending on the operator shell cwd, while relay cursor/status defaults still
  resolve under the durable project `.bus` directory rather than the disposable
  config snapshot. It was verified with a temporary Go workspace because the
  isolated worktree breaks the module's normal relative
  `replace ../bus-services` path.
- owning module: `bus-integration-events`
- branch: `codex/integration-events-relay-service`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-integration-events-relay-service`
- scope: refine the new skeleton into the preferred dedicated background
  Events relay service module. Current branch work includes module identity,
  service entrypoint shape, atomic route-pair validation/selection, and a first
  bounded relay engine pass using public `bus-events` APIs. The bounded engine
  can forward target-marked local Events, import target-marked remote Events,
  stamp per-destination sync state, persist cursors after each confirmed step,
  and resume without replaying already checkpointed Events in hermetic tests.
  Foreground service mode now holds a non-blocking active relay lock beside
  each active route-pair state file for the process lifetime, and bounded
  passes take the same lock before reading cursors or contacting either Events
  API. Duplicate active relay processes for the same durable state namespace
  fail closed instead of competing.
  It now consumes the sibling `bus-integration-ssh-runner` tunnel branch for
  SSH candidates with an explicit `localForwardUrl`, using
  `sshrunner.Runner.StartLocalForward` rather than a private OpenSSH
  implementation inside the relay module. It exposes a foreground status
  surface through `--status-file`, `--status`, and `--health`. It can also
  derive one route-pair config from a named `bus remote` with a token-file or
  configured `deployment-secret` credential source. Named-remote derivation now consumes
  `events_relay.owner_environment_id` and optional `events_relay.route_pair_id`
  from `bus-remote`, still allowing CLI/env owner override for deterministic
  recovery and tests. Missing owner metadata fails closed, and the generated
  route-pair id is canonical for the two environment ids when the remote does
  not pin one, so reciprocal declarations can converge on the same pair. This
  branch now also carries explicit `eventNames` route-pair filters and
  `--event-names` / `BUS_EVENTS_RELAY_EVENT_NAMES` support for named remotes,
  so the real scoped Events API can authorize bounded streams by name instead
  of requiring a broad wildcard listener. This was an important compatibility
  gap that the earlier fake Events API e2e did not expose. This foreground
  service path now fails closed without `--status-file` or
  `BUS_EVENTS_RELAY_STATUS_FILE`, so a Services-managed relay always has a
  persisted health/status snapshot for readiness checks instead of failing
  later during startup. Plans and persisted status snapshots now include safe
  token-file and deployment-secret credential-source summaries such as
  `token-file:local-events-token-file` and
  `deployment-secret:remote-events-deployment-secret`, without printing token
  values, token-file paths, or deployment-secret values. The configured
  deployment-secret resolver reads the service environment variable named by
  the source ref only when that source is configured and still ignores stale
  inherited `BUS_API_TOKEN`; unsupported `user-config-key` and
  `os-credential-label` sources fail closed until a shared resolver exists.
  The branch now implements the first SSH-issued Events token slice for
  service-owned relay credentials: `ssh-issued-token` sources can be derived
  from named remote metadata, resolved through `bus-integration-ssh-runner`
  remote script execution against the selected SSH target, request a
  configurable token lifetime with a 24 hour default target, reject expired or
  unbounded token envelopes, and keep issued token values out of persisted
  plans/status/errors. The foreground service keeps issued tokens only in
  process memory, reuses them while their expiry remains outside the configured
  refresh-before window, and asks the SSH issuer for a replacement once the
  cached token enters that window. Successful SSH-issued credentials now add
  safe runtime evidence to persisted status snapshots: route-pair id,
  candidate id, side, environment id, source kind/label, issue time, expiry
  time, requested lifetime seconds, issued lifetime seconds, refresh-before
  seconds, and refresh status such as `fresh` or `cached`, making provider
  lifetime caps visible without storing token material. Text status exposes
  this as `credential_runtime=...`, and JSON status exposes the structured
  `credentials` array, without storing the token value, issuer command, SSH
  target, or issuer stderr. Text status now also
  exposes `route_runtime=...` for the last bounded route-pair run, including
  route-pair id, selected candidate, local/remote cursor ids, reached flags,
  and per-route forwarded/imported/skipped counters, while JSON status exposes
  the same route runtime under `lastRun`. Health/readiness now requires a
  persisted healthy status whose service kind, current environment,
  active/passive route counts, and route-pair id/role/local/remote/owner
  metadata still match the configured startup plan, plus at least one
  successful relay iteration. Services command healthchecks therefore do not
  accept the initial planned status before the relay has moved or checked
  Events, and they cannot accidentally reuse a stale healthy snapshot from a
  different route. The expected remote
  issuer command is now
  a `bus operator token --format json issue events-relay` command, owned by
  the `bus-operator-token` implementation lane below. The issuer may call the
  remote auth provider internal token endpoint, or use `--local` for explicit
  offline HS256 signing when that host owns the deployment signing secret. This
  branch participated in the 2026-06-03 live local-to-dev.hg.fi Services proof
  through the temporary composed source tree and binary set. It still needs
  review, acceptance, and the same proof rerun from accepted branches or
  approved submodule pins rather than temporary proof directories.
  This branch now has a worktree-local dependency on the
  `bus-remote`
  `codex/events-relay-remote-metadata` branch in addition to the
  `bus-integration-ssh-runner` tunnel branch. It still needs accepted/pinned
  dependent branches before promotion.
- owning module: `bus-operator-token`
- branch: `codex/events-relay-token-issuer`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-operator-token-events-relay-issuer`
- scope: adds the canonical SSH-invoked relay issuer command,
  `bus operator token --format json issue events-relay`. The preset emits the
  bounded JSON envelope consumed by `ssh-issued-token` credential sources,
  defaults the audience to `ai.hg.fi/api`, defaults the scope to
  `task:send task:read`, chooses the subject from
  `BUS_EVENTS_RELAY_TOKEN_SUBJECT`, then `BUS_EVENTS_RELAY_ROUTE_PAIR_ID`, then
  `events-relay`, and keeps secrets and token contents out of diagnostics.
  Without `--local`, it calls the auth provider internal token endpoint with
  the relay's requested lifetime in `ttl_seconds`; the provider may cap or
  reject that request according to its configured internal-token maximum. With
  `--local`, it explicitly signs an offline HS256 token and defaults the
  lifetime to 24 hours or the `BUS_EVENTS_RELAY_TOKEN_TTL_SECONDS` value
  exported by the relay. The branch now also accepts `--local` and
  `--hs256-secret-file` before `issue` for SSH issuer command strings, so a
  frozen route command does not fail health solely because local signing inputs
  were placed near `--format` rather than after `issue events-relay`. This
  branch is verified branch-locally with a
  temporary Go workspace
  because the isolated worktree cannot resolve the module's normal relative
  `../bus-help` replacement on its own. The 2026-06-03 live proof used explicit
  `--local` mode with a temporary HS256 secret file on dev.hg.fi. The accepted
  deployment path still needs either provider-backed issuer configuration with
  a remote internal key or an explicitly approved local signing secret path.
- owning module: `bus-api-provider-auth`
- branch: `codex/internal-token-ttl`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-api-provider-auth-internal-token-ttl`
- scope: extends the protected `/api/internal/auth/token` and `/internal/token`
  issuer request with optional `ttl_seconds`. The auth provider treats zero or
  omitted TTL as the existing configured internal-token lifetime, accepts a
  positive requested lifetime only when it is no longer than
  `BUS_AUTH_INTERNAL_TOKEN_TTL_SECONDS`, and rejects over-limit requests rather
  than silently issuing a longer token. This lets the provider-backed
  `bus operator token issue events-relay` path request the relay's configured
  24 hour default when the deployment explicitly raises the internal-token
  maximum to that value, while keeping the provider as the lifetime policy
  owner. It still needs branch acceptance and live dev.hg.fi proof.
- owning module: `bus-operator-deploy`
- branch: `codex/worker-dev-tool-install`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-operator-deploy-worker-dev-tools`
- scope: extends `bus operator deploy worker dev setup` with
  `--events-relay-tool-bundle`, repeatable or comma-separated `--tool-module`,
  optional `--tool-bin-dir`, and repeatable `--tool-smoke-command` support. The
  dry-run and executable plans now record selected module paths, generated
  install commands, smoke commands/status, and the chosen remote `GOBIN`
  without accepting raw secrets.
  This gives the dev.hg.fi freshness/install step a scriptable way to install
  the selected Bus module binaries into a dispatcher-visible directory such as
  `./dist-bin` before the live `bus services up` proof. Smoke commands run
  after installation with `PATH`
  prefixed by the selected tool bin directory, so the proof can validate
  dispatcher visibility with a command such as `bus services --help` before
  trying to start the full stack. The branch rejects absolute, parent-relative,
  or whitespace-containing module paths so tool installs stay relative to the
  declared remote BusDK checkout, and rejects multiline smoke commands. This
  branch now has a focused dry-run regression for
  `--events-relay-tool-bundle`, the exact dev.hg.fi relay tool bundle updated
  after the 2026-06-03 live proof showed the Events API Services profile also
  needs the dispatcher binary: `bus`, `bus-api`,
  `bus-services`, `bus-integration-services`, `bus-integration-events`,
  `bus-operator-token`,
  `bus-api-provider-auth`, and `bus-api-provider-events`, installed into
  `./dist-bin` with `bus services --help` as the dispatcher-visible smoke
  command. The branch also verifies that extra `--tool-module` values can be
  combined with the bundle and duplicate module names are installed once. The
  regression also guards against the invalid `bus services up --help` smoke
  shape. It is verified branch-locally with a
  temporary Go workspace because the isolated worktree cannot resolve the
  module's normal relative sibling replacements on its own. `bus lint PLAN.md`
  is clean; `bus lint README.md` still reports broader pre-existing README
  structure findings outside this slice.
- owning module: `bus-services`
- branch: `codex/events-relay-service-profile`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-services-events-relay`
- scope: adds the built-in `bus-events-relay` Services profile so
  `bus services up` can hand the relay to `bus-integration-services` as a
  normal native Bus process. The profile starts `bus-integration-events
  --events-relay-service` from named `bus remote` configuration with explicit
  local environment id, local Events URL, local token-file path, SSH
  local-forward URL, durable state file, and secret-free status file
  parameters. The profile intentionally passes `PATH`, `HOME`, and
  `SSH_AUTH_SOCK` from the parent process into the native relay so OpenSSH can
  find Bus binaries, user SSH config/known-hosts, and the operator-approved SSH
  agent; unit coverage now asserts those process-env references because the
  live dev.hg.fi proof showed SSH auth fails without them. The built-in
  `bus-events-api-memory` and
  `bus-events-api-postgres` profiles now also accept a `port` parameter and
  feed that port to command args and TCP healthchecks through
  `BUS_EVENTS_API_PORT`, so hermetic Services proofs can start a real local
  Events API without colliding with other loopback fixtures. Relay owner
  metadata now comes from the selected `bus remote`
  entry rather than the Services profile. This proves Services can express and
  start the relay service without owning route policy. The profile now also
  includes a command healthcheck that runs `bus-integration-events --health`
  with the same named-remote, local endpoint, state-file, and status-file
  parameters, relying on the `bus-integration-services`
  `codex/services-command-healthcheck` branch for readiness polling. The
  branch now has an opt-in hermetic e2e smoke that runs `bus-services stack up`
  against the command-health integration binary and proves command-health
  readiness gates service startup through the actual Services dispatcher path.
  It also has an opt-in relay-profile e2e that launches the actual
  `bus-events-relay` profile through `bus-services stack up`, puts a fake
  `bus-integration-events` executable on the service `PATH`, and verifies that
  the foreground relay command and `--health` command receive the expected
  named remote, event-name filter, and status-file arguments. That e2e now also creates a temporary
  `.bus/remote/config.json`, proves the relay process runs from the frozen
  `config-snapshot` working directory, and proves the frozen remote config is
  visible there. It no longer overrides the relay `state_file` or `status_file`
  params, so it also proves the profile defaults expand to durable
  `.bus/events/relay` paths through `BUS_SERVICES_BUS_DIR` instead of landing
  inside the frozen config snapshot. The branch now adds a stronger opt-in e2e
  that uses the real `bus-integration-events` binary, fake local and remote
  Events APIs, token-file local auth, an `ssh-issued-token` remote credential
  source, explicit event-name stream filters, a stale parent `BUS_API_TOKEN`,
  and a fake `ssh` executable that implements both the runner-style local TCP
  forward and the bounded SSH token issuer.
  That proof starts the relay through `bus-services stack up`, waits for one
  local target-marked Event to publish to the remote fake API and one
  remote-originated Event to publish back locally, then verifies relay status,
  credential-source labels, SSH-issued token expiry/refresh metadata,
  requested and issued token lifetime metadata, absence of token-value,
  issuer-command, and stale inherited-token leaks, and durable state evidence.
  These proofs
  now include a stronger opt-in stack that starts a real local Bus Events API
  through the `bus-events-api-memory` profile and the installed `bus`
  dispatcher, starts the real relay profile in the same stack with an
  `ssh-issued-token` remote credential source, publishes a JWT-authorized local
  `bus.task.created` Event to the real local API, forwards it through the fake
  SSH remote path, imports a remote-originated `bus.task.status.snapshot`
  Event back into the real local API, verifies secret-free SSH-issued
  credential status including requested and issued token lifetime metadata,
  restarts the same Services stack from the persisted relay state file, and
  verifies the already-forwarded local and remote Events are not republished
  before shutdown. This strongest optional local e2e was rerun on 2026-06-03
  with a freshly built `bus-integration-events` relay binary and the composed
  dispatcher/command-health binaries, and passed. It was rerun again after the
  relay healthcheck was tightened first to require `lastSuccessAt`, and then to
  prove the persisted status snapshot matches the configured relay route plan,
  and still passed. These proofs
  require a temporary Go workspace or accepted
  dependency branch so the `bus-integration-services` binary is built against
  this `bus-services` relay-profile branch; a daemon binary built against the
  main Services branch will not know the new built-in profile yet.
- owning module: `bus-task`
- branch: `codex/task-relay-status`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-task-relay-status`
- scope: starts the task-surface relay-status consumption slice without making
  `bus-task` own relay startup, transport, or worker lifecycle. The branch now
  adds `bus task start` as an operator-facing alias for creating a task thread,
  so the goal's normal remote path can use `bus task start --environment
  dev-hg ...` while the actual scheduler/worker launch remains service-owned.
  `--environment` is accepted as an alias for the existing `--environment-id`
  across task commands so current API/query payloads keep using
  `environment_id` while the operator-facing CLI matches this goal's examples.
  It also adds `bus task stats --all` as a read-only aggregation of the current
  task-list view, including deterministic status counts and per-environment
  counts when aggregating all environments.
  `bus task start`,
  `bus task status` and `bus task stats` now accept `--relay-status-file`,
  `BUS_TASK_RELAY_STATUS_FILE`, or `BUS_EVENTS_RELAY_STATUS_FILE`, plus
  `--relay-status-max-age` / `BUS_TASK_RELAY_STATUS_MAX_AGE`. When configured,
  it loads the secret-free JSON status snapshot written by the service-owned
  `bus-integration-events` relay before querying the task API. Unreadable,
  malformed, unhealthy, no-success, stale, or wrong-environment route snapshots
  fail before the task API request so a remote task start/status/stats check
  cannot silently trust stale relay evidence or create remote-targeted task
  Events that the configured relay route cannot move. The task preflight now
  requires the status snapshot to show an active route-pair role covering the
  requested remote environment; passive reciprocal route-pair status is not
  treated as coverage, because the passive side must not authorize a competing
  remote-targeted path. For `bus task stats --all`, where there is no single
  requested remote environment id, preflight still requires at least one active
  route-pair entry and rejects passive-only snapshots before the task API
  request. Healthy snapshots whose active route pair covers the requested
  remote environment allow the normal task API request.
  Unhealthy relay `lastError` diagnostics redact bearer tokens and common
  query-token fields defensively before printing, even though the relay status
  snapshot itself is expected to be secret-free.
  This is branch-local proof for the acceptance item that `bus task` status
  can consume relay status instead of treating manual `--sync-now` as the
  primary path; it still needs review, acceptance, and live dev.hg.fi
  end-to-end proof with real Services status files. The branch now also has a
  hermetic CLI e2e that builds `bus-task`, starts a loopback fake task API,
  proves `bus task start --environment dev-hg --relay-status-file ...`, proves
  `bus task stats --all` against an active relay route, and proves a
  wrong-route relay status snapshot blocks `start` before the API request.
- merge policy: keep changes on the feature branch/worktree until operator
  review accepts the work

Root `PLAN.md` now contains a high-priority service-owned Events relay section.
`bus-events/PLAN.md` now contains an unchecked implementation item for deploying
service-owned relay for live remote worker routes. The existing `bus events
relay` local/testable command is useful development/recovery surface, but it is
not the normal live dev-hg/H100 service path and should not be run as the
production relay loop under Services.

Historical pre-proof dev.hg.fi readiness probe on 2026-06-03:

- SSH to `coding-agent@dev.hg.fi` works and the remote hostname reports as
  `dev`.
- `bus` is not on PATH for a non-interactive SSH shell.
- A BusDK checkout exists at
  `/home/coding-agent/coding-agent/git/busdk/busdk`, on branch `main`.
- That checkout had local dirty submodule pointer state in
  `bus-integration-containers`, `bus-integration-docker`, and `bus-lint`. The
  operator approved preserving unrelated dirty remote state, and the proof
  preserved it in remote BusDK superproject commit `ad7da200` before installing
  temporary relay binaries.
- The available dispatcher is
  `/home/coding-agent/coding-agent/git/busdk/busdk/dist-bin/bus`, which reports
  `bus dev`.
- Running `dist-bin/bus services up --help` fails because the dispatcher cannot
  find a `bus-services` executable in PATH. The searched remote checkout only
  showed `dist-bin/bus-operator-token` among the currently built service/relay
  related binaries.
- A composed local bin-dir proof later showed that `bus services up --help` is
  not a valid Services CLI smoke even when binaries are discoverable; use
  `bus services --help` or `bus services --version` for dispatcher visibility
  before running a real `bus services up`.

Current dependency: before the accepted-branch proof is rerun, the dev.hg.fi
environment needs a freshness/install step that makes the accepted or
worktree-built `bus`, `bus-api`, `bus-services`,
`bus-integration-services`, `bus-integration-events`, `bus-operator-token`,
and required provider binaries discoverable to the remote dispatcher without
hand-composing a temporary source tree. The current implementation path for
that dependency is the `bus-operator-deploy`
`codex/worker-dev-tool-install` branch, using `worker dev setup
--events-relay-tool-bundle --tool-bin-dir ./dist-bin
--tool-smoke-command 'bus services --help'` against the remote BusDK
checkout.

Local branch-composition proof on 2026-06-03:

- Temporary workspace:
  `/private/tmp/bus-events-relay-bin-proof-20260603-16/go.work`.
- Temporary dispatcher bin dir:
  `/private/tmp/bus-events-relay-bin-proof-20260603-16/dist-bin`.
- Built into that bin dir from the current feature branches or selected main
  modules: `bus`, `bus-services`, `bus-integration-services`,
  `bus-integration-events`, `bus-operator-token`, `bus-api-provider-auth`, and
  `bus-api-provider-events`. The later live dev.hg.fi proof showed the bundle
  also needs `bus-api` because the Events API Services profile starts the
  dispatcher to host the provider.
- The workspace composes the `bus-services`
  `codex/events-relay-service-profile` branch with the
  `bus-integration-services` `codex/services-command-healthcheck` branch, the
  `bus-integration-events` `codex/integration-events-relay-service` branch,
  the `bus-integration-ssh-runner` tunnel branch, the `bus-remote` relay
  metadata branch, the `bus-events` relay branch, the `bus-operator-token`
  issuer branch, and the `bus-api-provider-auth` TTL branch.
- With that bin dir first on `PATH`, `bus services --help`,
  `bus services --version`, `bus-integration-events --help`, and
  `bus-operator-token --help` all succeed.
- The same proof showed `bus services up --help` exits with an unknown flag,
  so it must not be used as the freshness smoke command.

The next useful thread should start by checking current Git state, reading the
root, `bus-events`, and `bus-integration-events` plan items, and implementing
the next smallest local-to-`coding-agent@dev.hg.fi` MVP route slice: review and
accept or otherwise compose the `bus-integration-ssh-runner` tunnel primitive,
the `bus-remote` relay metadata branch, the `bus-integration-services`
command-health branch, the `bus-services` relay profile branch, the
`bus-integration-events` relay service branch, the `bus-operator-token`
relay issuer branch, the `bus-api-provider-auth` TTL branch, and the
`bus-operator-deploy` worker-dev tool install branch, plus the `bus-task`
`codex/task-relay-status` branch if task-surface relay status preflight should
be included in the first acceptance batch. Then perform the dev.hg.fi
freshness/install step above, configure the remote issuer path, and prove both
systems with `bus services up`, durable checkpoint/status evidence,
bidirectional synthetic or task-shaped Events, and a `bus task status` check
that consumes the relay status snapshot. The later follow-on sequence is to
layer in service-owned scheduler and full remote worker evidence.

No commit was requested for this handoff. Avoid staging or committing until the
operator asks, and keep this docs handoff separate from unrelated dirty
submodule work.

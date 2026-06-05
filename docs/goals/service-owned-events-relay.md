# Service-Owned Events Relay Handoff

## Goal

Status on 2026-06-05: the local-dev to dev-hg service-owned Events relay MVP is
accepted on `develop`. The accepted proof used normal `bus services up` stacks
on both systems, local `bus task` and `bus workers` commands, remote App Server
execution on `coding-agent@dev.hg.fi`, returned worker/task terminal evidence,
and restart/resume without duplicate terminal evidence. The current remaining
work belongs to neighboring remote-worker lane goals such as scheduler
hardening, deterministic attempt evidence, Notes/artifact transfer, and
freshness automation.

This goal made Events synchronization between local and remote BusDK
development systems a normal service-owned capability for that MVP route.

The intended end state is that local-to-remote development work does not depend
on a supervisor manually running `bus events export`, `bus events import`,
SSH sync scripts, or `bus task --sync-now` as the daily path. A configured
environment such as local Docker, dev-hg, H100, or an UpCloud-style worker host
should run a bounded Events relay service with durable checkpoints. That relay
forwards target-marked local task and Notes operation events to the remote
Events API, imports remote-originated claim, progress, terminal, and lifecycle
evidence back, and reports status clearly enough that `bus task` and a
supervisor can trust the route.

The relay must be owned below the task and worker product surfaces. `bus-task`
and `bus-worker` should continue to behave like ordinary clients of the Bus
Events API, using stable environment properties in task and worker Events to
target or describe remote work. They must not hard-code import/export loops,
SSH sync, route-pair selection, cursor handling, or other cross-environment
synchronization logic. At most, they may read non-secret route health/status
for preflight and diagnostics before issuing ordinary Bus Events API requests.

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

The MVP is accepted only when the operator can drive one real remote-worker
run from the local system while both environments are running their normal Bus
service stacks. The relay must run as a background service: either as a
dedicated Bus Events Relay service or as a background relay capability inside
the Bus Events API process. A standalone `bus events relay` command may remain
the deterministic development, test, and recovery surface, but the normal MVP
path must not be a CLI command launched as the production relay.

The required MVP user flow is:

1. Start Bus services locally with `bus services up`.
2. Create a task locally with `bus task ...`.
3. Create or select a worker for the remote `dev-hg` environment locally with
   `bus workers ...`.
4. Assign or instruct that remote worker to work on the locally-created task
   from the local system.
5. Monitor and supervise the task and worker locally while the worker runs on
   `coding-agent@dev.hg.fi`, including claim/progress/terminal task evidence,
   worker status, messages, logs or attach handoff, and final task result.

Both systems have their Bus services up, one system has the other endpoint
configured as a remote, and live event sync happens in the background.
Synthetic or task-shaped relay probes are useful lower-level evidence, but
they are no longer sufficient for MVP completion. At minimum, the MVP proof
should demonstrate:

- `bus services up` starts the local process-level Events API stack.
- `bus services up` starts the dev.hg.fi process-level Events API stack.
- `bus services up` starts or supervises the local-owned background relay
  service or Events API embedded relay when the dev.hg.fi remote is configured.
- the normal project stack does not require operators to hand-compose relay
  route files, expose token paths in `services.yml`, choose proof-only SSH
  forward ports, or copy secrets into service configuration;
- the same reusable `services.yml` can run on both local and dev.hg.fi-style
  systems. It declares local service roles and capabilities only, not remote
  environment entries, route-pair definitions, SSH targets, token paths, or
  proof-only ports;
- route identity, SSH target, remote Events endpoint, owner/secondary role,
  credential source, token issuance, refresh lifetime, and safe status labels
  come from `bus-remote` and owned Bus configuration, with `services.yml`
  naming only the service, remote id, local environment id, and non-secret
  operational parameters that cannot be derived;
- remote pairing is derived atomically from named `bus-remote` entries and
  owned Bus configuration outside `services.yml`. If both systems configure
  each other, both derive the same route-pair id and deterministic active owner
  so only one background relay establishes the two-way sync while the
  reciprocal side reports passive/covered status instead of competing;
- the local and dev.hg.fi Events API clients use explicit token-file or
  configured credential-source references rather than depending on an inherited
  `BUS_API_TOKEN`;
- an intentionally stale inherited `BUS_API_TOKEN` does not override the
  configured relay credential sources;
- the local relay route reaches the remote Events API through SSH without
  manual export/import files;
- a local target-marked Event is forwarded to dev.hg.fi;
- a dev.hg.fi-originated response or evidence Event is imported back locally;
- a task is created locally through the accepted `bus task` surface;
- a remote dev.hg.fi worker is created, selected, or confirmed locally through
  the accepted `bus workers` surface;
- assigning or messaging that worker locally causes the remote dev.hg.fi
  worker service to claim or act on the task;
- remote worker claim, running, progress, message, log/attach, and terminal
  evidence is relayed back and visible locally through `bus task` and
  `bus workers` status/monitoring commands;
- the relay can stop and restart without losing cursors or replaying broad old
  history;
- route status reports the local and remote environment ids, cursors,
  forwarded/imported/skipped/pending counters, state file, SSH route identity,
  and non-secret credential-source labels.

The MVP does require enough service-owned task scheduling and worker execution
on dev.hg.fi for that local-to-remote worker run to happen without manual
handler launches, manual event import/export, or a production CLI relay loop.
Notes projection, full artifact transfer, user-systemd profile, and the full
remote freshness command can remain follow-on proof work, but any missing
worker scheduler, worker identity/control, or worker evidence path that blocks
the five-step local operator flow is a blocker for this goal.

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
issuer is `bus operator-token --format json issue events-relay` running on the
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
`docs/goals/remote-credential-source-selection.md` handoff remains useful
baseline evidence for explicit source precedence, fail-closed diagnostics, and
token redaction. Treat it as baseline coverage, not as acceptance proof for
this route. It does not implement SSH-issued relay credentials, issuer
configuration on dev.hg.fi, or automatic credential refresh, so this relay MVP
must add and re-prove that behavior on the current local `bus services up` plus
dev.hg.fi `bus services up` route unless the operator explicitly approves a
static credential fallback for a particular proof run.

## Required Behavior

The normal remote task path should look like this from the operator's point of
view. Exact flags may evolve with the accepted task and worker CLIs, but the
operator-visible ownership must remain local:

```bash
bus services up
bus task create --title "Do real product work on dev.hg.fi" --body "Run this from the dev.hg.fi worker lane."
bus workers create --label "dev-hg spark" --type agent --environment dev-hg --profile codex-spark --runner-provider codex-direct
bus workers assign <worker-id> <task-ref> --environment dev-hg
bus workers status <worker-id> --environment dev-hg
bus task status <task-ref>
bus task stats --all
```

The operator should not have to run a separate import/export loop. The relay
service should already be moving eligible events between the local/controller
Events API and the selected remote Events API.

From the perspective of `bus task` and `bus workers`, this should feel like the
same standard Bus Events API flow used on a single system. Those commands
publish and read canonical `bus.task.*` and `bus.workers.*` Events with
environment ids, eligible environment ids, worker ids, task refs, and other
non-secret routing properties. Bus Events API infrastructure, relay services,
and remote/environment metadata decide which Events move between systems,
which side owns the active relay, how cursors are stored, and how loops are
prevented.

The service should handle these flows:

- local task creation events move to the remote Events API
- local worker create, assign, message, status, logs, and attach requests for
  `dev-hg` move to the remote worker environment when they target that
  environment
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

Relay routing must be based on Event addressing metadata, not the Event name.
The intended model is closer to mail routing than topic whitelisting:
`bus.origin.environment.id` and `bus.environment.id` describe where the Event
comes from or currently exists, while `bus.destination.environment.id` and the
existing multi-target `bus.sync.target.ids` identify which environment should
receive it. The relay may expose event-name narrowing only as an explicit
diagnostic, test, or recovery control. It must not decide that task snapshots,
worker progress, Notes operations, or other future Events are in or out of a
remote route based on their subject/name. Broadcast/subscription routing should
be added as owned Events API and `bus-integration-events` behavior when the
subscription model is defined, so ordinary task and worker clients only stamp
the correct non-secret routing properties.

## What Needs To Be Built

### Service Configuration

Define a deployable route configuration shape. Each route needs at least:

- local Events URL
- destination Events URL
- stable source environment id
- stable destination environment id
- origin system id when useful
- token-file or credential-source references for each side
- destination/subscription addressing metadata and optional diagnostic
  narrowing controls
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
resolve to the same route-pair id and the same active/passive decision rather
than creating separate competing sync loops.

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
6. Create a task locally through `bus task`.
7. Create or select a dev.hg.fi worker locally through `bus workers`.
8. Assign or instruct the dev.hg.fi worker to work on the local task from the
   local system.
9. Observe the relay forward the task and worker control Events to the dev.hg.fi
   Events API.
10. Observe the dev.hg.fi worker service claim or start work on the task.
11. Observe remote worker progress, message/log/attach handoff, and terminal
    task evidence.
12. Observe the relay import that evidence back locally.
13. Confirm local `bus task status <task-ref>`, `bus task stats --all`,
    `bus workers status <worker-id> --environment dev-hg`, and at least one
    local worker monitoring surface such as `bus workers messages`, `logs`, or
    `attach` show the remote identity and current or terminal result.
14. Restart the relay process or service.
15. Repeat or continue without replaying unrelated history, duplicating worker
    claims, or resurrecting stale task/worker state.

The proof should record task ref, worker id, route id, local and remote
environment ids, state-file path, before/after cursors,
forwarded/imported/skipped/pending counters, worker status, terminal status,
monitoring output used, and any manual intervention. If manual intervention is
needed, record it as an implementation defect rather than treating the proof as
complete.

### Live Capability Proof Result

The live local-to-dev.hg.fi capability proof succeeded on 2026-06-03 using
temporary feature-branch binaries and process-level Services stacks on both
systems. This means the basic product question is no longer whether a
Services-owned relay can move Events both directions over SSH; it can. The
dependent branch set was later promoted to module primary branches and the
same proof shape was rerun from the accepted BusDK release line described
below.

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

### Promoted Release Proof Result

The accepted-branch proof also succeeded on 2026-06-03 from promoted BusDK
`main` release `562237e17bbc08aa0ae16e1ce6675a1f152715a8`, with both
environments using the installed dispatcher-visible `dist-bin` bundles and
process-level Services stacks.

The proof used a fresh local proof root
`/private/tmp/bus-relay-main-20260603-223752` and remote proof root
`/tmp/bus-relay-main-20260603-223752`. dev.hg.fi started its memory Events API
with `bus services up --file services.yml` from the promoted checkout
`/home/coding-agent/coding-agent/git/busdk/busdk`. The local supervisor host
started a local memory Events API plus the `bus-events-relay` service with
`bus services up --file services.yml`, with `PATH` prefixed by the local
promoted `dist-bin` and an intentionally stale inherited `BUS_API_TOKEN`.

Correction after operator review on 2026-06-04: this was valid capability and
restart proof, but it was not enough to close the product MVP. It used a
temporary proof-specific `services.yml` plus explicit proof route/token/port
wiring instead of the normal root stack deriving the relay from `bus-remote`.
The product requirement is simpler for operators: once both environments have
`bus services up` and one side has the other configured as a Bus remote, the
relay should establish itself without proof-only route files, proof secrets,
manual SSH forward port choices, or token paths exposed in `services.yml`.

The promoted proof kept the same deterministic route design:

- local environment id `env-local`;
- remote environment id `dev-hg`;
- remote id `dev-hg`;
- route pair id `local_dev_hg_events`;
- relay owner environment id `env-local`;
- SSH target `coding-agent@dev.hg.fi`;
- local token-file credential source;
- remote `ssh-issued-token` credential source;
- requested token lifetime 86400 seconds;
- refresh-before window 3600 seconds;
- an explicit diagnostic Event-name narrowing used by that historical proof.

That last point was not the intended product routing contract. The relay route
must move Events because their routing metadata targets the peer environment,
not because their Event names are present in a relay allowlist.

The first verification probe used a dev.hg.fi token with the wrong account
subject and correctly could not see the relayed Event in the remote Events API.
The proof then used a route-pair-scoped proof token, matching the relay issuer
subject, for remote-side verification. That preserved the tenant isolation
behavior while proving the relay path.

The accepted-release proof moved local Event
`ev_main_local2_20260603_224136` to dev.hg.fi and moved remote Event
`ev_main_remote2_20260603_224136` back to the local Events API. Relay status
reported the route healthy, selected the SSH candidate, recorded safe
SSH-issued credential metadata, and showed `forwarded=2`, `imported=1` across
the proof run, with the last run forwarding one Event and importing one Event.
The extra forwarded count includes the earlier local Event
`ev_main_local_20260603_223938`, which the relay did forward successfully
before the verifier token-subject correction.

The accepted-release restart proof killed only the local relay process, left
both Events APIs running, ran `bus services up --file services.yml` again
against the same local stack, and observed the replacement relay process start
from durable state. The proof Event counts stayed stable:
`ev_main_local2_20260603_224136` appeared once on dev.hg.fi before and after
restart, and `ev_main_remote2_20260603_224136` appeared once locally before
and after restart. The restarted relay status stayed healthy, refreshed the
remote SSH-issued credential, and reported no duplicate forwarding/importing of
the already-synced proof Events. The temporary local and remote Services stacks
were stopped with `bus services down` after verification.

The dependent work spans `bus-integration-ssh-runner`, `bus-remote`,
`bus-integration-services`, `bus-services`, `bus-integration-events`,
`bus-operator-token`, `bus-api-provider-auth`, `bus-operator-deploy`, and
dispatcher/provider freshness for `bus-api` plus Events provider modules.

The promoted release state after the 2026-06-03 promotion is:

- BusDK `main` commit `562237e17bbc08aa0ae16e1ce6675a1f152715a8`.
- Local BusDK checkout:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk`.
- dev.hg.fi BusDK checkout:
  `/home/coding-agent/coding-agent/git/busdk/busdk`.
- Both checkouts are clean at `562237e`.
- Both checkouts have a rebuilt dispatcher-visible `dist-bin` containing
  `bus`, `bus-api`, `bus-services`, `bus-integration-services`,
  `bus-integration-events`, `bus-operator-token`, `bus-api-provider-auth`, and
  `bus-api-provider-events`.
- dev.hg.fi installed the bundle through promoted `bus-operator-deploy worker
  dev setup --events-relay-tool-bundle --tool-bin-dir ./dist-bin
  --tool-smoke-command 'bus services --help' --remote-timeout-seconds 900` from
  the primary checkout; the helper reported clean source state, rebuilt tools,
  passed smoke, and `stale=false`. After the final docs-pointer commit advanced
  BusDK to `562237e`, both primary checkouts were fast-forwarded and the same
  installed bundle remained available for the promoted-release proof.

The feature branch bill of materials that was promoted to primary branches is:

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
  commit `9023892`, for the new relay integration service skeleton, named
  remote consumption path, portable BusDK sibling replacements, and clearer
  credential setup docs. Promotion to `main` required merge commit `6bcff61`
  because the skeleton branch and relay branch both added scaffold files.
- `bus-operator-token` branch `codex/events-relay-token-issuer`, commit
  `606ef55`, for tolerant relay issuer signing flags before `issue`.
- `bus-api-provider-auth` branch `codex/internal-token-ttl`, commit
  `8a84665`, for configurable internal service-token TTLs and clarified
  internal-token docs.
- `bus-operator-deploy` branch `codex/worker-dev-tool-install`, commit
  `b34e540`, for the `--events-relay-tool-bundle` remote freshness/install
  bundle, executable setup preflight for missing remote module directories, and
  checkout-root resolution of relative `--tool-bin-dir` before exporting
  `GOBIN`.
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
- `bus-integration-events`: `go test ./...` passed with loopback escalation and
  a temporary Go workspace after the portable `go.mod` replacement fix;
  `go vet ./...`, `git diff --check`, and `bus lint README.md PLAN.md` passed.
- Earlier checks in this implementation pass also showed clean test/vet/lint
  results for `bus-remote`, `bus-services`, `bus-operator-token`, and
  `bus-operator-deploy` using their recorded temporary workspaces where the
  isolated worktree layout requires them.

A pinned dev.hg.fi freshness proof on 2026-06-03 used BusDK proof branch
`codex/service-owned-events-relay-proof`, commit `c4c85bd`, with
`bus-integration-events` pinned to `9023892` and `bus-operator-deploy` pinned to
`b34e540`. The proof checkout lives at
`/home/coding-agent/coding-agent/git/busdk/worktrees/service-owned-events-relay-proof`
and used this command shape:

```sh
bus-operator-deploy worker dev setup \
  --remote-id dev-hg \
  --remote-kind ssh-docker \
  --ssh-url coding-agent@dev.hg.fi \
  --checkout /home/coding-agent/coding-agent/git/busdk/worktrees/service-owned-events-relay-proof \
  --events-relay-tool-bundle \
  --tool-bin-dir ./dist-bin \
  --tool-smoke-command 'bus services --help' \
  --remote-timeout-seconds 900
```

The executable SSH run succeeded. It rebuilt `bus`, `bus-api`, `bus-services`,
`bus-integration-services`, `bus-integration-events`, `bus-operator-token`,
`bus-api-provider-auth`, and `bus-api-provider-events` into
`/home/coding-agent/coding-agent/git/busdk/worktrees/service-owned-events-relay-proof/dist-bin`.
The helper reported `BUS_WORKER_DEV_TOOLS_STATUS=rebuilt`,
`BUS_WORKER_DEV_TOOLS_SMOKE_STATUS=passed`, final source commit
`c4c85bd0ba54926266152a4f34f47af4c05f55b9`, clean source state, and
`stale=false`. A follow-up binary visibility check found every selected binary
in that `dist-bin`, and `PATH="$proof/dist-bin:$PATH" bus services --help`
started successfully.

This proof required two portability fixes discovered by the pinned checkout:
`bus-integration-events` needed canonical BusDK sibling `replace` paths instead
of local feature-worktree names, and `bus-operator-deploy` needed to resolve a
relative `--tool-bin-dir` from the checkout root before exporting `GOBIN` for
module-local `go install` commands.

The remote freshness/install path is now part of the promoted branch set,
including `bus-api`, and the scripted install path has reproduced the
dispatcher-visible tool bundle without hand-composing a temporary source tree.
The promoted Services profile includes `HOME` and `SSH_AUTH_SOCK` forwarding
because the live proof showed SSH auth fails without it even when
operator-shell SSH works. The promoted `bus-remote` SSH-issued credential
timing metadata and `bus-integration-events` named-remote consumption of that
metadata represent the 24-hour token lifetime and refresh-before behavior in
config and relay status.

The relay capability proof is satisfied for the local-to-dev.hg.fi
Services-owned Events route, but the relay MVP close condition is not yet
satisfied. The remaining close condition is to wire the normal project stack so
`bus services up` can start the relay from durable `bus-remote` configuration
and owned Bus credential sources, then rerun the local-to-dev.hg.fi proof from
that root stack with the real local-operator remote-worker flow. The accepted
proof must create the task locally, create/select and assign a dev.hg.fi worker
locally, run the worker on dev.hg.fi, and monitor task/worker evidence locally.
New follow-up work should still start isolated until separately accepted.

## Related Goals Discussed In This Thread

### Accepted Local Workers MVP

`docs/goals/workers.md` is accepted only for local native Services plus
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

Status on 2026-06-05: the local-dev to dev-hg relay MVP is accepted. The live
proof and `bus-integration-events` regression recorded below satisfy the
criteria in this section for the MVP route. Broader remote-worker lane work,
such as scheduler hardening, deterministic attempt evidence, Notes/artifact
transfer, and freshness automation, belongs to the neighboring goals linked
above.

This goal was complete only when all of these were true:

- `bus-integration-events` owns the dedicated background Events relay service
  path, or the goal explicitly chooses the embedded Bus Events API worker path
  instead.
- `bus-events` exposes or shares the reusable sync/cursor/dedupe primitives
  needed by the background relay, not only local command support.
- Relay route config is explicit, non-secret, and driven by `bus-remote` and
  environment metadata outside `services.yml`; the same reusable `services.yml`
  remains valid on both systems without embedding remote-specific route config.
- External Events environments can be configured as named remotes, similar to
  Git remotes, with enough non-secret metadata for Services, relay, and task
  status surfaces to agree on the route.
- Each bidirectional environment relationship resolves to one atomic route
  pair with a stable route-pair id, explicit owner environment id or equivalent
  primary/secondary role, one durable state namespace, and at most one active
  two-way sync session.
- Reciprocal remote config converges on the same route pair and deterministic
  active/passive relay decision; duplicate or conflicting route-pair
  declarations fail clearly instead of starting competing active relays.
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
  for route-health preflight and diagnostics instead of requiring `--sync-now`
  as the primary operator path; `bus task` must not implement its own
  synchronization/import/export loop.
- `bus task` and `bus workers` use normal Bus Events API requests and
  environment properties to create, assign, message, status, logs, and attach
  remote work. Cross-environment route ownership, cursoring, dedupe, and
  transport stay in Bus Events API/relay infrastructure, not in task or worker
  clients.
- The MVP live proof creates a task locally through `bus task` and the task
  becomes visible to the dev.hg.fi worker environment through the service-owned
  relay, not a manual import/export path.
- The MVP live proof creates or selects a dev.hg.fi worker locally through
  `bus workers`, and the worker identity/control Events are owned by the
  remote worker environment while being observable from the local system.
- The MVP live proof assigns or instructs that dev.hg.fi worker locally to work
  on the local task, and the remote worker service claims or starts the task
  without a manual remote handler launch.
- Local monitoring and supervision commands prove the loop is complete:
  `bus task status <task-ref>`, `bus task stats --all`, `bus workers status
  <worker-id> --environment dev-hg`, and at least one of `bus workers
  messages`, `bus workers logs`, or `bus workers attach` show remote identity,
  claim/progress/terminal evidence, and the current or final result.
- Restart/resume proof includes the real task/worker flow: after relay or
  service restart, the route does not duplicate worker claims, replay unrelated
  history, or lose the active task/worker state.
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
8. `bus-task/run/run.go`
9. `bus-integration-task/PLAN.md`
10. `bus-remote/PLAN.md`
11. `bus-operator-deploy/PLAN.md`
12. `docs/goals/remote-credential-source-selection.md`
13. `bus-dev/PLAN.md`
14. `logs/20260527-17-agent-memo.md`
15. `logs/20260529-14-agent-memo.md`

Use the current worktree and current remote state as authoritative. The memo
files are supporting context, not proof by themselves.

## Current Verification Commands

Run these commands from the BusDK superproject root when checking the automated
closeout regression or this goal file. The live proof commands and Event ids
are recorded in the 2026-06-05 03:55 EEST section below.

```bash
cd <your-busdk-superproject-root>
git status --short
git -C bus-integration-events log --oneline -1
go -C bus-integration-events test ./pkg/eventrelay
go -C bus-integration-events test ./...
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
accepted-release proof repeated that same Services-owned route from promoted
BusDK `main` release `562237e17bbc08aa0ae16e1ce6675a1f152715a8`.
After the 2026-06-04 correction, those `main` proofs are historical capability
evidence only. Current integration and acceptance work uses `develop`. The
normal `develop` stack later proved the full local operator flow with a
locally-created task, a locally-created dev.hg.fi worker, remote worker
execution, and local task/worker monitoring in the 2026-06-05 updates below.

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

## Historical State At 2026-06-04 Handoff

At this point the relay goal was active and not accepted. The operator
corrected the thread on 2026-06-04 after a documentation/refinement task was
incorrectly closed as if it represented the product goal. This document remains
the living goal record, and the 2026-06-05 updates below supersede this
handoff state.

Current `develop` audit on 2026-06-04:

- Root `services.yml` starts `postgres`, `events`, `repos`, `workers`, `tasks`,
  `api`, and `events-relay` in the default stack. The relay entry is generic:
  remote route identity and SSH target come from `bus-remote`, not
  `services.yml`.
- `bus-services` has a `bus-events-relay` profile and tests for Services-owned
  relay startup, including the `bus-integration-events --events-relay-service`
  command shape, state file, status file, healthcheck, and remote metadata
  snapshot behavior.
- `bus-integration-events` owns the background relay module and already has
  route-pair ownership, SSH candidate, credential-source, cursor, status, and
  health machinery from the previous relay capability work.
- The installed local `dist-bin` bundle is not sufficient evidence for the
  current MVP. At audit time, `dist-bin/bus workers --help` exposes the
  product worker create/assign/status/messages/logs/attach surface, but
  `dist-bin/bus task --help` exposes the older task surface and does not show
  the previously prototyped `stats --all`/relay preflight shape.
- The `bus-task` `develop` checkout is at `71864eb` and currently owns the
  ordinary Events-backed task thread surface, not worker launch or relay sync.
  Any missing task status/statistics/preflight features needed for the MVP
  remain implementation work, but `bus-task` must still not own SSH transport,
  import/export loops, cursoring, dedupe, or route-pair selection.
- The five-step MVP is still incomplete on `develop`: start local services,
  create the task locally, create/select the dev.hg.fi worker locally,
  instruct that worker locally, then monitor the remote execution locally with
  claim/progress/log/terminal evidence returning through standard Bus Events
  API flow.

Implementation update later on 2026-06-04:

- `bus-integration-events` has a local implementation slice for
  `--remote auto`: it derives route pairs from configured `bus-remote` entries
  that carry `events_relay` metadata and treats no configured relay remotes as
  a healthy no-op plan rather than a stack failure.
- The `bus-events-relay` Services profile has non-secret defaults for the local
  environment id, local Events URL, local token-file reference, SSH
  local-forward URL, and status file. It no
  longer requires a fixed shared state-file default, so auto-derived route
  pairs can keep per-pair durable cursor state.
- Root `services.yml` includes a generic `events-relay` service in
  `default_services` and in the infrastructure group. It depends on the local
  Events API and does not embed a dev.hg.fi route, SSH target, remote Events
  URL, token value, or remote token-file path.
- Focused source checks passed for this slice:
  `go test ./cmd/bus-integration-events ./pkg/eventrelay`,
  `go test ./pkg/services`, `go test ./cmd/bus-services`, source
  `bus services stack validate --file ../services.yml`, source
  `bus services stack plan --file ../services.yml --format text`, and
  `git diff --check` for the touched files.
- A temporary source-built binary proof also passed without touching committed
  `dist-bin`: `/private/tmp/bus-relay-auto-bin/bus-services stack validate
  --file services.yml` reported `OK services stack 7 services`, stack plan
  included `events-relay`, and `/private/tmp/bus-relay-auto-bin/
  bus-integration-events --remote auto ... --once --format json` returned a
  healthy zero-route plan.
- This is not MVP acceptance. The installed `dist-bin` bundle is still stale
  for this slice, the local checkout currently has no configured
  `events_relay` remote route for auto mode to activate, root `bus services
  up` has not yet been rerun with rebuilt binaries, dev.hg.fi has not yet been
  refreshed to the same `develop` state, and the five-step local task/dev.hg.fi
  worker flow remains incomplete.

Develop continuation later on 2026-06-04:

- The local `dev-hg` `bus-remote` entry now carries non-secret relay metadata:
  route pair `local_dev_hg_events`, relay owner `local-dev`, and an
  `ssh-issued-token` credential source using the actual dispatcher command
  `bus operator-token --format json --local issue events-relay` with a requested
  86400 second lifetime and 3600 second refresh-before window.
- `bus-services` now refreshes a stack-local Events JWT from the configured
  local Events signing secret during `up` and writes it to the durable
  `.bus/tokens/local-events.jwt` runtime path. The relay profile default now
  points at `{env:BUS_SERVICES_BUS_DIR}/tokens/local-events.jwt`, so the
  frozen Services working directory no longer turns the token-file reference
  into `.bus/services/config-snapshot/.bus/tokens/...`.
- `bus-integration-events` now carries the selected remote candidate's
  `remote_workdir` from `bus-remote` and prepends `<remote_workdir>/dist-bin`
  for SSH-issued token commands. This lets noninteractive SSH resolve the
  remote Bus dispatcher/tools without embedding dev.hg.fi paths in
  `services.yml`.
- `bus-integration-services` now freezes fresh stack config for a new
  `up`/`serve` attempt instead of silently reusing an old failed-run snapshot.
  This matters because `.bus/remote/config.json` is intentionally runtime
  configuration outside normal committed source and must be recopied after
  local remote metadata changes.
- Focused checks passed after these fixes:
  `go test ./...` in `bus-services`, `go test ./...` in
  `bus-integration-services`, and `go test ./...` in
  `bus-integration-events`.
- A local root-stack proof still has not accepted the goal. Rebuilt local
  binaries start `postgres`, `events`, `repos`, `tasks`, `workers`, and `api`
  successfully after cleaning stale PIDs and ports, but the overall
  `bus services up` readiness fails because the `events-relay` healthcheck is
  correctly unhealthy while dev.hg.fi cannot issue the remote Events token.
- The current live blocker is dev.hg.fi freshness and issuer setup. SSH
  inventory on 2026-06-04 found the remote primary checkout still on
  `main...origin/main`, with a stale `dist-bin` containing only older tools
  such as `bus-dev`, `bus-integration-task`, `bus-lint`, and `bus-notes`.
  A non-secret issuer diagnostic with stdout discarded showed
  `bus operator-token --format json issue events-relay` exists only after the
  tool bundle is installed and then fails without a remote provider internal
  key: `missing --internal-key-file or BUS_OPERATOR_INTERNAL_KEY`.
- Next implementation work must put dev.hg.fi on the same accepted `develop`
  release and install the same Services/relay/auth tool bundle there, then
  configure the remote issuer through owned Bus secret/config state. The relay
  must keep failing closed until that remote issuer can mint a scoped Events
  token without printing or persisting token values.

Develop continuation at 12:00 on 2026-06-04:

- dev.hg.fi now has the local BusDK `develop` superproject ref
  `db695ea` transferred over SSH and checked out in
  `/home/coding-agent/coding-agent/git/busdk/busdk`; the local-ahead
  `bus-services`, `bus-integration-services`, `bus-integration-events`, and
  `docs` `develop` refs were transferred to the matching remote submodule
  repositories before `git submodule update --init --recursive`.
- dev.hg.fi `dist-bin` was rebuilt from the `develop` checkout for the
  Services/relay/task/worker proof bundle: `bus`, `bus-api`, `bus-services`,
  `bus-integration-services`, `bus-integration-events`, `bus-operator-token`,
  `bus-api-provider-auth`, `bus-api-provider-events`, `bus-task`,
  `bus-worker`/`bus-workers`, `bus-api-provider-workers`,
  `bus-integration-task`, `bus-integration-workers`,
  `bus-integration-repos`, and `bus-remote`. The dispatcher-visible smoke
  checks `bus services --help`, `bus task --help`, and `bus workers --help`
  passed on the remote host.
- dev.hg.fi now has a private runtime `.env` with a generated local Events
  signing secret, a generated local API token, Postgres 16 native-process
  settings on port 55432, and `dev-hg` task/worker environment settings. Token
  values and signing secrets were not printed or recorded.
- The remote issuer path is now the owned Bus local-signing mode:
  `bus operator-token --format json --local issue events-relay`. The SSH issuer
  script in `bus-integration-events` now enters the remote Bus workdir,
  prepends its `dist-bin`, sources the remote private `.env` when present, and
  maps `BUS_EVENTS_JWT_SECRET` to `BUS_AUTH_HS256_SECRET` only for the remote
  issuer process when no separate local-signing secret is configured. This
  avoids embedding a secret file path in `services.yml` or the `bus-remote`
  route declaration.
- Remote validation now passes:
  `PATH="$PWD/dist-bin:$PATH" BUS_INTEGRATION_SERVICES_BIN="$PWD/dist-bin/bus-integration-services" bus services stack validate --file services.yml`
  reported `OK services stack 7 services`. A non-secret issuer smoke with
  token stdout redirected to `/dev/null` reported `issuer_ok`.
- This is still not MVP acceptance. The issuer-env change has been committed in
  `bus-integration-events` and installed into dev.hg.fi `dist-bin`; subsequent
  startup work found additional root-stack gaps before the full proof could run.

Develop continuation after the first 12:00 stack attempts on 2026-06-04:

- The BusDK `develop` line now includes local commits for the first remote
  startup blockers found by running the normal dev.hg.fi stack: `bus-services`
  passes `BUS_ENVIRONMENT_ID` into the relay process so dev.hg.fi can evaluate
  itself as the passive side of the `local_dev_hg_events` route pair, and the
  native Postgres profile uses `/tmp` as the Unix socket directory so an
  unprivileged process-level stack does not attempt to write socket locks under
  `/var/run/postgresql`.
- dev.hg.fi has been fast-forwarded as far as BusDK `f8f2894` during this
  sequence and validates `services.yml`. The later local BusDK root commit
  `b1d9495` pins the relay-service environment-id fix and the
  `bus-operator-deploy` tool-bundle correction, but it still needs to be
  transferred/installed on dev.hg.fi before another full proof attempt.
- The intended integration runtime is the shared `bus integration --provider
  ...` host. If that command does not compile or host `task`, `workers`, or
  `repos` from the checked-out module set, fix the shared integration host
  rather than changing the normal product path to standalone
  `bus-integration-*` binaries.
- The accepted remote worker proof path is Codex App Server. Direct-exec Codex
  is legacy and must not be accepted as the MVP proof path unless the operator
  explicitly changes that decision.
- The first remote Events credential is allowed to bootstrap over the existing
  SSH trust path to dev.hg.fi, because the local system cannot know remote
  secrets in advance. After bootstrap, refresh may use HTTP provider APIs when
  the scoped credential path exists.
- The five-step local task/dev.hg.fi worker flow remains incomplete: both normal
  stacks must start, local-owned relay health must pass, a local task must be
  created, a dev.hg.fi worker must be created or selected locally, that worker
  must execute on dev.hg.fi, and claim/progress/log/terminal evidence must be
  monitored locally through the normal Bus Events API surfaces.

The implementation lanes listed below were originally developed in isolated
worktrees and promoted to module primary branches as part of BusDK `main`
`562237e17bbc08aa0ae16e1ce6675a1f152715a8`. The lane entries remain here as
provenance for the historical release. They are not current acceptance status:
the active integration branch is `develop`, and the stronger MVP in this file
must be implemented and proven there.

Promoted implementation lanes:

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
  branch now also carries explicit `eventNames` route-pair narrowing and
  `--event-names` / `BUS_EVENTS_RELAY_EVENT_NAMES` support for named remotes,
  but that support is diagnostic/test-only and is not the routing contract.
  The relay route itself must remain address-metadata based so future
  task/worker/Notes Events move when they target the peer environment without
  every Event name being added to a relay allowlist. This foreground service
  path now fails closed without `--status-file` or
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
  a `bus operator-token --format json issue events-relay` command, owned by
  the `bus-operator-token` implementation lane below. The issuer may call the
  remote auth provider internal token endpoint, or use `--local` for explicit
  offline HS256 signing when that host owns the deployment signing secret. This
  branch participated in the 2026-06-03 live local-to-dev.hg.fi Services proof
  through the temporary composed source tree and binary set, and was promoted to
  module `main` as part of BusDK release `562237e`. The accepted-release proof
  later reran the same route from promoted BusDK `main`.
- owning module: `bus-operator-token`
- branch: `codex/events-relay-token-issuer`
- worktree:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk/tmp/worktrees/bus-operator-token-events-relay-issuer`
- scope: adds the canonical SSH-invoked relay issuer command,
  `bus operator-token --format json issue events-relay`. The preset emits the
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
  branch was verified branch-locally with a temporary Go workspace and promoted
  to module `main` as part of BusDK release `562237e`. The 2026-06-03 live
  proofs used explicit `--local` mode with temporary HS256 secret files on
  dev.hg.fi; provider-backed issuer configuration with a remote internal key
  remains a follow-on deployment-hardening option.
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
  `bus operator-token issue events-relay` path request the relay's configured
  24 hour default when the deployment explicitly raises the internal-token
  maximum to that value, while keeping the provider as the lifetime policy
  owner. This branch was promoted to module `main` as part of BusDK release
  `562237e`; the accepted-release proof used explicit SSH-issued local signing
  on dev.hg.fi.
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
  named remote and status-file arguments. That e2e now also creates a temporary
  `.bus/remote/config.json`, proves the relay process runs from the frozen
  `config-snapshot` working directory, and proves the frozen remote config is
  visible there. It no longer overrides the relay `state_file` or `status_file`
  params, so it also proves the profile defaults expand to durable
  `.bus/events/relay` paths through `BUS_SERVICES_BUS_DIR` instead of landing
  inside the frozen config snapshot. The branch now adds a stronger opt-in e2e
  that uses the real `bus-integration-events` binary, fake local and remote
  Events APIs, token-file local auth, an `ssh-issued-token` remote credential
  source, addressed relay metadata, a stale parent `BUS_API_TOKEN`,
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
  This is branch-local proof for the acceptance item that `bus task` can use
  relay health/status as preflight evidence instead of treating manual
  `--sync-now` as the primary path. It is not proof that `bus-task` owns
  synchronization; the task CLI still creates and observes ordinary task
  Events, while Bus Events API/relay infrastructure owns cross-environment
  movement. After the 2026-06-04 operator correction, full task
  start/status/stats proof against a real dev.hg.fi worker is part of this
  goal's MVP, not follow-on. The branch now also has a
  hermetic CLI e2e that builds `bus-task`, starts a loopback fake task API,
  proves `bus task start --environment dev-hg --relay-status-file ...`, proves
  `bus task stats --all` against an active relay route, and proves a
  wrong-route relay status snapshot blocks `start` before the API request.
- historical merge status: promoted to module `main` as part of BusDK release
  `562237e17bbc08aa0ae16e1ce6675a1f152715a8`; current local integration policy
  is `develop`, and this branch-local proof should be treated as partial
  support for the stronger MVP rather than acceptance evidence for the full
  local-to-dev.hg.fi worker flow

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

Freshness dependency status: the same scripted freshness path has now been
proven from the dev.hg.fi primary BusDK checkout at
`/home/coding-agent/coding-agent/git/busdk/busdk`, release commit
`562237e17bbc08aa0ae16e1ce6675a1f152715a8`. `bus-operator-deploy worker dev
setup --events-relay-tool-bundle --tool-bin-dir ./dist-bin
--tool-smoke-command 'bus services --help' --remote-timeout-seconds 900`
rebuilt the full dispatcher-visible bundle there. The installed bundle includes
`bus`, `bus-api`, `bus-services`, `bus-integration-services`,
`bus-integration-events`, `bus-operator-token`, `bus-api-provider-auth`, and
`bus-api-provider-events`. The helper reported clean source state, rebuilt
tools, and passed smoke; after the final docs-pointer release both checkouts
were fast-forwarded to `562237e`, and the same installed bundle remained
available. The local supervisor BusDK checkout is also clean at `562237e` and
has the same bundle installed in
`/Users/jhh/git/busdk/agent-supervisor/projects/busdk/dist-bin`.

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

Implementation update on 2026-06-04 after the addressing correction:

- The relay architecture must not be described as an Event-name relay stream.
  Event names remain useful for normal Events API subscribers and optional
  relay diagnostics, but the service-owned relay route is addressed by Event
  metadata. `bus-integration-events` now treats
  `bus.destination.environment.id` as a first-class destination address and
  continues to support the older comma-separated `bus.sync.target.ids`
  metadata used by existing task-shaped proofs.
- The default Services relay profile and Services e2e fixtures no longer bake
  task/worker Event-name allowlists into the happy path. The relay service is
  expected to see addressed Events and decide movement from destination/source
  metadata plus per-destination sync state.
- `bus-api-provider-events` has an Events relay scope for service-owned
  nameless stream access, and `bus-services` refreshes local service tokens
  that predate that scope. At this 2026-06-04 point, stale dispatcher binaries
  still prevented accepting the live route. The 2026-06-05 updates below
  supersede this note: both systems were refreshed to the same `develop`
  release, the live local task/dev.hg.fi worker flow succeeded, and automated
  worker-relay regression coverage was added.

Follow-on threads should build on the accepted relay path. Task and worker
clients should keep using ordinary Bus Events API requests with environment
metadata; scheduler, deterministic evidence, artifact, Notes, and freshness
work should use the relay as the same logical Events system rather than adding
client-owned synchronization.

## Current State Update 2026-06-04 19:00 EEST

The remaining MVP work should be driven by automated e2e or regression tests
where practical, not by manual proof notes alone. A completed local regression
slice restored the normal local worker API surface:

- `bus-api-provider-worker` request-aware bounded projection refresh now skips
  malformed historical worker evidence during read-side replay while keeping
  strict `ApplyWorkerEvent` behavior for normal projection application.
- The new regression covers the live failure shape: a historical proof Event
  named `bus.workers.status.snapshot` with route metadata but no worker id,
  followed by a valid dev-hg worker status snapshot.
- `bus-api` was rebuilt with the replaced provider source into root
  `dist-bin/bus-api`.
- After clearing stale checkout-owned `bus-api serve` processes and starting
  the normal local stack with `bus services up --file services.yml`, this
  command succeeded:

```sh
bus workers \
  --api-url http://127.0.0.1:8090/local/v1 \
  --token-file .bus/tokens/local-events.jwt \
  --format json \
  list
```

Verification from this slice:

- `go test ./...` in `bus-api-provider-worker` passed.
- `go test ./...` in `bus-api` passed.
- the local `bus workers ... list` command above returned eight worker
  records from the normal Services stack.

Same-release freshness for this slice was completed after the local
worker-replay fix:

- local BusDK and `coding-agent@dev.hg.fi` were both updated to the same BusDK
  `develop` release before continuing the remote-worker proof;
- both checkouts have matching relevant submodule pins:
  `bus-api` `02b39ae`, `bus-api-provider-worker` `7ab4cc7`,
  `bus-integration-services` `46e1289`, and docs `bc60f0d`;
- affected root `dist-bin` tools were rebuilt on both systems:
  `bus-api`, `bus-integration-services`, and `bus-api-provider-workers`;
- local `bus services up --file services.yml` restarted cleanly after stopping
  a stale checkout-owned Postgres postmaster left from an earlier state-file
  mismatch, and local
  `bus workers --api-url http://127.0.0.1:8090/local/v1 --token-file
  .bus/tokens/local-events.jwt --format json list` returned eight workers;
- dev.hg.fi `bus services up --file services.yml` restarted cleanly, and
  `bus services ps --file services.yml` reported `postgres`, `events`,
  `tasks`, `repos`, `workers`, `api`, and `events-relay` running from the same
  checkout.

The local task CLI proof is also complete for this slice:

- local `bus task --api-url http://127.0.0.1:8081/local/v1 --token-file
  .bus/tokens/local-events.jwt --format json new @dev-hg ...` created
  `task-a4373f55e80c`;
- local `bus task ... show task-a4373f55e80c` read that Events-backed task
  thread back from the normal local Events API;
- `bus-task` live Events e2e was refreshed from the old `--enable-module task`
  API flag to the current `--provider task` surface;
- that e2e now sets `BUS_TASK_EVENTS_TOKEN_FILE` while deliberately leaving a
  stale `BUS_API_TOKEN`, so it guards the credential-source precedence needed
  by this goal;
- `go test ./...`, `make test-e2e`, and `bash tests/live-events-e2e.sh` in
  `bus-task` passed.

This is not MVP acceptance. The following exact work remains:

1. Write and run a local `bus workers` e2e that creates or selects a worker for
   `dev-hg` using environment metadata and ordinary worker API Events.
2. Write and run the live two-system e2e where the dev.hg.fi worker service
   consumes relayed task/worker Events and claims or starts the task without
   task/worker clients owning synchronization logic.
3. Extend that live e2e to assert remote claim, running/progress,
   message/log-or-attach, and terminal evidence is visible locally through
   `bus task` and `bus workers`.
4. Write and run restart/resume e2e for the real task/worker route so a
   Services or relay restart does not duplicate worker claims, replay
   unrelated history into active state, or lose task/worker evidence.

## Current State Update 2026-06-04 20:00 EEST

The next concrete local-worker defect was the worker provider's validation-time
secret heuristic. `bus-api-provider-worker` had been rejecting worker create
prompts and operator messages when text looked secret-like, including false
positives such as the model string `gpt-5.3-codex-spark` because it contains
`sk-`. That was the wrong boundary for Bus workers: local and isolated worker
environments may intentionally discuss or carry secret values. Secret safety
belongs at logging, memo, diagnostics, and public-output boundaries, not as an
API rejection rule for worker communication.

The worker provider has been updated so prompts, messages, labels, metadata,
profile values, worker ids, environment ids, and worker-home refs are validated
for structure only: size limits, UTF-8, identifier syntax, namespace rules,
and runner compatibility. The old `valueLooksSecret` rejection function and
the remaining `secret-looking content` validation errors were removed from the
worker/provider/API path. `bus-api-provider-worker/AGENTS.md` now records this
boundary explicitly, and the workers goal text was updated so future work does
not reintroduce heuristic payload rejection.

The same implementation slice also fixes the relay-addressing defect found in
the local worker create flow. The workers API now accepts a local environment
id from `BUS_WORKERS_ENVIRONMENT_ID` or `BUS_ENVIRONMENT_ID` and stamps
`bus.origin.environment.id` plus `bus.origin.system.id` on worker request
Events before preserving the target worker environment as
`bus.environment.id`, `bus.destination.environment.id`, and
`bus.sync.target.ids`. This prevents the Events relay from classifying a
locally-created dev-hg worker request as remote-origin simply because the
target worker environment is `dev-hg`.

Verification completed in this slice:

- `go test ./...` in `bus-api-provider-worker` passed.
- `go test ./...` in `bus-api` passed.
- A focused source search found no remaining `valueLooksSecret` or
  `secret-looking content` rejection strings in the affected
  `bus-api-provider-worker`, `bus-worker`, `bus-integration-worker`, or
  `bus-api` paths.
- `make clean build install` completed for the BusDK superproject from the
  current `develop` checkout.
- Local `bus services down --file services.yml` followed by
  `bus services up --file services.yml` restarted the normal seven-service
  stack: `postgres`, `events`, `tasks`, `repos`, `workers`, `api`, and
  `events-relay`.
- Live local `bus workers ... create` through
  `http://127.0.0.1:8090/local/v1` accepted a prompt containing
  `gpt-5.3-codex-spark` and harmless token-like placeholder text, returning
  worker `local-secret-text-check-20260604-2006` in `creating` state.
- Live local `bus workers ... message` accepted operator text with the same
  token-like placeholder once the required `--environment local-dev` argument
  was supplied. The verification worker was then stopped.
- The worker/API/docs changes were committed and pushed on `develop`, then
  BusDK `develop` was pushed at `3fdfd8e`.
- dev.hg.fi was fast-forwarded to BusDK `3fdfd8e` with submodule pins
  `bus-api` `3689fbb`, `bus-api-provider-worker` `0162e9f`, and docs
  `95ca728`. `make clean build install` completed on dev.hg.fi, and its
  normal seven-service stack was restarted with `bus services up --file
  services.yml`.

This still does not close the remote-worker MVP. The next exact work item is a
local `bus workers` e2e that asserts origin/destination metadata on create and
message Events, followed by the live local-to-dev.hg.fi worker e2e where the
remote worker service consumes the relayed Events and sends claim/progress/log
or attach/terminal evidence back through the background relay.

## Current State Update 2026-06-04 22:30 EEST

The manual live remote-worker path has now reached the intended MVP shape on
the normal Services stack, after two worker-integration fixes were promoted to
`develop`.

First, `bus-integration-worker` commit `a8eb289` made worker control handling
tolerate out-of-order request Events. Assign and message requests can now
upsert a placeholder worker when they arrive before the create request, and the
later create request merges with that placeholder instead of erasing it. The
same slice made lifecycle failure publishing durable before acknowledging the
consumer event, so a launch failure does not poison the consumer cursor.
`go test ./...` passed in the feature worktree and again in the primary
`bus-integration-worker` checkout. BusDK pinned that change at `0ec9abc`.

Second, `bus-integration-worker` commit `ae9a5a2` fixed the return path for
worker response Events. Remote worker status/message responses now target the
request origin environment when the response is produced by another
environment, and stale destination metadata is cleared for local-only
responses. `go test ./...` passed in the feature worktree and in the primary
checkout. BusDK pinned that change at `fce0895`.

After the fixes, local and `coding-agent@dev.hg.fi` were both refreshed to
BusDK `fce0895`, `bus-integration` was rebuilt into `dist-bin` on both
systems, and both systems ran the normal root `services.yml` stack with
`postgres`, `events`, `tasks`, `repos`, `workers`, `api`, and `events-relay`.

The successful live proof used local task `task-0fae28bf931d`, local-created
dev.hg.fi worker `dev-hg-relay-mvp-20260604-2210`, and message
`msg-20260604-2221`. The local operator created the task through `bus task`,
created the worker through `bus workers` targeting `dev-hg`, and sent a worker
message locally. The remote dev.hg.fi worker service consumed the worker
control Events and produced response/status evidence from environment
`dev-hg` addressed back to `local-dev`.

Concrete returned evidence:

- remote Events row `283` was `bus.workers.message.response` for
  `msg-20260604-2221`, with origin `dev-hg` and destination `local-dev`;
- remote Events row `284` was `bus.workers.status.snapshot` with status
  `running`, origin `dev-hg`, and destination `local-dev`;
- local Events rows `370` and `371` imported those same remote message/status
  facts into the local Events API;
- local `bus workers messages dev-hg-relay-mvp-20260604-2210 --environment
  dev-hg` showed the accepted worker-to-operator response;
- local `bus workers status dev-hg-relay-mvp-20260604-2210` showed the remote
  worker running with active task `task-0fae28bf931d`, model
  `gpt-5.3-codex-spark`, App Server URL, worktree path, and logs path;
- local `bus workers logs` and `bus workers attach` returned the remote
  runtime paths and App Server connection metadata;
- after local `bus workers stop`, local Events row `381` imported the remote
  terminal `bus.workers.status.snapshot` with status and lifecycle phase
  `stopped`.

This establishes the manual MVP flow through the standard Bus Events API and
background relay rather than task/worker clients owning synchronization logic.
It also leaves three exact engineering items before the goal should be closed:

1. Add automated e2e or regression coverage for the worker-relay path so
   local-dev worker control Events, dev-hg response/status evidence, and
   terminal evidence are checked by tests rather than only by manual proof.
2. Add restart/resume coverage for the same route, including no duplicate
   worker claims and no loss of task/worker evidence after Services or relay
   restart.
3. Fix or regression-cover Services native process health so a defunct worker
   process is not reported as a healthy running service merely because
   `signal(0)` succeeds.

Two local supervisor-worker lanes were opened for those remaining items:
`task-a645d55cc1f2` / worker `local-relay-e2e-tests-20260604` for hermetic
relay-worker test coverage, and `task-9af421bc0a11` / worker
`local-services-health-20260604` for Services process health.

## Current State Update 2026-06-04 23:45 EEST

The local supervisor-worker substrate is now usable again for BusDK module
work on `develop`, and part of the remaining automated relay coverage has
landed.

Accepted and pinned fixes in this slice:

- `bus-integration-worker` `2ab1628` materializes the assigned module from a
  canonical local checkout when a generated product worktree contains only an
  uninitialized submodule placeholder. This lets local App Server workers edit
  module code without fetching private submodules from GitHub.
- `bus-integration-worker` `25ebdd5` passes the product worktree itself as a
  Codex App Server `--add-dir` root and logs bounded message diagnostics
  including worker id, operation, cwd, cwd status, and App Server URL
  presence. This makes worker-turn failures easier to diagnose without
  exposing prompt text or credentials.
- `bus-worker` `50c5660` documents `--environment` and `--environment-id` in
  the `bus workers` help and README for API-backed lifecycle and observation
  commands: `message`, `messages`, `status`, `logs`, `attach`, `pause`,
  `resume`, `stop`, and `assign`.
- `bus-integration-worker` `1841f3e` materializes replaced sibling modules
  such as `bus-events` and `bus-remote` from canonical local checkouts when
  generated product worktrees contain non-git sibling placeholders.
- `bus-integration-events` `ea2f083` adds hermetic relay regression coverage
  for sync-target metadata routing, passive owner selection, and bidirectional
  cursor resume. The tests assert that relay routing uses addressing metadata
  rather than event-name filters.

Verification completed in this slice:

- `go test ./pkg/workersintegration` and `go test ./...` passed for
  `bus-integration-worker` after the App Server root fix and again after the
  sibling materialization fix.
- `make test` passed for `bus-worker` after the CLI help/docs change.
- `make test` passed for `bus-integration-events` after the relay regression
  tests.
- Fresh local App Server worker `local-worker-help-docs-20260604d` completed
  a delegated `bus-worker` change through the normal `bus workers message`
  surface and returned response evidence locally.
- Fresh local App Server worker `local-relay-e2e-events-20260604b` completed
  a delegated `bus-integration-events` test change after assigned and sibling
  module materialization were fixed.
- The normal local dispatcher help now shows the environment flags for worker
  lifecycle/observation commands.
- BusDK `develop` pinned the first batch at `9c73e95` and the relay coverage
  plus sibling-materialization batch at `a4de0c4`.

This advanced the automated evidence, but at 2026-06-04 23:45 EEST the goal
was still open. The closeout items from that moment were later resolved or
deferred in the 2026-06-05 updates below: both systems were refreshed to the
same `develop` release, the full live local-to-dev.hg.fi remote-worker flow was
rerun and recorded, worker-relay regression coverage was added, and the
Services process-health follow-up was narrowed to broader hardening because
normal unsandboxed `bus services ps` behaved correctly during the accepted
proof.

## Current State Update 2026-06-05 03:55 EEST

The full live local-to-dev.hg.fi remote-worker flow has now succeeded from the
normal `develop` line and normal root `services.yml` stacks on both systems.
Local and `coding-agent@dev.hg.fi` were both running BusDK `develop`
`e91589af` for the proof, with the affected worker/task/relay binaries rebuilt
into dispatcher-visible `dist-bin` on both systems. A later supervision-only
BusDK guidance commit `8612977` updates this goal's operating guidance; it did
not change the proof binaries.

The proof used the normal service stack on both systems:

- local checkout:
  `/Users/jhh/git/busdk/agent-supervisor/projects/busdk`;
- remote checkout:
  `/home/coding-agent/coding-agent/git/busdk/busdk`;
- local environment id `local-dev`;
- remote environment id `dev-hg`;
- route pair `local_dev_hg_events`;
- both stacks reported `postgres`, `events`, `tasks`, `repos`, `workers`,
  `api`, and `events-relay` running from `bus services ps --file services.yml`.

The exact accepted proof artifacts are:

- task ref `task-f6f1416002a3`;
- worker id `dev-hg-relay-mvp-terminal-20260605-034730`;
- worker branch `codex/dev-hg-relay-mvp-terminal-20260605-034730`;
- worker environment `dev-hg`;
- worker model `gpt-5.3-codex-spark`;
- message id `msg-relay-terminal-20260605-034730`;
- App Server thread id `019e9541-4206-76c0-828c-53a85e13c58e`;
- App Server turn id `019e9541-42ff-7a91-9f72-904a06cd0d22`;
- terminal Event id `evt_1780620545346253915`.

The local operator created the task with the current `bus task` surface:

```sh
PATH="$PWD/dist-bin:$PATH" ./dist-bin/bus task \
  --api-url http://127.0.0.1:8081/local/v1 \
  --token-file .bus/tokens/local-events.jwt \
  --format json \
  new @dev-hg \
  "Terminal evidence relay MVP proof 20260605-034730: dev.hg.fi App Server worker should reply once and close this task through bus.task.closed returned by the Bus Events relay."
```

The local operator created the dev.hg.fi worker through the current
`bus workers` surface:

```sh
PATH="$PWD/dist-bin:$PATH" ./dist-bin/bus workers \
  --api-url http://127.0.0.1:8090/local/v1 \
  --token-file .bus/tokens/local-events.jwt \
  --format json \
  create \
  --id dev-hg-relay-mvp-terminal-20260605-034730 \
  --label "dev.hg.fi relay MVP terminal 20260605-034730" \
  --type agent \
  --profile codex-spark \
  --capability relay-mvp \
  --environment dev-hg \
  --eligible-environment dev-hg \
  --model gpt-5.3-codex-spark \
  --module busdk \
  --branch codex/dev-hg-relay-mvp-terminal-20260605-034730 \
  --runner-kind direct \
  --runner-provider codex-direct \
  --sandbox workspace-write \
  --task-ref task-f6f1416002a3
```

After the created worker reached the remote App Server lifecycle, it was
resumed and messaged locally with terminal task evidence requested:

```sh
PATH="$PWD/dist-bin:$PATH" ./dist-bin/bus workers \
  --api-url http://127.0.0.1:8090/local/v1 \
  --token-file .bus/tokens/local-events.jwt \
  --format json \
  message dev-hg-relay-mvp-terminal-20260605-034730 \
  --environment dev-hg \
  --message-id msg-relay-terminal-20260605-034730 \
  --task-ref task-f6f1416002a3 \
  --close-task-on-response \
  --text "Please reply with exactly one sentence: dev.hg.fi App Server worker completed task-f6f1416002a3 and closed it through the Bus Events relay."
```

The worker response returned locally through `bus workers messages` with
`delivery=app_server` and text:

```text
dev.hg.fi App Server worker completed task-f6f1416002a3 and closed it through the Bus Events relay.
```

Both local and remote task status then reported the task closed with the same
last Event id:

```json
{
  "task_ref": "task-f6f1416002a3",
  "status": "closed",
  "recipient": "dev-hg",
  "last_event_id": "evt_1780620545346253915"
}
```

`bus task show task-f6f1416002a3` on both local and dev.hg.fi replayed the same
three task-thread facts: local task creation, remote worker task message, and
remote worker task close. The terminal close Event was `bus.task.closed` with
origin metadata `bus.origin.environment.id=dev-hg`,
destination metadata `bus.destination.environment.id=local-dev`,
`bus.task.ref=task-f6f1416002a3`, correlation id
`msg-relay-terminal-20260605-034730`, and payload status `closed`. This keeps
task/worker clients on the normal Events API flow; relay synchronization still
belongs to the Events/relay infrastructure.

Restart/resume behavior was checked by stopping both normal service stacks
with `bus services down --file services.yml`, starting both again with
`bus services up --file services.yml --all`, then checking service health,
task status, and `bus.task.closed` replay on both sides. Both systems returned
to seven running services. The task remained closed, and the terminal close
Event replayed as the same single Event id
`evt_1780620545346253915`; no duplicate terminal task evidence was observed.

The proof worker was then stopped cleanly:

```sh
PATH="$PWD/dist-bin:$PATH" ./dist-bin/bus workers \
  --api-url http://127.0.0.1:8090/local/v1 \
  --token-file .bus/tokens/local-events.jwt \
  --format json \
  stop dev-hg-relay-mvp-terminal-20260605-034730 \
  --environment dev-hg \
  --reason "terminal relay proof complete"
```

Local and remote `bus workers status` both reported the worker `stopped` with
`last_error=""`.

The live MVP flow is now accepted as working for the local operator path:
local task creation, local dev.hg.fi worker creation/control, remote App
Server execution on dev.hg.fi, returned worker message evidence, terminal task
evidence, and restart/resume stability all work through the normal Events API
and background relay services.

Remaining closeout work is now documentation and test hardening rather than
manual proof discovery:

1. Add or accept one automated e2e/regression that exercises the worker-relay
   path through ordinary worker control Events, remote response/status
   evidence, terminal task evidence, and restart/resume idempotency. Existing
   relay regression coverage already covers metadata routing, passive owner
   selection, and bidirectional cursor resume; this remaining test should bind
   those relay guarantees to the worker/task proof shape above.
2. Update any neighboring goal/status files that still say the live
   same-release remote-worker flow has not happened.
3. Keep the Services process-health follow-up open only if current source
   still misreports dead native processes under normal, unsandboxed operation.
   During this proof, unsandboxed `bus services ps --file services.yml` gave
   correct running/stopped results before and after restart.

## Current State Update 2026-06-05 04:20 EEST

The remaining automated regression requirement for the relay MVP is now
satisfied on `develop` by `bus-integration-events` commit `6aa7b3b`
(`Add worker relay proof regression`). The regression is hermetic and lives in
`pkg/eventrelay/engine_test.go` as
`TestRunnerRunOnceRelaysWorkerTaskProofAndDoesNotDuplicateTerminalEvidence`.
It models the accepted proof shape without live SSH, Docker, or task/worker
sync code:

- local `bus.task.created`, `bus.workers.create.request`, and
  `bus.workers.message.request` Events addressed to `dev-hg` are forwarded to
  the remote side;
- remote `bus.workers.message.response`,
  `bus.workers.status.snapshot`, `bus.task.message`, and `bus.task.closed`
  Events addressed back to `local-dev` are imported locally;
- the terminal `bus.task.closed` Event preserves route/task identity through
  `bus.origin.environment.id=dev-hg`,
  `bus.destination.environment.id=local-dev`, `bus.task.ref`,
  `bus.recipient.id`, correlation id, and payload fields
  `task_ref`, `worker_id`, `message_id`, and `status=closed`;
- a second `RunOnce` against the durable cursor state does not duplicate the
  terminal task evidence.

Verification for this closeout slice:

```sh
go test ./pkg/eventrelay
go test ./...
```

Both commands passed in `bus-integration-events` after the regression was
promoted to the module `develop` checkout. The earlier live proof plus this
regression now cover the MVP's required local operator flow, metadata-addressed
relay movement, worker/task terminal evidence, and restart/resume idempotency.

The Services process-health follow-up remains a broader Services hardening
item, not an open relay MVP acceptance item. During the accepted proof,
unsandboxed `bus services ps --file services.yml` correctly reported
running/stopped state before and after restart on both local and dev.hg.fi.

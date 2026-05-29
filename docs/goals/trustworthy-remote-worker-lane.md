# Trustworthy Remote Worker Lane Handoff

## Goal

This conversation is about making remote worker systems ordinary Bus capacity,
not machines that a supervisor has to shepherd by hand.

A trustworthy remote worker lane is a configured local, dev-hg, H100, or
UpCloud-style environment where normal Bus services launch Codex App Server
workers for queued task Events, bind each launch to the intended task, use
explicit credential-source boundaries, preserve durable Events and Notes
evidence, and return enough task, artifact, model, commit, and status evidence
for local review without environment-specific correction.

The target user workflow is that a supervisor can submit real product work to a
remote environment, watch it progress through service-owned status, and review
the result locally without manually starting handlers, exporting a global token,
running ad hoc sync loops, repairing Git metadata, copying files with `scp`, or
guessing which model/runtime actually handled the task.

## Current Tracker Location

The root tracker records this under `PLAN.md`, especially `Current Refined
Finish Line`, `High-Priority Service-Owned Events Relay Goal`, `Deterministic
Task Evidence Goal`, and `Durable Task And Notes Evidence Goal`.

Module ownership has shifted while this goal was being refined. Earlier
discussion and some historical notes used `bus-integration-dev-task` and
`bus.dev.task.*`. The current tracker increasingly uses `bus-integration-task`,
`bus.task.*`, and future `bus task` / `bus worker` ownership. A future thread
should inspect current `PLAN.md` files before implementing and should use the
current names in code and docs.

The most relevant current files are:

- `PLAN.md`
- `bus-integration-task/PLAN.md`
- `bus-dev/PLAN.md`
- `bus-events/PLAN.md`
- `bus-operator-deploy/PLAN.md`
- `bus-remote/PLAN.md`
- `bus-notes/PLAN.md`
- `bus-integration-notes/PLAN.md`
- `bus-api-provider-notes/PLAN.md`

## Finish Line

The minimum credible finish line is a repeatable remote work loop:

1. A local supervisor submits a real implementation task to a configured remote.
2. Task Events move to the remote through service-owned relay/sync.
3. Remote services see queued work and start Codex App Server workers up to configured capacity.
4. A worker claims only the intended task ref and refuses stale, canceled, terminal, or unrelated replayed tasks before any model turn starts.
5. The worker edits only its isolated task worktree, runs required checks, and publishes structured closeout evidence.
6. The worker commits or reports a structured no-change result.
7. Terminal Events, model/reasoning metadata, worker logs, Notes, attachments, branch/commit identity, and status evidence return locally.
8. The local supervisor extracts any artifacts through the task stream, verifies the diff, promotes/pins accepted work, and records proof.
9. The same loop works again after a fresh or non-persistent remote start.

This is not complete until it works on real product work, not just read-only
smokes or test-file edits.

## What We Decided

Manual SSH, `scp`, process-global `BUS_API_TOKEN`, one-shot `codex exec`
fallback, stale replay cleanup, Git metadata repair, remote-specific start
recipes, and manually launched per-handler processes are break-glass paths. If
any of them are needed during proof, record the exact reason as a defect or
follow-up.

Codex App Server is the normal worker backend. One-shot `codex exec` remains
legacy compatibility only. Remote/local-model lanes should start and steer App
Server workers through the same service pattern.

Task state belongs in Events. Schedulers and worker services may build
projections, but Events remain the source of truth for queue state, attempts,
claims, terminal status, sync routing, and replay.

Bus Notes worker evidence must use the platform architecture. Notes API
mutations should append or consume `bus.notes.*` Events; Events relay/sync
moves those operation Events between local and remote systems; Notes projection
materializes queryable state into durable storage. There should not be a
separate Notes replication layer.

Small patches, logs, and evidence files should move through task attachment
support. Out-of-band file copy is only a fallback when the current artifact
size or storage model cannot handle the payload.

## Workstreams

### Service-Owned Task Scheduler

The scheduler should be a long-lived service that consumes queued task work,
starts App Server workers up to configured capacity, avoids replaying stale
claims as live capacity, and exposes queue/worker/capacity state.

Current owner: `bus-integration-task`.

Required behavior:

- Replay task lifecycle events into a projection with queued, launch-pending, claimed, running, stale, drain-pending, done, failed, blocked, and canceled states.
- Treat created/reopened tasks as queue inputs only when recipient, remote, and write-scope policy match the scheduler config.
- Start workers through the worker-start contract with exact work ref, recipient, write scopes, backend, remote metadata, credential-source labels, and expected-ref environment.
- Enforce global, per-remote, and per-recipient capacity.
- Make stale claims and orphaned launch requests stop consuming capacity.
- Support pause/drain.
- Publish scheduler health/status with queue depth, active workers, launch-pending count, stale-claim count, drain state, last errors, remote id/kind, and safe credential-source labels.

Open proof needed:

- Unit/replay tests for capacity, stale claims, exact-ref launch binding, canceled/terminal exclusion, orphaned launches, and service restart.
- A fixture or e2e smoke where multiple queued tasks produce only capacity-bounded exact-ref App Server starts and scheduler status shows the right state.

### Exact-Ref Worker Safety

Workers must not claim an arbitrary neighboring task when launched for a
specific ref.

Current owner: `bus-integration-task`.

Required behavior:

- Worker launch accepts an expected task/work ref.
- Before App Server startup, the worker replays current task status for that exact ref.
- If the next claimable task is stale, canceled, terminal, unrelated, or from another same-recipient shard, the worker refuses before the model turn.
- The refusal is published as bounded task/launcher evidence.

This requirement came from a real failure mode where a repair launch intended
for one reopened task claimed an old stale task first.

### App Server-Only Remote Worker Lane

Remote/local-model worker launches should use Codex App Server end to end.

Current owner: `bus-integration-task`.

Required behavior:

- H100, dev-hg, localhost, and future UpCloud launches use the `codex-appserver` backend.
- Local-model startup passes provider flags and model endpoint information that are reachable from the worker runtime namespace.
- Live guidance through task messages reaches the App Server controller and publishes an acknowledgement before supervisors rely on mid-task steering.
- Reopened or retried tasks preserve and validate requested versus observed model/profile/provider identity.
- Normal local-model profiles reject accidental `codex exec` selection.

The important model bug to prevent is silently resuming a stored App Server
thread from an old model or profile after a supervisor requested another model.

### Model And Profile Retry Semantics

Supervisors need a structured way to retry or steer a task with a different
model, reasoning effort, or profile.

Current owners: `bus-dev` for task metadata surfaces, `bus-integration-task`
for App Server runtime behavior.

Required behavior:

- Task creation, reopen, and guidance support structured model/reasoning/profile metadata.
- App Server workers compare stored thread identity with requested runtime identity before resuming.
- If the profile/provider cannot be switched safely in the existing process, start a fresh thread or block with a clear diagnostic.
- If model changes are supported, call the appropriate App Server model-switch operation before the next turn and record requested/observed model metadata.

### Remote Credential Source Selection

The normal path is explicit remote config or token files, not a supervisor shell
token.

Current owners: `bus-remote`, `bus-dev`, `bus-events`, `bus-integration-task`.

Required behavior:

- Controller credentials prefer explicit `--token-file`, selected local/controller credential source, local/user/compose token files, then inherited `BUS_API_TOKEN` only as fallback.
- Remote Events relay/sync keeps local and destination credentials separate.
- Worker runtime credentials prefer configured token files/source refs before inherited env.
- SSH-Docker remote token-file refs are remote-side references and must not be opened locally by the controller.
- Missing, unreadable, expired, or unsupported selected credentials fail before model startup with actionable diagnostics that name the source kind/path safely and never print token values.

### Systemd User Deployment

A fresh local or remote worker host should start required Bus infrastructure
through one named `systemd --user` profile, not by manually launching each
handler.

Current owner: `bus-operator-deploy`.

Default service shape:

- `bus-events`
- one combined `bus-integration` runtime for selected integration and provider-adjacent handlers
- optionally one `bus-api` runtime for selected API providers
- rootless Docker/Podman as worker/container runtime dependency, not as the default Bus control-plane host

Required behavior:

- `bus operator deploy service user-systemd plan|install|update|status` can render, install, update, restart, and report a named combined-runtime profile.
- Unit files reference config files, token files, credential-source labels, and environment-file paths only.
- Unit files and command output do not embed raw tokens or provider secrets.
- Status reports installed/enabled/active/failed units, linger versus login-session scope, user-manager health, rootless Docker dependency, Events/API/integration readiness, and non-secret config/token source labels.
- Live proof shows dev-hg or H100 install/update/start/status after a fresh wake and a worker task starting without manual handler launches.

### Service-Owned Events Relay

Normal task routing should not require a supervisor to run manual export/import,
SSH sync scripts, or `--sync-now` as the daily path.

Current owner: `bus-events`, with consumers in `bus-dev` and deploy/service
tooling.

Required behavior:

- Each configured worker environment can run `bus events relay` as a bounded service or scheduled loop.
- Relay config includes local/destination Events URLs, stable environment IDs, token-file or credential-source refs, event filters, durable state-file paths, iteration bounds, and backoff/lock behavior.
- Relay status exposes cursors, last successful iteration, forwarded/imported/skipped/pending counters, pending truncation, route IDs, credential-source labels, and last error without token values.
- Restart resumes from persisted cursors and does not replay old unrelated history.
- Remote-origin events are not forwarded back to their origin.
- Relay covers task Events and, once enabled, `bus.notes.*` operation/lifecycle Events.

Live proof needed:

- Local task creation relays to remote.
- Remote worker claim/progress/terminal evidence relays back.
- Local status/stats show the result without a manual sync loop.

### Durable Task And Notes Evidence

Normal worker evidence must survive service restarts and remote sync.

Current owners: `bus-events`, `bus-api`, `bus-operator-deploy`,
`bus-api-provider-notes`, `bus-integration-notes`, and `bus-notes`.

Required behavior:

- Normal development Events services use PostgreSQL or explicit repository-file-backed storage.
- Events `memory` storage is only for tests, self-tests, and explicitly disposable smokes.
- Memory-backed service restart/update paths export visible task and Notes operation Events first or refuse without an explicit discard decision.
- Notes API mutations route through `bus.notes.*` operation Events with idempotency and source/origin metadata.
- Notes projection consumes those Events and materializes durable query state.
- `bus notes` and the Notes API can query worker evidence by module, task, session, tag, source kind/ref, and origin environment/system after remote sync.

### Deterministic Attempt Evidence

Every worker attempt should produce a machine-readable evidence bundle.

Current owners: `bus-integration-task` and `bus-dev`.

Required fields:

- terminal status and classification
- remote id/kind
- requested and observed model/profile/reasoning
- attempt id and sequence
- prior/superseded attempt id when applicable
- worker id
- durable worker log pointer or task attachment id
- branch and worktree identity
- commit hash or structured no-change reason
- validation command records with pass/fail/skip and accepted skip reason
- structured closeout state
- Bus Notes ids or query metadata
- start/end timestamps
- token usage when concretely reported
- redacted failure or block reason

Review surfaces should expose evidence completeness. Terminal work with missing
modern fields should appear as incomplete or legacy-partial, not as a quiet
success.

### First-Class Task Artifact Transfer

Small file attachment support exists, but the remote promotion workflow still
needs adoption and proof.

Current owner: `bus-dev` for the existing primitive and near-term workflow.

Current baseline:

- Task creation and task guidance can embed small attachments.
- Attachment envelopes include content, checksum, media type, and producer metadata.
- `task show -f json` replays attachment envelopes.
- `task extract` materializes selected attachments with checksum, path traversal, and symlink safety checks.
- Current limits are 1 MiB per attachment and 4 MiB per event.

Remaining work:

- Document and test the operator recipe for patch/log/evidence transfer.
- Update worker prompt/closeout guidance so workers attach patches, logs, and evidence through the task stream.
- Run one live remote proof where a remote worker attaches patch/log/evidence and the local supervisor extracts and reviews or applies without `scp`.
- Keep large binary/image/archive delivery as a separate object/block-store follow-up.

## Current Known Status

Already completed or largely proven:

- Remote/environment identity and non-secret remote metadata in `bus-remote`.
- Per-remote credential source metadata and controller/worker credential precedence slices.
- Bounded Events sync/relay primitives and cursor/state-file support.
- First local/testable `bus events relay` command behavior.
- Task attachment envelope and extraction primitive.
- First user-systemd install/update/status slice for allowlisted services.
- Combined `bus-integration` host concept.
- Notes contracts, FileStore, BusData adapter, and API-backed CLI foundation.
- H100 local-model write smokes that proved H100 can run model-backed workers and produce commits under controlled scripts.

Still open:

- Service-owned scheduler as the normal remote App Server launch path.
- Exact-ref guard before App Server startup.
- App Server-only lane across local/dev-hg/H100/UpCloud.
- Model/profile switch semantics on retry and guidance.
- Service-owned Events relay deployment and live remote proof.
- Durable Events backend and memory restart/export guard.
- Notes-over-Events production projection and origin-aware queries.
- User-systemd combined runtime profile.
- Remote source/tool/image freshness command.
- Live real-product remote implementation proof, followed by a repeat proof after readiness/freshness automation.

## Suggested Next Thread Start

Start by inspecting current state rather than relying on this handoff alone:

```sh
git status --short
sed -n '1,360p' PLAN.md
sed -n '1,280p' bus-integration-task/PLAN.md
sed -n '1,360p' bus-events/PLAN.md
sed -n '1,220p' bus-operator-deploy/PLAN.md
sed -n '1,220p' bus-dev/PLAN.md
```

Then pick one implementation slice. The highest-leverage order is:

1. Restore/prove the local Events API and durable Events/storage gate.
2. Finish service-owned Events relay deployment/status.
3. Implement the service-owned task scheduler and exact-ref worker guard.
4. Wire status/monitor to scheduler-owned state.
5. Prove App Server-only worker execution and model/profile retry behavior.
6. Add user-systemd combined runtime profile and remote refresh command.
7. Prove a real remote product task, review/promote locally, then repeat after freshness/readiness automation.

If the next thread only has time for one scoped worker task, start with either
the `bus-events` durable/local Events gate or the `bus-integration-task`
exact-ref worker guard. Those remove the most dangerous false-positive success
modes.

## Definition Of Done

The goal is complete only when current evidence proves all of the following:

- A configured remote can be refreshed to accepted root/submodule/tool state with recorded identity evidence.
- Required Bus services can be started or verified through the normal service profile.
- Events relay moves task and Notes evidence out and back with durable cursors and no replay storm.
- A queued real implementation task launches an App Server worker through the service scheduler.
- The worker claims only the intended task.
- The worker produces structured deterministic attempt evidence.
- Patches/logs/evidence transfer through task attachments or another first-class Bus artifact path.
- Notes evidence is queryable locally after remote sync by module, task, session, tag, source, and origin.
- Local status/stats show remote id/kind, model/reasoning, terminal status, accepted/failed/blocked counts, stale/false-active state, and scheduler source.
- The supervisor can review, verify, promote, and pin the result locally.
- The same loop succeeds again after a fresh or non-persistent remote start.
- Any manual intervention is either absent or recorded as an explicit remaining defect with an owning module plan item.

Do not mark this goal complete from unit tests alone, from a smoke-only task, or
from a single manually shepherded success.

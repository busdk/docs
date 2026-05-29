# Remote Worker Lane Handoff

## Goal

This thread refined the remote worker/offload goal for BusDK. The target is a
trustworthy service-owned lane where a local supervisor can queue real
development work for local, dev-hg, H100, or another configured remote
environment, and the environment can run the work without manual SSH repair,
manual token swapping, ad hoc import/export loops, scp side channels, or
post-hoc Git reconstruction.

The intended happy path is:

```bash
bus dev work --remote dev-hg start @some-module "Do real product work"
bus dev work --environment h100-weekend start @some-module "Do real product work"
```

That should create a local task, relay it to the remote Events service, let a
service-owned scheduler start an App Server worker, have that worker claim only
the intended task, produce a branch/commit or no-change closeout, attach logs
and evidence, sync terminal Events and Notes back, and leave the local
supervisor able to review, promote, pin, and report the work from the primary
checkout.

## Why This Exists

The conversation started from retrospective follow-ups and repeatedly narrowed
vague remote-worker concerns into concrete product work. The most important
correction is that the Events relay is not medium-priority polish. A
service-owned relay is a high-priority gate for the remote lane because normal
work should not depend on a human running manual import/export loops.

This handoff preserves the working definition of the goal so another thread can
resume without relying on chat memory.

## Current Evidence Pointers

Use these as orientation, not as proof that the goal is finished.

- `PLAN.md` describes the active H100 goal as the smallest real repeatable
  offload loop.
- `bus-events/PLAN.md` has a completed local/testable `bus events relay` slice
  with loop/service mode, durable state file support, counters, and token file
  references. Live dev-hg/H100 proof still remains.
- `bus-dev/PLAN.md` includes the local-supervisor to remote Events sync slice,
  remote status visibility, first-class task attachment work, and the refined
  worker stats/recovery-analysis item.
- `bus-integration-dev-task/PLAN.md` still owns the App Server end-to-end
  remote/local model lane and the intended-ref guard for workers.
- `bus-operator-deploy/PLAN.md` includes user-systemd deployment work, the
  still-open single-runtime service profile, and the remote freshness command.
- `bus-integration-notes/PLAN.md` and `bus-api-provider-notes/PLAN.md` capture
  the remaining Notes-over-Events projection and mutation path.

Before acting, inspect the current files because line numbers and completion
status may have moved since this handoff was written.

## Workstreams

### Service-Owned Events Relay

This is high priority. Normal task flow should use a bounded relay service
rather than a manual import/export loop.

Needed work:

- Deploy `bus events relay` as a systemd, Compose, or combined integration
  service for local-to-remote and remote-to-local routes.
- Configure routes declaratively with local Events URL, destination URL,
  environment/source IDs, token-file or credential-source references, durable
  state file paths, and filters.
- Expose health and status: last success, cursors, forwarded/imported/skipped
  counts, pending counts, target IDs, last error, credential labels, and
  truncated-pending indicators.
- Make `bus-dev` rely on relay health for normal work. `--sync-now` should be
  bootstrap or recovery, not the default operating loop.
- Prevent replay storms and loops with durable checkpoints, idempotency,
  locking, bounded iterations, and backoff.
- Prove live flow on dev-hg or H100: local task, relay forward, remote worker
  execution, relay import of terminal evidence, relay restart, and repeat.

### Service-Owned Task Scheduler

A service, not the supervisor shell, should consume queued bus dev task work,
start App Server workers up to configured capacity, avoid replaying stale
claims, and expose current queue/worker status.

Needed work:

- Define the scheduler service owner and runtime entrypoint.
- Read queue state from durable Events and claim work atomically.
- Start App Server workers with configured model, reasoning, write scopes, and
  environment profile.
- Track capacity, launch-pending workers, active workers, terminal attempts,
  stale claims, drain mode, and false-active lanes.
- Refuse stale or unintended work refs rather than replaying old queued tasks.
- Expose status through `bus dev work status` or a related command so the
  supervisor can see why work is queued, running, blocked, or idle.

### Remote Credential Source Selection

Credentials must come from explicit remote config or token files as the normal
path, not from a process-global token. Expired or missing credentials should
fail early with actionable diagnostics.

Needed work:

- Separate the three credential planes: controller credentials, remote
  Events/relay credentials, and worker runtime credentials.
- Use deterministic precedence: explicit token file, selected remote or
  environment credential source, local compose/config/user token file, and only
  then `BUS_API_TOKEN` as a legacy fallback.
- Treat ssh-docker token-file references as remote-side paths. Do not try to
  open those files locally.
- Diagnostics should name the remote, credential source, and missing/expired
  condition, never the secret value.
- Add tests for stale process-global tokens, valid explicit token files,
  expired token files, separate source/destination relay tokens, and absence of
  secret leakage in Events, logs, task payloads, or docs.

### Systemd User Deployment For Bus Infrastructure

A local or remote worker environment should start the required Bus API, Events,
integration, provider, relay, and scheduler services with one or a few user
services rather than manually launching each handler.

Needed work:

- Keep the existing allowlisted user-systemd unit deployment path for separate
  services.
- Add the preferred single-runtime or few-service profile driven from config.
- Check lingering, user manager availability, rootless Docker requirements,
  unit installation, enable/start behavior, and readiness.
- Provide a concise status command that explains missing services and next
  repair actions.
- Use systemd deployment as the normal way to run relay and scheduler services
  in remote lanes.

### Durable Task And Notes Evidence

Visible task Events and Notes must survive service restarts and remote sync.
Memory-backed Events are acceptable only for tests or intentionally disposable
smokes.

Needed work:

- Ensure normal development services use durable Events storage, such as
  PostgreSQL or an explicit repository-file-backed store.
- Add a pre-restart export guard for memory-backed Events that exports visible
  `bus.dev.task.*` and `bus.notes.*` Events with a manifest, checksum, and
  import command, or requires an explicit discard flag.
- Route Notes mutations through `bus.notes.*` Events.
- Let `bus-integration-notes` materialize the Notes projection from Events.
- Make worker Notes queryable after remote sync by module, task, session, tag,
  source, and origin.

### First-Class Task File And Artifact Transfer

The basic small-attachment path exists, but the remote workflow still needs to
adopt it as the normal evidence transfer channel.

Needed work:

- Use `bus dev task` attachments for patches, log bundles, and evidence files
  instead of scp.
- Ensure worker prompts and closeout guidance prefer first-class attachments.
- Include attachments in local review and promotion flows.
- Prove a remote worker can attach evidence and the local supervisor can
  retrieve it without environment-specific side channels.
- Keep the large-artifact story separate if it requires storage or streaming
  work beyond the current small-file support.

### Trustworthy Remote Worker Lane

The lane is trustworthy only when a fresh or restarted environment can run real
work repeatedly through the same product path.

Needed work:

- Remote freshness and source identity are automatic and inspectable.
- Service-owned relay and scheduler are running.
- App Server is the normal backend everywhere. One-shot Codex execution is
  legacy compatibility, not the normal local/dev-hg/H100 path.
- Workers claim only intended refs and report stale-ref refusal clearly.
- Model/profile retry behavior is deterministic and visible.
- Terminal evidence, Notes, logs, branches, commits, and validation results
  sync back for local review.

### Remote Freshness Command

Remote environments need one idempotent command that updates source, tools,
worker images, and services only when needed, then records identity.

Likely shape:

```bash
bus operator deploy worker dev refresh --remote dev-hg --dry-run
bus operator deploy worker dev refresh --remote dev-hg --apply
bus operator deploy worker dev refresh --remote dev-hg --status
```

Needed work:

- Read desired state from config: remote id, root path, ref or branch,
  submodule pins, required tools, worker image, and services.
- Reuse `scripts/remote-checkout-update.sh` where appropriate.
- Build or install changed tools only when source identity changed.
- Rebuild or reload worker images only when image inputs changed.
- Restart or reload services only when their unit/config/image/tool identity
  changed.
- Emit an identity manifest with root SHA, submodule SHAs, tool versions and
  paths, image tag/id/digest/platform, reloaded or skipped services, remote
  id/kind, and redacted credential source labels.

### Deterministic Task Evidence

Every worker attempt should emit a mandatory evidence envelope from claim
through terminal closeout or launch failure.

Required fields:

- terminal status
- remote id and remote kind
- requested and observed model
- requested and observed reasoning/profile
- attempt id and attempt sequence
- worker id
- worker log pointer
- branch and worktree
- commit hash or explicit no-change state
- validation commands and outcomes
- closeout state

Missing required fields should be visible in `task show`, `monitor`, and work
status. For backward compatibility, older attempts can be bucketed as
`unknown`, but promotion and recovery analysis should prefer complete attempts.

### Worker Stats For Recovery Analysis

Stats must explain recovery quality, not just count activity.

Needed work:

- Report model attempted, remote id, attempt count, failures, blocked attempts,
  supervisor interventions, GPT-backed repair work, accepted/promoted work,
  and blocked reasons.
- Add groups such as `by_intervention`, `by_repair_source`, and
  `by_blocked_reason`.
- Preserve legacy compatibility with explicit `unknown` buckets.
- Distinguish created, claimed, running, terminal, branch promoted,
  supervisor accepted, root pinned, pushed, and released.
- Use these numbers in progress reports so weak throughput or false-active
  lanes are obvious.

## Priority Order

P0/gating:

- Service-owned Events relay live proof.
- Worker intended-ref guard.
- Durable Events storage or memory pre-restart export guard.

P1:

- Service-owned scheduler launch/status.
- Credential-source contract and tests.
- App Server-only remote/local model path.
- Deterministic task evidence envelope.

P2:

- Remote freshness command.
- Systemd single-runtime profile.
- Notes over Events projection and query path.
- Worker stats taxonomy and reporting.
- Artifact-transfer adoption in the remote promotion workflow.

## Acceptance Checklist

The goal is not complete until a fresh or refreshed dev-hg/H100-style
environment can prove this loop more than once:

- The remote root and submodule pins are current and recorded.
- Durable Events storage is in use, or a restart export guard protects visible
  task and Notes Events.
- Relay services are running in both directions with durable checkpoints.
- A local supervisor creates a real product task and the relay forwards it
  without manual import/export.
- The scheduler starts an App Server worker within configured capacity.
- The worker claims the intended task ref and refuses stale work.
- The worker produces a commit or explicit no-change closeout.
- Logs, patches, validation output, Notes, terminal status, model/reasoning,
  attempt id, branch, and commit evidence sync back.
- Local status and stats show remote id, attempts, failures, blocked reasons,
  interventions, accepted work, and recovery attribution.
- The supervisor reviews, promotes, pins, and can repeat after a service
  restart or remote freshness run.

## Risks And Cautions

- Inspect the dirty worktree before editing or committing. Several modules may
  already have unrelated local or worker-produced changes.
- H100 may be cost-paused. Use dev-hg, local fixtures, and unit/e2e tests to
  advance service code while H100 proof is unavailable.
- Never write secrets into docs, logs, Events, task payloads, Notes, or memos.
- Do not count queued, claimed, launched, or container-running work as accepted
  progress. Accepted progress requires supervisor review and promotion/pinning
  where applicable.
- Do not paper over service gaps with manual SSH, scp, or Git repair unless
  the repair is explicitly recorded as a temporary recovery step and converted
  into an owned PLAN item.

## First Commands For A New Thread

```bash
git status --short
git -C bus-dev status --short
git -C bus-events status --short
git -C bus-integration-dev-task status --short
git -C bus-operator-deploy status --short
git -C logs status --short
sed -n '33,104p' PLAN.md
sed -n '89,140p' bus-events/PLAN.md
sed -n '101,220p' bus-integration-dev-task/PLAN.md
sed -n '95,132p' bus-operator-deploy/PLAN.md
sed -n '300,380p' bus-dev/PLAN.md
```

## Done Means

This goal is done only when normal remote development work can run repeatedly
through services: no manual import/export loop, no manual worker runner, no
process-global token dependency as the normal path, no scp evidence transfer,
no manual Git reconstruction, and readable local evidence and stats for every
attempt.

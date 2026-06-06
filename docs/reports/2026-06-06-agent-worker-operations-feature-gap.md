---
title: "Agent worker operations feature gap review"
description: "Review of existing BusDK worker modules and the exact software features needed for a commercially credible AgentOps package."
---

## Scope

This report reviews the existing BusDK task, worker, repository, Events, API,
and service-profile modules from the perspective of a commercial Agent Worker
Operations package. The intended first product is not a fully autonomous remote
worker fleet. The credible first product is a supervised Codex worker lane:
BusDK starts and controls a sandboxed Codex App Server worker, gives it a
task, records the conversation and runtime metadata, preserves the repository
worktree evidence, and produces a buyer-readable evidence bundle.

The commercial problem is trust. A buyer will not pay for vague claims that
agents can do work. They need to see what was requested, where the worker ran,
which model/runtime was selected, what the worker replied, what changed in the
repository, what checks ran, and what the operator still had to review.

## Existing foundation

The current BusDK tree already contains the core worker substrate for a local
Codex worker product path.

`bus-task` provides bidirectional task threads over `bus.task.*` Events. It is
the right place for task conversation and task status, but it deliberately does
not own worker launch, worker execution, worktrees, model choice, or scheduler
policy.

`bus-work` provides generic durable work streams and claim semantics. It is a
general work-queue primitive, not a Codex-specific worker product.

`bus-worker`, through the plural `bus-workers` product command, is the current
operator-facing worker API client. It can create, list, show, pause, resume,
assign, message, read messages, stop, show logs, and attach to workers through
the workers API provider.

`bus-api-provider-worker` is the controller and projection surface for
`bus.workers.*` Events. It publishes canonical create/control/message Events
and projects bounded worker status, messages, logs, and attach metadata. The
provider is already mounted by `bus-api` under the workers provider path.

`bus-integration-worker` is the environment-side lifecycle service. Its
`direct-exec` path starts real local Codex App Server workers with isolated
`CODEX_HOME`, product worktrees, worker identity worktrees, logs, scratch
paths, sandbox settings, model/profile selection, and bounded message evidence.
Its `repos-events` materializer path uses repository Events instead of
privately creating all worktrees.

`bus-repos`, `bus-api-provider-repos`, and `bus-integration-repos` provide the
repository contract and local Git worktree materialization. The current
accepted worker path can ask the repos integration to materialize a product
worktree and a worker identity worktree, then report branch and worktree
status as evidence.

`bus-events` and `bus-api-provider-events` provide the event transport and
durable evidence substrate. The worker goal documentation records PostgreSQL
durability proof for the local worker acceptance path, and Events replay can
hydrate worker projections after restart with bounded recipient and
environment filters.

`services.yml` and the service profiles already describe a local stack with
PostgreSQL-backed Events, repos integration, workers integration, tasks, and
the API gateway. This is close to the stack shape needed for a commercial
AgentOps pilot.

The strongest existing proof is in the worker product e2e scripts. The
repos-backed worker e2e proves create, status, worktree materialization,
branch creation, logs, attach, message, response projection, API projection
replay after restart, and stop. The gated real-Codex e2e proves the same
product path with a real Codex command and a real Events provider when
`BUS_WORKERS_REAL_CODEX_PRODUCT_E2E=1` is supplied.

## Commercial position

The sellable first package should be stated narrowly:

BusDK AgentOps can run and supervise local sandboxed Codex workers for a
specified repository task, preserve non-secret runtime and conversation
evidence, and produce a reviewable evidence bundle for the operator or buyer.

The first package should not claim autonomous fleet scheduling, remote worker
relay, VM/container isolation, unattended code promotion, or guaranteed
business outcomes. Those are extension tracks.

## Required P0 features

These are the exact features needed for a credible weekend commercial offer.
Without them, the system may work technically but still looks like an internal
engineering harness.

| Feature | Owning modules | Required behavior | Definition of done |
| --- | --- | --- | --- |
| AgentOps evidence bundle | `bus-worker`, `bus-api-provider-worker`, `bus-events`, `bus-integration-worker` | Add a user-facing command such as `bus workers evidence <worker-id>` or `bus workers evidence --task-ref <ref>`. It collects worker create intent, current status, message transcript, logs/attach metadata, Events replay references, worktree paths, branch refs, model/runtime/sandbox metadata, and optional command/check output into one directory. | A local worker run produces `manifest.json`, `transcript.md`, `status.json`, bounded Events NDJSON, `runtime.md`, `repository.md`, and `limitations.md`. Token-like values are redacted. An e2e verifies the pack contains the worker id, task ref, model, sandbox, worktree branch refs, response evidence, and no token material. |
| AgentOps preflight and doctor | `bus-worker`, `bus-api`, `bus-api-provider-events`, `bus-integration-worker`, service profiles | Add `bus workers doctor` or equivalent. It checks API reachability, workers provider mount, Events provider storage kind, repos materializer reachability, worker integration reachability, Codex command availability, Codex auth/config source label, requested model, sandbox mode, writable roots, and evidence-pack output directory. | A clean local stack reports pass/fail rows with actionable diagnostics. Memory-backed Events are reported as disposable unless the operator explicitly opts into a disposable proof. Secret values are never printed. |
| Packaged local demo workflow | `services.yml`, `profiles`, `bus-worker`, `docs` | Convert the existing test-oriented path into an operator-facing demo. It should start or target the local AgentOps stack, create a synthetic product repo and worker identity repo when needed, create a worker, send one task message, wait for a response, stop the worker, and produce an evidence bundle. | A documented command sequence from a fresh checkout completes with a generated evidence directory. A fake-Codex mode is deterministic and does not require paid model access; an optional real-Codex mode is gated and clearly marked. |
| Explicit runtime and model evidence | `bus-agent`, `bus-integration-worker`, `bus-api-provider-worker`, `bus-worker` | Surface the requested model, profile, runner kind/provider, Codex command path/version when available, App Server backend, sandbox mode, product worktree, worker identity worktree, logs ref, and allowed writable roots. The evidence should distinguish requested settings from observed runtime facts. | `bus workers status`, `logs`, `attach`, `messages`, and the evidence bundle expose the same bounded non-secret runtime fields. The real-Codex e2e or a new proof checks exact model pass-through and sandbox/root metadata. |
| Durable proof mode | `bus-events`, `bus-api-provider-events`, `bus-api`, service profiles | Make the commercial AgentOps profile use durable Events by default and record the storage kind in status and evidence packs. Memory mode remains allowed only for disposable demos and tests. | The demo or doctor command proves Events replay after API restart, or records that the current run is disposable. The evidence bundle states `events_storage=postgres|file|memory` and includes a replay check result. |
| Buyer-facing assurance page | `docs`, `busdk.com` | Publish a concise assurance page that explains what the package proves, what data is collected, what is redacted, what remains manual, and which claims are not included in the first package. | The page links to a generated synthetic evidence bundle and to the command sequence used to produce it. It does not claim autonomous remote fleets or unattended production code acceptance. |

## Required P1 features

These features are needed to move from a first paid pilot to a repeatable
commercial workflow.

| Feature | Owning modules | Required behavior | Definition of done |
| --- | --- | --- | --- |
| Task-to-worker run command | `bus-worker`, `bus-task`, `bus-api-provider-worker` | Add a higher-level command that creates or selects a task ref, creates or assigns a worker, sends initial guidance, watches until first response or terminal timeout, and records the evidence pack location. The worker module may orchestrate API calls, but task modules still own task Events. | One command can run a small supervised task from request to evidence bundle. It prints worker id, task ref, evidence path, and next review action. |
| Active worker status and stale detection | `bus-worker`, `bus-api-provider-worker`, `bus-integration-worker` | Expose active task, last status event time, last operator message time, last worker response time, lifecycle phase, runtime error, stale/blocked reason, and capacity-relevant state. | `bus workers list --format json` is sufficient for a small status dashboard and for supervisor scripts to detect stale workers. |
| Review and handoff summary | `bus-worker`, `bus-repos`, `docs` | Add a command that summarizes repository diff, branch refs, check commands, check results, worker transcript highlights, and manual review status. It should not auto-promote code. | A worker run can end with a `review.md` artifact that a human can accept, reopen, or reject. |
| AgentOps stack initialization | `services.yml`, `profiles`, `bus-operator-deploy`, `docs` | Provide a supported local stack profile or init command for AgentOps. It should generate non-secret config, choose durable Events storage, configure repos, and tell the operator which token files or credential sources are required. | A new operator can initialize the local stack without reading module e2e scripts. The generated configuration avoids raw secrets in committed files. |
| Support diagnostic archive | `bus-worker`, `bus-api`, `bus-events` | Add a support-safe archive command that packages version info, selected profile names, provider readiness, storage kind, worker status, redacted Events samples, and evidence-pack manifests. | The archive is useful for support triage and passes a redaction test for token-like values. |
| Synthetic public proof repository | `docs`, example repositories, `bus-worker` | Maintain a small synthetic repository and published output bundle that demonstrates the full worker evidence path without private code or customer data. | The public proof can be regenerated from a documented command and its generated manifest records BusDK module versions. |

## Required P2 features

These features matter for scaling the package beyond local supervised pilots,
but they should not block the first paid offer.

| Feature | Owning modules | Required behavior | Definition of done |
| --- | --- | --- | --- |
| Service-owned worker scheduler | `bus-integration-worker`, `bus-task`, `bus-work` | Consume queued work, claim capacity, launch workers, recover stale claims, and publish queue/capacity status without the supervisor manually creating every worker. | Multiple queued tasks are processed up to configured capacity, stale claims do not hold capacity forever, and status shows the next action. |
| Service-owned Events relay for remote workers | `bus-events`, `bus-api-provider-events`, deployment modules | Move worker request, status, message, and evidence Events across environments through service-owned relay, not manual shell sync. | A local supervisor can create a task for a remote environment and recover worker evidence after remote service restart. |
| Container and VM runner providers | `bus-integration-worker`, `bus-integration-containers`, VM modules | Add runner providers behind the existing worker runner interface without changing worker API callers. | The same worker API can select `direct`, container, or VM runners and still produce the same evidence bundle shape. |
| Signed or attestable evidence | `bus-events`, `bus-worker`, release modules | Add signatures, checksums, or attestations for evidence bundles and event exports. | A buyer can verify that an evidence bundle has not changed after generation. |
| Promotion and PR workflow | `bus-repos`, GitHub integration, `bus-worker` | Turn accepted worker output into a controlled PR or branch promotion flow after human review. | The system can produce a PR or promotion request that links back to the evidence bundle. |
| Billing and entitlement automation | billing/auth modules, `busdk.com` | Connect the AgentOps package to purchase, entitlement, quota, and support-plan state. | A paid account or license can enable the package without manual allowlisting. This can follow the first concierge sale. |

## Minimum weekend cut

The minimum commercially usable cut is:

1. Start the local AgentOps stack with durable Events.
2. Run a deterministic fake-Codex demo and an optional real-Codex demo.
3. Generate an evidence bundle from each run.
4. Publish the synthetic evidence bundle and an assurance page.
5. Sell the package as supervised local Codex worker operations with evidence,
   not as autonomous remote development.

The implementation should not wait for scheduler, remote relay, container
runners, VM runners, automated PR creation, or billing automation. Those are
important, but they are not the proof gap that blocks a first paid pilot.

## Immediate backlog

The first implementation tasks should be small and testable:

1. Add `bus workers evidence` for one worker id using existing workers API,
   Events replay, logs, attach, and message projection.
2. Add redaction tests for evidence, logs, attach, and support diagnostics.
3. Add `bus workers doctor` against the local service stack.
4. Add an AgentOps demo workflow that wraps the existing repos-backed worker
   proof in an operator-facing command or script.
5. Add public docs for the assurance model and generated synthetic proof.

This sequence turns the existing worker substrate into something a buyer can
inspect. It also keeps the commercial claim aligned with the actual software:
BusDK can already operate local sandboxed Codex workers through the product
path, but it still needs a first-class evidence and assurance surface before
it is credible as a paid AgentOps package.

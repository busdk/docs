# Deterministic Task Evidence And Remote Worker Lane Handoff

This handoff captures the goal discussed in the conversation thread that led to
the deterministic task evidence, service-owned relay, and trustworthy remote
worker lane planning work. It is meant to let a future thread restart without
depending on chat memory.

## Goal

Make remote development workers trustworthy enough that normal work can move
through Bus services instead of through operator shell rituals. A local
supervisor should be able to create a task, route it to a configured remote
environment such as dev-hg or H100, have service-owned infrastructure launch a
Codex App Server worker, and review the result from durable task evidence,
attachments, Notes, and status output.

The immediate planning shape is now captured across the root and module
`PLAN.md` files. The implementation goal is still open: every worker attempt
must emit deterministic, non-secret evidence for terminal status, remote
identity, model/runtime selection, attempt identity, worker logs, branch and
commit state, validation commands, closeout state, Notes, and failure or block
classification.

## What This Thread Covered

The operator asked what still needs to be done for several related work items.
The answers converged into one product path:

- Service-owned task scheduler for remote workers: a long-lived service should
  consume queued task work, launch App Server workers up to configured
  capacity, avoid stale claim replay, and expose queue and worker status.
- Remote credential source selection: controller, remote Events, and worker
  runtime credentials should come from explicit remote config or token files as
  the normal path. A process-global token is only fallback. Expired or missing
  credentials must fail early with actionable diagnostics.
- Systemd user deployment for Bus infrastructure: a local or remote worker
  host should start Bus Events, integration/runtime, optional API, and provider
  handlers through one user-service profile instead of manual per-handler
  launches.
- Durable task and Notes evidence: visible task Events must not disappear on
  memory-backed restarts; normal development services should use durable Events
  storage; worker Notes should sync and be queryable by module, task, session,
  tag, source, and origin.
- First-class task file and artifact transfer: patches, logs, and evidence
  bundles should move through `bus dev task` attachments and extraction, not
  through `scp` or shared-path side channels.
- Trustworthy remote worker lane: remote workers should launch through the same
  service pattern, run queued tasks, return evidence, and avoid manual
  environment-specific correction.
- Remote freshness command: worker hosts should update root/submodules, install
  changed tools, rebuild or reload worker images only when needed, and report
  source, tool, and image identity.
- Service-owned Events relay: event sync between local and remote systems is a
  high-priority gating dependency, not medium-priority polish. Normal work
  should not require manual export/import loops.
- Deterministic task evidence: every attempt should report enough structured
  fields for review, retry, promotion, and model/runtime comparison without
  remote shells, container logs, or prose-only closeout.

## Current Plan State

Root `PLAN.md` now has explicit sections for the high-priority
service-owned Events relay, deterministic task evidence, durable task and Notes
evidence, remote credential source selection, and the refined trustworthy remote
worker lane finish line.

The current tree uses `bus-integration-task` as the task integration module.
Older names such as `bus-integration-dev-task` should not be used for new plan
work.

`bus-dev/PLAN.md` owns the operator and supervisor surfaces:

- consume scheduler-owned queue and worker status;
- operationalize patch/log/evidence transfer through task attachments;
- decode and classify deterministic attempt evidence in `task show`,
  `task monitor`, `work status`, and `work stats --all`;
- preserve and show requested versus observed model/profile/reasoning metadata;
- attribute recovery, intervention, repair, and blocked reasons in stats.

`bus-integration-task/PLAN.md` owns the worker producer and scheduler side:

- emit complete deterministic attempt evidence on every App Server lifecycle
  path;
- build a service-owned scheduler for remote App Server workers;
- enforce exact work-ref launch binding and stale-claim replay safety;
- publish scheduler queue, worker, capacity, drain, stale, and credential-source
  status;
- keep App Server as the normal worker backend and one-shot execution as legacy
  compatibility.

`bus-events/PLAN.md` owns bounded service relay and durable event movement:

- relay target-marked task and Notes events between local and remote systems;
- persist route checkpoints and prevent replay storms or origin loops;
- report route status, cursors, counters, pending/skipped counts, credential
  source labels, and last errors without leaking tokens.

`bus-operator-deploy/PLAN.md` owns remote readiness and deployment:

- user-level systemd service installation/update/status for Bus services;
- one administrator-configured combined runtime profile instead of one unit per
  integration/provider by default;
- memory-backed Events restart/export guard;
- remote freshness/source setup and status that records checkout, tool, and
  image identity.

The Notes modules own the durable Notes projection path: worker Notes should be
published through `bus.notes.*` Events and remain queryable after remote sync.

## Required Evidence Contract

The deterministic attempt evidence contract should include, at minimum:

- terminal status and classification;
- remote id and remote kind;
- requested and observed model, profile, reasoning effort, and relevant runtime
  labels;
- attempt id, sequence, superseded/prior attempt id when applicable, and worker
  id;
- durable worker log pointer or task attachment id/checksum;
- branch, worktree id, and commit hash or structured no-change reason;
- validation commands with command text, pass/fail/skip status, accepted skip
  reason, and concise output or artifact pointer;
- structured closeout state;
- Bus Notes ids and query metadata;
- start/end timestamps and non-secret duration data;
- redacted failure or block reason;
- token usage only when the backend concretely reports it.

Terminal work with missing modern fields should be classified as incomplete or
legacy partial rather than quietly treated as accepted progress.

## Recommended Implementation Order

1. Build on the accepted service-owned Events relay MVP. The 2026-06-05
   local-to-dev-hg proof and `bus-integration-events` regression cover
   routine remote task routing and returned worker/task terminal evidence for
   the MVP path, so deterministic task evidence work should use that relay as
   its baseline instead of reopening relay proof as unknown.
2. Complete the `bus-integration-task` attempt evidence envelope across success,
   no-change, failed, blocked, startup failure, timeout, exact-ref refusal,
   stale-task refusal, and remote-launch failure paths.
3. Teach `bus-dev` to decode, classify, display, and enforce the evidence
   contract in JSON/text status, monitor, stats, review, and promotion helpers.
4. Build the service-owned scheduler with exact work-ref binding, capacity,
   pause/drain, stale-claim requeue rules, and script-friendly status.
5. Make durable Events storage and Notes-over-Events the normal development
   path. Keep memory storage for tests or disposable smokes only.
6. Finish user-systemd service profiles and remote freshness so dev-hg/H100 can
   be refreshed, started, and checked without manual handler launches.
7. Prove first-class artifact transfer with a patch plus log/evidence
   attachment round trip, extracted locally without `scp`.
8. Run a live dev-hg or H100 proof: create task locally, relay to remote,
   service launches App Server worker, worker returns deterministic terminal
   evidence and artifacts, local supervisor reviews/promotes/pins, then repeat
   after a freshness or service restart path.

## Acceptance Shape

The smallest credible end-to-end proof is:

1. Local supervisor creates a real implementation task with explicit remote,
   model/profile/reasoning, and write scope.
2. Service-owned relay forwards the task to the remote Events service.
3. Remote scheduler sees the queued task, starts one App Server worker within
   configured capacity, and binds it to the exact work ref.
4. Worker publishes claim/running/terminal evidence with the required fields.
5. Worker attaches any patch/log/evidence artifacts through task Events.
6. Relay brings remote-origin evidence back locally without manual
   export/import.
7. `bus dev task show --format json`, `bus dev task monitor`,
   `bus dev work status`, and `bus dev work stats --all` show enough evidence
   to review the attempt.
8. Supervisor extracts artifacts if needed, runs validation, promotes or
   rejects the branch, and records the final closeout state.

## Constraints And Cautions

Do not make manual SSH, `scp`, ad hoc event export/import, process-global token
exports, one-shot `codex exec`, stale replay cleanup, or remote-specific Git
repair the normal path. They are break-glass or compatibility aids.

Do not treat a queued task, SSH-runner request, container-status event, or stale
remote process as an active worker. Count it separately until task Events show a
fresh claim, meaningful App Server/model progress, terminal evidence, a commit,
or an exact failure.

Do not store secret tokens in docs, task Events, unit files, command arguments,
or committed logs. Output should name credential source labels and token-file
paths only when safe.

Do not accept memory-backed Events for normal local or remote worker lanes whose
conversations should be retained. If memory storage is used for a disposable
smoke, visible task or Notes evidence must be exported before restart.

## Where To Restart

Start a future thread from the BusDK superproject root by checking the current
state rather than assuming this handoff is still complete:

```sh
cd <your-busdk-superproject-root>
git status --short
git -C docs status --short --untracked-files=all
sed -n '1,260p' PLAN.md
sed -n '230,430p' bus-dev/PLAN.md
sed -n '1,250p' bus-integration-task/PLAN.md
sed -n '80,160p' bus-events/PLAN.md
sed -n '1,140p' bus-operator-deploy/PLAN.md
```

Then choose the highest-leverage unblocked implementation lane. As of the
2026-06-05 relay MVP closeout, the best default is deterministic task evidence:
use the accepted service-owned Events relay as the baseline route, then make
remote attempts report enough structured terminal evidence for local review,
promotion, and repeat proof.

## Current Dirty-State Note

At the time this handoff was written, `docs/docs/goals/` already contained
other untracked goal handoff files from adjacent work, including the separate
`supervisor-identity-root.md` handoff. Do not overwrite those while continuing
this goal.

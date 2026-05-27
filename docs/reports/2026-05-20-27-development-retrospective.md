---
title: "Development retrospective, 2026-05-20 to 2026-05-27"
description: "Evidence-based retrospective for BusDK remote worker environments, GPU worker environments, task automation, service readiness, and release-preparation work from 2026-05-20 to 2026-05-27."
---

## Scope

This retrospective covers BusDK development work from 2026-05-20 through
2026-05-27. The main goal was to make remote development workers useful enough
to accelerate BusDK development: a local supervisor should be able to queue real
development work, route it to remote environments, have App Server based
workers produce commits, bring evidence back, review the result, iterate when
needed, and promote accepted changes into the authoritative branches.

The review uses hourly operator memos, Git history, submodule pins, worker task
evidence, and current repository state. It focuses on the software system and
the development system that produced it: task design, worker orchestration,
remote readiness, credentials, evidence, review, and release closeout.

This is not an implementation specification. Follow-up implementation contracts
belong in the owning module plans, SDD documents, and module `AGENTS.md` files.

## Executive summary

The week proved that remote workers can perform real BusDK development work.
The project reached App Server based worker execution in a GPU worker
environment, ran local model workers with Gemma 4 31B and GPT-OSS 120B
experiments, accepted useful remote-produced changes after review and repair,
improved local and remote worker substrates, and added tooling around task
metadata, terminal evidence, credential selection, event relay, worktree
cleanup, and worker guidance.

The goal was not fully complete by 2026-05-27 because the end-to-end loop still
depended too much on supervisor correction and environment-specific launch
knowledge.
The bottlenecks were mostly not model inference. The repeated blockers were
service readiness, queue consumption, stale source/tool state, ambiguous
credential selection, worker status replay, missing first-class file transfer,
and inconsistent fleet supervision.

The most important process learning was that the supervisor must act as a
worker-fleet lead, not only as a careful individual engineer. Parallel workers
helped when they were fed with clear, bounded tasks and reviewed quickly. The
same system slowed down when work was not queued steadily, when task
definitions were vague, or when active workers were not guided through the task
event interface.

## Goals and expected outcome

The target loop was:

1. A local supervisor creates or selects a real development task.
2. The task is queued through Bus task tooling rather than an ad hoc side
   channel.
3. A remote service consumes queued work and starts an App Server based worker
   up to configured capacity.
4. The worker uses the configured remote model and trusted workspace profile.
5. The worker edits, tests, commits, and reports evidence.
6. The supervisor reviews the result, guides follow-up work when needed, and
   accepts, reopens, or repairs the work.
7. Accepted work is promoted into the owning submodule and pinned in the
   superproject.
8. The same loop repeats after a fresh worker environment or non-persistent
   environment start without manual per-service shepherding.

The intended MVP did not require private image delivery. Source checkout,
build/install, and App Server workers were sufficient for this milestone.

## Actual outcome

The project achieved substantial parts of the loop. GPU-backed remote workers
were no longer theoretical: they could run App Server workers, use local models,
produce real commits, and expose reviewable results. Remote and local worker
environments also became important repair and infrastructure lanes. Several
worker-produced changes were accepted only after iteration, which is the
correct flow: the goal is not a perfect first attempt, but a repeatable path
from task to accepted work.

The remaining gap was automation maturity. Launching, refreshing, collecting,
and reviewing work still required too much human-supervisor memory. The project
therefore paused costly GPU use and shifted priority to local and remote
implementation work that improves remote productivity without requiring the GPU
worker environment to stay online.

## Evidence reviewed

The primary evidence was the hourly memo series from `logs/20260520-*` through
`logs/20260527-*`, the root superproject Git history for the same date range,
and submodule pins in the superproject. Representative current pins after the
week include:

| Area | Evidence |
| --- | --- |
| Worker task tooling | `bus-dev` pinned at `a120e08` |
| Events relay and sync | `bus-events` pinned at `79b8f72` |
| Integration services | `bus-integration` pinned at `eb14e34` |
| Dev task integration | `bus-integration-dev-task` pinned at `4618af9` |
| SSH runner integration | `bus-integration-ssh-runner` pinned at `cf0f7bb` |
| Deploy operator | `bus-operator-deploy` pinned at `4c36645` |
| Skill and guideline work | `skills` pinned at `241eef1` |

The root Git history for the period contained hundreds of commits and pins. The
commit stream clustered around remote worker execution, GPU worker offload,
Events relay/sync, credential handling, worker scheduler and App Server
corrections, worktree pruning, terminal evidence, task attachments, guidance,
and release preparation.

One live validation command still showed a remaining issue: a task statistics
query could not run with the local token file because the token was expired.
That is useful evidence that credential freshness and per-remote credential
selection are still active development concerns.

## Timeline

### 2026-05-20

The week started with multi-remote worker foundations: localhost and remote
substrates, worker dispatch experiments, gopls/debugger support, and
no-spend/offload testing. The project also refined AGENTS guidance, reduced
process ambiguity, and improved delivery hygiene around module pins and worker
review.

### 2026-05-21

Work continued on scalable remote execution and development productivity.
Memos show local and remote worker environment probing, worker task
maintenance, remote selection work, and repeated attention to release-quality
gates. The system was becoming usable, but still had too many environment-specific
assumptions.

### 2026-05-22

The team focused on SSH-Docker and external worker substrates. Image-backed
workers, App Server smoke tests, writable substrate checks, GPU worker gateway
and privileged-shell safety, and event import/export workflows were tested. The
important learning was that remote workers need first-class service and evidence
plumbing; manual sync can prove a path but should not be the product flow.

### 2026-05-23

GPU worker environment readiness and local model experiments advanced. Events
export/import proved that evidence could move between systems, but
local-supervisor-to-GPU-worker-environment routing remained too manual. The GPU
worker environment was close enough to run work, but not yet repeatable after a
fresh start.

### 2026-05-24

Gemma and GPT-OSS smoke tests, GPU worker launch scripts, and event sync work
made remote work more concrete. A release was published during this period.
The project also found drift between local, remote, and GPU worker environment
tool versions, which reinforced the need for remote freshness automation.

### 2026-05-25

GPU worker App Server based work became real. The system produced useful
remote commits and one accepted/pinned documentation-style result. At the same
time, several defects surfaced: service readiness was fragile, model/profile
switching on resumed App Server threads was confusing, and one-shot runner
patterns created architectural mismatch with the intended App Server design.

### 2026-05-26

The week peaked in parallel remote-worker experimentation. Multiple Gemma
workers ran, some work was salvaged after review, and the supervisor learned
that iteration plus review is the expected success path. The project also
identified and worked on local and remote worker environment issues:
deterministic scheduler behavior, credentials without process-global tokens,
service-owned event relay, first-class task attachments, terminal evidence,
worktree pruning, and worker status/stats.
Cost concerns led to pausing GPU worker environment use and collecting work
rather than continuing to spend on underused GPU capacity.

### 2026-05-27

The focus shifted to release closeout, guidance, skills, and retrospective
capture. The project updated persistent guidance and skill documentation so the
lessons from the week are not lost between worker sessions.

## Task-to-code mapping

### Remote worker execution

The requested outcome was a remote worker loop that could process real
development tasks. The code and configuration work touched task creation,
worker launch, App Server execution, terminal evidence, remote identity,
model/reasoning metadata, and branch/commit promotion.

The behavior improved meaningfully: remote workers could run real work and
produce commits. The remaining gap is that queue consumption and capacity
control must be service-owned and deterministic, not launched manually by the
supervisor.

### App Server worker model

The team converged on App Server workers as the normal runner pattern across
local, remote, and GPU worker environments. One-shot `codex exec` style flows
were found to be the wrong default because they split behavior from the App
Server supervision and live-guidance path.

The remaining work is to remove or de-emphasize legacy one-shot paths where
they create confusion, and to make model/profile switching explicit and
observable for retries and resumed threads.

### Credentials

The week exposed that process-global `BUS_API_TOKEN` is too blunt for
multi-remote development. The better direction is explicit remote environment
configuration and token files selected per controller, event relay, and worker
runtime.

The current system still needs better freshness handling and less reliance on
operator shell state. The expired-token statistics check during this
retrospective is a small but concrete example.

### Evidence and event relay

Event import/export and sync proved the evidence path, but manual scripts and
SSH side channels are not enough. The right product shape is service-owned,
bounded relay with clear attempt identity, terminal status, commit hash, remote
identity, model/reasoning data, and worker log pointers.

### Worktree cleanup

The project accumulated local and submodule worktrees quickly. Worktree pruning
became necessary for disk pressure and operational clarity. The important
quality constraint is that pruning must default to dry-run and must not remove
active, locked, dirty, or in-use worktrees.

### Documentation and persistent guidance

Several lessons were converted into durable guidance: root `AGENTS.md`, skill
indexes, skill authoring guidance, and retrospective guidance. This was a
positive outcome because the same corrections should not depend on one
supervisor's short-term memory.

## Source code and architecture review

The strongest architectural correction was choosing a consistent runner model:
App Server workers everywhere, with environment-specific model profiles and
service-managed launch behavior. This reduces special cases between local,
remote, and GPU worker execution.

The second strong correction was moving toward one or a few user-level systemd
services for Bus infrastructure. A single-process or small-service deployment
shape is a better MVP than running every integration handler manually or inside
worker containers. Docker remains useful for isolated workers, but Bus
infrastructure services should not depend on being run inside the same worker
container model.

The biggest maintainability risk is still broad, vague work items. When items
such as "package operator path" or "improve stats" were not split into exact
acceptance criteria, they became difficult to finish. Future tasks should name
the feature, owning module, expected command or service behavior, validation
command, and evidence that marks the work complete.

## Agent-worker review

Remote workers performed useful work when tasks were small, explicit, and
bounded. Gemma-based workers were able to contribute, especially when the
supervisor guided follow-up attempts and reviewed results instead of expecting
first-pass perfection.

Workers struggled when instructions were too broad, when their checkout or tool
state was stale, or when the wrong runner pattern was used. Several failures
were not model failures; they were environment and orchestration failures.

Worker memos and terminal evidence improved over the week, but they are still
not deterministic enough. Every task attempt should leave the same minimum
evidence shape: task id, attempt id, remote id, model, reasoning effort, worker
log pointer, terminal status, branch, commit, validation commands, and explicit
follow-up state.

## Human orchestration review

The supervisor made real progress but did not keep the worker fleet fed and
measured consistently. Parallel work was effective in bursts, especially around
the high-concurrency experiments, but the operating mode was not sustained.

The user feedback materially improved the plan. Important corrections included:
use App Server workers everywhere, stop spending on underused GPU capacity, avoid
manual lock-file deletion, make tasks asynchronous and queue-backed, avoid
one-shot runner upkeep, split vague items into clear definitions of done, and
write lessons into durable guidance.

The strongest process improvement is to treat task queues, worker capacity,
review, reopen, and promotion as a managed development system. The supervisor
should not be the only scheduler. The platform should accept queued work,
launch up to configured capacity, preserve evidence, and allow asynchronous
guidance through the task event interface.

## Key findings

### Finding 1: Remote workers can produce real BusDK work

Evidence: GPU-backed workers ran App Server based tasks, used local models,
produced branches and commits, and some results were accepted after review or
repair. Remote and local worker environments also produced accepted
infrastructure work.

Impact: The development model is viable. The remaining problem is not whether
remote work can happen, but whether it happens repeatably with less human
shepherding.

Confidence: High.

### Finding 2: The main blockers were orchestration and readiness, not model capacity

Evidence: Failures repeatedly involved stale tools, missing service readiness,
queue replay, token selection, status ambiguity, write-scope mistakes, and
manual event/file transfer. Gemma and GPT-OSS experiments both showed useful
capability when the environment was correct.

Impact: The fastest path to productivity is service automation and task-system
improvement, not only model swapping.

Confidence: High.

### Finding 3: One-shot runner paths created product confusion

Evidence: The team repeatedly had to clarify that App Server workers should be
the normal path on local, remote, and GPU worker environments. One-shot runner
debugging did not match the desired live-guided worker flow.

Impact: Keeping unused runner paths increases maintenance and causes workers to
exercise the wrong behavior.

Confidence: High.

### Finding 4: Parallel work was underused

Evidence: The strongest output periods occurred when multiple bounded workers
were active and reviewed quickly. Other periods had too much serial
supervision, status checking, or manual repair.

Impact: BusDK needs a steady asynchronous task queue and deterministic capacity
scheduler so worker utilization does not depend on manual attention every hour.

Confidence: High.

### Finding 5: Credential and token handling needs first-class remote scoping

Evidence: Multi-remote work repeatedly mixed controller, remote Events, and
worker runtime credential concerns. A live statistics query during this review
failed because the selected local token file had expired.

Impact: Process-global token state is too fragile for multi-remote
development. Credentials must be selected by remote config or explicit token
files, with freshness checks and clear failure messages.

Confidence: High.

### Finding 6: Published docs need reports, but process rules belong elsewhere

Evidence: The docs site already separates public docs from agent instructions.
The retrospective is useful as a public project report, while worker operating
rules belong in `AGENTS.md`, skills, plans, and SDD files.

Impact: Creating a reports section is appropriate, but reports should summarize
evidence and outcomes without leaking secrets or turning public docs into agent
runbooks.

Confidence: High.

## Root causes

| Issue | Immediate cause | Systemic cause | Preventive action |
| --- | --- | --- | --- |
| Manual GPU worker shepherding | Services and launchers needed task-specific correction | Remote readiness was not yet productized as services | Build deterministic service/scheduler and systemd user setup |
| Stale remote state | Remote tools and checkouts drifted from reviewed local state | Freshness was not automatic or recorded clearly | Add refresh/build/install/image identity recording |
| Ambiguous credentials | Different parts of the loop relied on shell environment or token files | Multi-remote credential model was not first-class enough | Use per-remote config and explicit token sources |
| Weak closeout evidence | Workers did not always report the same metadata | Evidence schema was implicit | Require attempt id, remote id, model, commit, logs, terminal status |
| Inconsistent parallelism | Supervisor manually decided when to feed workers | No deterministic queue/capacity scheduler | Keep work queued and let services launch up to configured capacity |
| Vague unfinished items | Some work items described themes instead of deliverables | Planning did not enforce definition of done | Write tasks with owner module, command behavior, validation, and evidence |

## Learnings converted into guidance

The week produced several durable operating rules:

- Use App Server workers as the normal worker path across local, remote, and
  GPU worker environments.
- Treat one-shot runner flows as legacy or exceptional unless a specific
  current task proves they are needed.
- Keep costly GPU worker environments paused unless they are actively needed
  and workers are ready to use them.
- Do not manually remove lock files as a normal workflow; first verify whether
  the lock is active and wait when appropriate.
- Keep a steady queue of bounded tasks; the supervisor should review, guide,
  and measure rather than manually schedule every worker.
- Write unfinished work items with concrete scope, module ownership,
  acceptance criteria, and validation evidence.
- Convert repeated mistakes into `AGENTS.md`, skill, plan, SDD, test, or CI
  updates.

## Remaining work

The following items remain from the goal and are written as concrete
deliverables rather than broad themes.

| Priority | Work item | Definition of done |
| --- | --- | --- |
| High | Service-owned task scheduler for remote workers | A service consumes queued `bus dev task` work, starts App Server workers up to configured capacity, avoids replaying stale claims, and exposes current queue/worker status. |
| High | Systemd user deployment for Bus infrastructure | A local or remote worker environment can start the required Bus API, Events, integration, and provider handlers as one or a few user services without manually launching each handler. |
| High | Remote credential source selection | Controller, remote Events, and worker runtime credentials are selected from explicit remote config or token files, not from a process-global token as the normal path. Expired or missing credentials fail with actionable diagnostics. |
| High | First-class task file and artifact transfer | `bus dev task` can attach and retrieve patches, log bundles, and evidence files without `scp` or ad hoc side channels. |
| High | Trustworthy remote worker lane | A remote worker environment can launch App Server workers through the same service pattern, run queued tasks, and return evidence without manual environment-specific correction. |
| High | Remote freshness command | A worker environment can update root/submodules, build/install changed tools, rebuild/reload worker images only when needed, and record source, tool, and image identity. |
| Medium | Service-owned Events relay | Event sync between local and remote systems runs as a bounded service with clear checkpoints and no manual import/export loop for normal work. |
| Medium | Deterministic task evidence | Every worker attempt reports terminal status, remote id, model/reasoning, attempt id, worker log pointer, branch, commit hash, validation commands, and closeout state. |
| Medium | Model/profile switching semantics | App Server retries and resumed threads expose and honor the requested model/profile, or fail clearly when a thread cannot switch models. |
| Medium | Worker stats for recovery analysis | Stats report model attempted, remote id, attempt count, failures, supervisor interventions, GPT-backed repair work, accepted work, and blocked reasons. |
| Medium | Worktree pruning in normal operations | The pruner defaults to dry-run, detects active/locked/dirty root and submodule worktrees, and can reclaim obsolete finished worktrees after review. |
| Medium | Operator path pages | User-facing operations docs explain what to install, how to refresh, how to start services, how to launch queued work, and what evidence proves success. |

## Recommendations

The next development push should prioritize local and remote work that removes
remote friction before spending on GPU capacity again. The best order is:
service-owned scheduler, systemd user service packaging, remote credential
selection, task attachments, remote freshness, and bounded event relay.

A GPU worker environment should return only after the service path can keep it
busy. At that point, the proof should be ordinary: queue multiple bounded
tasks, let the configured scheduler launch workers, review and reopen through
task events, promote accepted work, and confirm the same loop repeats after a
fresh worker-environment start.

## Open questions

- Which exact Bus binary should own the first single-process or few-process
  service composition for the MVP?
- Should remote worker capacity be configured per remote, per model, or both?
- How much of model/profile switching should be implemented in Bus task
  metadata versus App Server thread management?
- Which statistics should be part of the stable CLI output, and which should
  remain internal debugging data?

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Project reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../testing/index">Testing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- Hourly development memos for 2026-05-20 through 2026-05-27.
- Root superproject Git history for 2026-05-20 through 2026-05-27.
- Current superproject submodule pins after the release-preparation and
  guidance updates.
- Current validation evidence, including the expired-token task statistics
  failure observed during retrospective preparation.

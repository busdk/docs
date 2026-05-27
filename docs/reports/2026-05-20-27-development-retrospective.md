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

A second remaining gap is evidence durability. The week produced a large amount
of useful task and note evidence, but too much of it lived in hourly memos,
memory-backed task services, retained worker directories, or environment-local
process state. The current visible task ledger is enough to validate the major
patterns, not enough to be treated as the canonical archive of every task
conversation from the week.

## Evidence reviewed

The primary evidence was the hourly memo series from `logs/20260520-*` through
`logs/20260527-*`, the root superproject Git history for the same date range,
submodule histories for the worker/runtime modules, current task statistics
from the still-live local task Events API, Bus Notes evidence recorded in
memos, and a current remote worker environment inspection. Representative
current pins after the week include:

| Area | Evidence |
| --- | --- |
| Worker task tooling | `bus-dev` pinned at `2192849` |
| Events relay and sync | `bus-events` pinned at `3e7adf3` |
| Integration services | `bus-integration` pinned at `eb14e34` |
| Dev task integration | `bus-integration-dev-task` pinned at `e59c404` |
| SSH runner integration | `bus-integration-ssh-runner` pinned at `cf0f7bb` |
| Deploy operator | `bus-operator-deploy` pinned at `4c36645` |
| Notes integration | `bus-integration-notes` pinned at `8830eb0` |
| Skill and guideline work | `skills` pinned at `0c89c79` |

## Metrics snapshot

These numbers are git and task-ledger measurements for 2026-05-20 through
2026-05-27. Commit totals should be read as evidence volume, not as a
deduplicated feature count, because superproject pin commits often correspond
to separately counted submodule commits.

| Metric | Count | Notes |
| --- | ---: | --- |
| Visible task streams | 89 | Current local task ledger; all terminal at review time. |
| Done task streams | 37 | All 37 were promoted or accepted-or-promoted in task metadata. |
| Failed task streams | 6 | Terminal task result, not including recovered attempts. |
| Blocked task streams | 3 | Terminal task result, not including recovered attempts. |
| Canceled task streams | 43 | Mostly stale, false-active, superseded, or hygiene closeouts. |
| Handoffs | 31 | Reopen/repair or cross-attempt handoff evidence in task stats. |
| Recovered tasks | 10 | Tasks that had failed/blocked attempts before final success. |
| Root superproject commits | 379 | Mostly pins, memos, planning, scripts, and orchestration. |
| Submodule commits | 542 | Across 25 submodules with commits in the date range. |
| Combined observed commits | 921 | Root plus submodule histories, not deduplicated. |
| Root git churn | +7,662 / -3,482 | 80 root-level paths, mostly orchestration and pins. |
| Submodule git churn | +58,260 / -4,658 | 277 per-module file paths; includes logs/docs/skills. |
| Submodule churn excluding logs/docs/sdd/skills | +43,300 / -4,223 | Closer to product and developer-tooling code/docs churn. |

The largest submodule commit counts were concentrated in the development
system:

| Submodule | Commits | Git churn |
| --- | ---: | ---: |
| `logs` | 254 | +10,980 / -221 |
| `bus-dev` | 89 | +15,753 / -2,041 |
| `bus-integration-dev-task` | 48 | +6,265 / -668 |
| `bus-operator-deploy` | 32 | +7,887 / -447 |
| `bus-integration-ssh-runner` | 17 | +2,312 / -180 |
| `bus-events` | 15 | +3,345 / -189 |
| `docs` | 14 | +980 / -145 |
| `bus-integration` | 13 | +1,862 / -88 |
| `bus-remote` | 12 | +2,166 / -167 |
| `skills` | 9 | +2,435 / -25 |
| `bus-lint` | 8 | +1,680 / -173 |
| `bus-integration-upcloud` | 5 | +1,264 / -129 |

Measured as capability clusters rather than commits, the week produced or
substantially advanced about 15 features or operating surfaces:

| Capability cluster | Evidence shape |
| --- | --- |
| Remote task routing and selection | `bus-dev` remote/environment commits and task stats. |
| SSH-Docker worker substrate | `bus-dev`, `bus-integration-ssh-runner`, and smoke-script commits. |
| App Server worker execution | `bus-integration-dev-task` lifecycle and closeout commits. |
| GPU worker local-model proof | Worker memos, task attempts, and remote-launch commits. |
| Model/reasoning metadata | Task metadata, stats, and closeout changes. |
| Per-remote credential selection | Token-file and credential-source commits. |
| Events sync and relay | `bus-events` sync, relay, and service commits. |
| Terminal evidence relay | Task status/evidence commits and memos. |
| Task attachments | `bus-dev` attachment commits and extraction help. |
| Worker scheduler/service planning | Scheduler/service repair and PLAN commits. |
| User-level service deployment | `bus-operator-deploy` service install and status slices. |
| Same-process integration host | `bus-integration` run/config/health work. |
| Worktree pruning | Safe dry-run prune command and cleanup evidence. |
| Durable Notes evidence path | Notes metadata search and Notes-over-Events sync planning. |
| Supervisor/worker guidance | Root `AGENTS.md`, skills, and worker contract updates. |

The root Git history for the period contained hundreds of commits and pins. The
commit stream clustered around remote worker execution, GPU worker offload,
Events relay/sync, credential handling, worker scheduler and App Server
corrections, worktree pruning, terminal evidence, task attachments, guidance,
Notes evidence, and release preparation. The highest-change modules matched
the retrospective themes: `bus-dev` added remote routing, credentials, stats,
attachments, pruning, and Compose defaults; `bus-integration-dev-task` added
App Server lifecycle, sandbox, closeout, remote metadata, and worker evidence
controls; `bus-events` added sync, relay, and Notes-operation event support;
and `bus-integration-notes` added metadata/tag search.

The visible local task ledger is useful but incomplete. With the correct local
development token, `bus dev task stats --all` reported 89 visible terminal
tasks: 37 done, 6 failed, 3 blocked, and 43 canceled, with 37 promoted or
accepted-or-promoted results. The same statistics showed 31 handoffs and 10
recovered tasks, which supports the finding that reopen/review/repair became a
normal success path. The task ledger also showed 81 local worker-environment
streams, 5 remote worker-environment streams, 3 GPU worker-environment streams,
and 5 legacy/API-url streams.

Those task numbers are not a durable full-week archive. The local and remote
task services inspected during the evidence pass were still backed by in-memory
Events stores; a remote worker environment also had running Events, Docker,
container, and Notes-related services, but its current task CLI view returned
zero visible tasks, and its Notes API endpoint did not answer the current Notes
CLI path. Bus Notes evidence is therefore available mainly through recorded
memo queries and note IDs, plus later local smoke evidence, not as a complete
queryable cross-environment notes corpus. This is itself one of the major
findings: the development system needs durable Events and Notes storage before
future retrospectives can rely less on hourly memos.

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
capture. New development was paused while active work was drained, queued or
false-active remote work was canceled, and remote checkouts were checked for
unretrieved accepted commits. The project updated persistent guidance and skill
documentation so the lessons from the week are not lost between worker
sessions. It also found that the task and Notes evidence path itself needed
repair: current task Events services were still memory-backed, the local task
ledger required the correct development-account token to reveal its 89 visible
terminal streams, and remote Notes/task evidence was not yet uniformly
queryable from the current CLI.

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

The current task statistics implementation is valuable because it can separate
terminal outcomes, promoted work, handoffs, recovered attempts, remote ids, and
recipient-level throughput. It also exposed a product gap: statistics are only
as reliable as the Events store behind them. Memory-backed task services made
the numbers useful for this report but not sufficient as a permanent audit log.

### Bus Notes evidence

Workers began recording searchable Bus Notes evidence, and memos preserved
queries such as `module:<module> task:<work-ref> tag:agent-work-log` plus
specific note IDs. Later work added metadata and tag search to the Notes
integration and taught the retrospective skill to require Notes evidence.

The remaining gap is runtime integration. Notes need durable operation events,
projection into the Notes API, and cross-environment sync through Events before
agent work logs can be queried consistently after a remote service restart or
release pause. Until that exists, hourly memos remain the canonical narrative
evidence for this week.

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

The biggest operations risk found during the renewed evidence pass is using
memory-backed Events services for development worker lanes. That backend is
appropriate for tests and disposable smokes, but it is the wrong default for
task conversations, Notes evidence, release closeout, or remote-worker history.
The follow-up commits already moved guidance and Compose defaults toward
Postgres-backed Events and Notes, but existing in-memory service history still
needs export before those services are restarted.

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

The local task ledger reinforces that distinction. Its visible 89 terminal
streams included 37 promoted results and 43 canceled streams. Many cancellations
were useful hygiene rather than failure: they retired stale, false-active, or
superseded task streams so they stopped masquerading as active capacity. The 10
recovered tasks and 31 handoffs are also positive evidence for the
review-reopen-repair loop, but only when the final promoted diff and supervisor
checks agreed with the task closeout.

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

### Finding 7: Retrospective evidence is still too dependent on live memory and memos

Evidence: The local task ledger could show 89 terminal streams only when queried
with the correct development-account token, and that ledger came from a
still-live in-memory Events service. The remote worker environment had running
Events and Notes-related services, but the current task CLI view returned zero
visible tasks and the Notes CLI did not reach a compatible Notes API endpoint.
Memos preserved worker-note queries and note IDs, and later local smoke tests
proved Notes search, but the cross-environment Notes/event path was not yet a
durable retrospective source.

Impact: The report can make high-confidence claims about repeated patterns, but
future reviews should not have to reconstruct task history from hourly memos
and retained process state. Durable Events and Notes storage are part of the
development platform, not optional reporting polish.

Confidence: High.

## Root causes

| Issue | Immediate cause | Systemic cause | Preventive action |
| --- | --- | --- | --- |
| Manual GPU worker shepherding | Services and launchers needed task-specific correction | Remote readiness was not yet productized as services | Build deterministic service/scheduler and systemd user setup |
| Stale remote state | Remote tools and checkouts drifted from reviewed local state | Freshness was not automatic or recorded clearly | Add refresh/build/install/image identity recording |
| Ambiguous credentials | Different parts of the loop relied on shell environment or token files | Multi-remote credential model was not first-class enough | Use per-remote config and explicit token sources |
| Weak closeout evidence | Workers did not always report the same metadata | Evidence schema was implicit | Require attempt id, remote id, model, commit, logs, terminal status |
| Non-durable task and note evidence | Development services still used memory-backed Events or unqueryable Notes endpoints | Evidence storage was treated as launch plumbing instead of product state | Export visible history, run development Events/Notes on durable storage, and make Notes-over-Events projection routine |
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
- Treat development task Events and Bus Notes as durable product evidence.
  Memory backends are acceptable for tests and disposable smokes, not for
  normal local or remote worker lanes.
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
| High | Durable task and Notes evidence | Visible task Events are exported before memory-backed services restart, normal development services use durable Events storage, and worker Notes can be queried by module, task, session, tag, and origin after remote sync. |
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
durable task and Notes evidence export/storage, service-owned scheduler,
systemd user service packaging, remote credential selection, task attachments,
remote freshness, and bounded event relay.

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
- Submodule Git histories for `bus-dev`, `bus-integration-dev-task`,
  `bus-events`, and `bus-integration-notes`.
- Current superproject submodule pins after the release-preparation and
  guidance updates.
- Current local task statistics from the still-live task Events API: 89
  visible terminal streams, 37 done, 6 failed, 3 blocked, 43 canceled, and 37
  promoted or accepted-or-promoted results.
- Bus Notes evidence recorded in memos, including worker-note query strings and
  note IDs, plus later local Notes smoke evidence.
- Current remote worker environment inspection: running Bus service containers
  were present, but the current task CLI view returned zero visible tasks and
  the Notes CLI endpoint check returned a compatibility failure.

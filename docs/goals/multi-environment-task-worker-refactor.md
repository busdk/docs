# Multi-Environment Task/Worker Refactor Handoff

## Purpose

This handoff captures the state of the long-running conversation about the
BusDK multi-environment task and worker refactor. It is written so a new
conversation thread can resume the same goal without needing the original chat.

The active objective is to make `bus-task` the generic multi-environment
task/thread system, move proactive worker behavior into worker-owned modules,
keep runtime/provider execution in `bus-agent`, preserve local and remote
worker environments in one Bus deployment, document the new architecture, and
verify and commit the finished changes.

The goal is not complete. A lot of foundation work has landed, and the local
Spark worker lane is now usable, but the full end state still needs more
module-by-module implementation and proof.

## Original Product Direction

The refactor started from a naming and ownership clarification.

`bus-task` should be the user-facing generic task/thread surface. It should not
be a development-only or Codex-only command. Tasks need approval, priority,
blockers, dependencies, assignment metadata, deterministic queue state, and
enough non-secret routing metadata for workers to pick them up later in the
right environment.

Worker identity and worker-oriented orchestration should move out of
task-specific integration code. Durable worker identity belongs in
`bus-worker`. Reusable integration behavior for claims, routing, capacity,
worker starts, replay selection, health, consumer loops, and scheduler decisions
belongs in `bus-integration-worker`.

`bus-integration-task` should become thinner. It can bridge `bus.task.*` event
streams to task execution, but it should not remain the hidden owner of worker
identity, queue selection, worker routing, claim arbitration, capacity, or
runtime launch policy.

`bus-agent` remains the runtime/provider execution layer. Provider execution,
Codex App Server protocol handling, App Server buffering, and backend runtime
details belong there, not in task or worker identity modules.

The product must keep first-class support for these environments in one Bus
deployment:

- local workers
- ssh-docker workers
- hosted workers
- ChatGPT/Codex subscription workers
- API-key workers

The operator also chose the user-facing name `repos` for Git-backed repository
features:

- `bus-repos` for user-facing repo concepts and CLI
- `bus-integration-repos` for Git-backed storage integration
- `bus-api-provider-repos` for API/controller integration

The user-facing product should say `repos`, not `git`, because Git is the
implementation technology rather than the user-facing project-management tab.

## Important Operating Lessons

Several operator corrections became durable project guidance during this
thread.

First, always write important repeated lessons into the relevant `AGENTS.md`
instead of trusting chat memory. Corrections about naming, model ids,
architecture priority, logging, or process should become durable guidance in
the same work session.

Second, troubleshoot by turning the lights on. Enable verbose logging first.
If evidence is too thin, add DEBUG/TRACE-capable logs in the owning module
before making broad behavior changes. Verify root causes with proof instead of
assuming from symptoms.

Third, simplify before building. Before creating a feature, abstraction,
workflow, or support system, ask whether the goal can be met by removing a
requirement, narrowing the problem, reusing a smaller existing primitive, or
accepting a temporary manual step. Less system is preferred when it honestly
solves the current need.

Fourth, keep the core substrate minimal. Project-specific practices such as
Bus Notes, PLAN-driven closeout, local reporting rituals, and supervisor
bookkeeping should be optional overlays unless source-backed proof shows the
core worker/task/event substrate truly depends on them.

Fifth, local Spark worker work should use the exact raw model id:

```text
gpt-5.3-codex-spark
```

Do not normalize this model name as part of the current refactor. Passing the
configured model id through exactly is the current rule. Alias or normalization
logic can be a later UX feature, but it is not on the critical path.

## Current Architecture State

`bus-task` already owns much of the generic task/thread surface. Current
capabilities include task creation, approval/ready transitions, assignment
metadata, priority, blockers, dependencies, deterministic queue selection, and
monitor snapshots with task queue metadata. The monitor path has also gained an
incremental projection cache so worker-facing queue reads do not need to replay
all task history on every poll.

`bus-integration-worker` is no longer only a skeleton in practice. It now owns
many reusable worker packages, including worker claim ordering, claim
verification, routing, replay selection, worker-start request shaping, queue
decisions, health/stale-worker checks, consumer loops, and scheduler runtime
helpers. Its public docs still need more cleanup so they tell the same story as
the code.

`bus-integration-task` has been progressively slimmed. Many worker-side rules
were extracted out of `cmd/bus-integration-task/main.go` and
`pkg/devtaskintegration` into `bus-integration-worker`, but the command still
contains too much top-level orchestration glue. It remains the bridge from
task events to execution, and it currently owns the App Server task prompt
contract used by local Spark workers.

`bus-worker` has started becoming real. The latest committed slice created a
first durable identity contract in `bus-worker` with an internal identity
package, validation and normalization tests, and README/PLAN contract text.
This is only phase 1. There is still no finished `bus worker` CLI product.

`bus-agent` received an App Server buffering fix so diagnostic bursts do not
drop assistant text during local Spark worker runs. Runtime/provider execution
should continue to stay there.

The repos family modules were initialized and planned, but repo automation is
not on the immediate critical path for getting workers productive. They should
not block the worker v1 unless the current slice explicitly needs repository
storage behavior.

## Local Events and Task Substrate

The local Events API was repaired during the thread. The important fixes were:

- `bus-api-provider-events` now serves conditional append over HTTP.
- Published `bus.task.*` lifecycle events seed the conditional latest-state
  used by worker claiming.
- Local host-worker smoke scripts fail if the source-run Events API exits
  early.
- Disposable local Events smokes enable TRACE by default.

The core local task proof script is:

```bash
scripts/test-local-task-events-proof.sh
```

It proved a disposable local Events API can create a task, approve it, list it
as ready, replay it through `show`, and expose it through
`monitor --format json`.

The local host-worker smoke script is:

```bash
scripts/test-local-host-worker-smoke.sh
```

It proved a local worker can see ready work, claim atomically, start execution,
emit progress, and finish to `bus.task.done` on a fresh source-run local Events
provider.

## Local Spark Worker Lane

The local Spark worker lane is now usable enough for real work, with an
important caveat.

The proven lane is:

```text
agent backend: codex-appserver
model: gpt-5.3-codex-spark
sandbox: full
worktree: supported
commit promotion: not currently used on this lane
```

The useful environment shape for local Spark smoke runs has been:

```bash
BUS_LOCAL_HOST_WORKER_SMOKE_AGENT_BACKEND=codex-appserver
BUS_LOCAL_HOST_WORKER_SMOKE_MODEL=gpt-5.3-codex-spark
BUS_TASK_CODEX_SANDBOX=full
BUS_TASK_TRACE=true
```

The local macOS `workspace-write` App Server path is still a separate substrate
bug. The evidence points at the source `CODEX_HOME/tmp/arg0` cache lacking the
Linux sandbox helper expected by the stricter workspace-write setup. Do not
block useful local Spark work on that bug. Treat it as a follow-up substrate
issue.

Commit-enabled isolated worktree workers currently require the stricter write
sandbox path or a trusted lifecycle policy. Because the proven local Spark lane
uses `BUS_TASK_CODEX_SANDBOX=full`, the practical local worker lane for now is:

```text
worktree=true
commit=false
```

That means workers can produce reviewable work in isolated worktrees, but the
supervisor still needs to inspect and promote accepted diffs manually or through
later tooling.

## Spark Worker Focus Problem

The current immediate worker problem is not launch, claim, auth, worktree prep,
Codex process startup, thread creation, or App Server turn startup. Those have
all been proven.

The problem is worker focus inside the model turn.

Local Spark workers were reaching the App Server turn but behaving too much
like broad supervisors. Narrow recipient-local tasks drifted into:

- `PLAN.md`
- `README.md`
- broad repository scans
- "no change needed" conclusions
- generic verification instead of the named requested fix

This was especially visible with a concrete `bus-task` issue:

```bash
bus-task/bin/bus-task new --help
bus-task/bin/bus-task assign --help
```

Both commands still printed the top-level help banner instead of
subcommand-specific help. Workers were asked to fix that exact behavior, but
they drifted into broader scans before touching the narrow CLI surface.

Several fixes landed to address this:

- `bus-integration-task` now has a reduced `minimal-implement` prompt profile
  separate from `minimal-smoke`.
- `minimal-smoke` remains for read-only or proof-only tasks.
- `minimal-implement` tells workers to edit files when needed and not silently
  downgrade implementation tasks into read-only verification.
- `minimal-implement` now tells workers to start with exact named files,
  failing commands, stale text, or acceptance surfaces.
- It also tells workers not to broaden into README, PLAN, or unrelated
  directories unless those named surfaces are insufficient.
- The task prompt builder now has a `prioritizeTaskText` mode for
  `minimal-implement`, presenting `Primary requested work:` before broader
  metadata.
- Root `AGENTS.md` now includes `Recipient-Scoped Worker Focus` so ordinary
  implementation workers do not inherit broad supervisor duties by default.
- `bus-integration-task/AGENTS.md` now mirrors that guidance.

This prompt/guidance work is committed as:

```text
bus-integration-task add791c Tighten recipient worker prompt focus
root 7088b3c Checkpoint recipient worker focus guidance
```

The focused verification run for that slice was:

```bash
go -C bus-integration-task test ./pkg/devtaskintegration ./cmd/bus-integration-task
git diff --check
```

The next thread should run one new sharply scoped Spark worker proof after
this prompt-ordering change, because the final behavioral proof has not yet
been completed.

## Recent Clean Checkpoint

The last requested cleanup checkpoint committed the full current superproject
state at that moment.

Submodule commits:

```text
bus-worker 76b6ad9 Start bus-worker identity contract
bus-integration-task add791c Tighten recipient worker prompt focus
logs 8d58f54 Record Spark worker focus debugging
```

Root commit:

```text
7088b3c Checkpoint recipient worker focus guidance
```

The checkout was clean immediately after that commit.

After that checkpoint, the operator reorganized setup around
`agents/supervisor/`. That work appears to be a separate conversation goal and
may leave root changes such as `.gitmodules`, `agents/supervisor`, `docs`, and
`logs`. Do not confuse those later supervisor-root changes with the
multi-environment task/worker refactor itself. Always inspect the current Git
state before resuming.

## Known Working Commands

Use these as starting evidence, not as proof that the full goal is done.

Local task substrate:

```bash
scripts/test-local-task-events-proof.sh
```

Local host worker substrate:

```bash
scripts/test-local-host-worker-smoke.sh
```

Focused `bus-integration-task` prompt/guidance tests:

```bash
go -C bus-integration-task test ./pkg/devtaskintegration ./cmd/bus-integration-task
```

Worker identity contract tests:

```bash
go -C bus-worker test ./...
```

Task module focused tests used repeatedly:

```bash
go -C bus-task test ./run
```

Docs lint is sometimes slow or prone to `bus-lint` hangs in this environment.
When it completes, treat it as useful evidence. When it hangs, kill stale
process chains honestly and do not claim a passing lint result.

## Known Unfinished Product Work

`bus-worker` is still not a finished product. It needs:

- `bus worker list`
- `bus worker show`
- `bus worker create`
- durable worker registry storage
- worker group records
- worker status and stats
- stable operator-facing JSON/text output
- API/provider integration

`bus-integration-worker` still needs to become the clear owner of the long-lived
worker service loop. It already owns many packages, but the final product needs
one service-owned scheduler that continuously watches ready tasks, accounts for
capacity, handles stale workers, claims atomically, starts runtimes only after
claim ownership is proven, and reports clear outcomes.

`bus-integration-task` still needs slimming. It should keep task-thread
projection, task event translation, and task-specific review/reopen semantics,
but remaining worker launch and scheduler glue should continue moving to
worker-owned packages.

`bus-task` still needs polish and proof on its generic CLI contract. A concrete
known gap is subcommand-specific help for:

```bash
bus-task/bin/bus-task new --help
bus-task/bin/bus-task assign --help
```

Remote ssh-docker Spark worker execution is still operationally rough. Earlier
live runs reached remote image launch points but failed on image pull/GHCR
access. The scripts now support `--install-image`, `--build-image`, `--image`,
and `--local-tag`, but the remote proof is not complete.

Mixed local plus remote worker queue proof is not complete. Capacity behavior
across local, ssh-docker, hosted, subscription, and API-key environments still
needs a completion matrix.

The repos modules remain mostly planning and skeleton work. They should define
repo concepts, worker-home repo contracts, task-context repo contracts, and
project-link contracts without exposing Git as the primary user-facing term.

Docs and rename cleanup are improved but not finished. Remaining stale
`bus dev task`, `bus dev work`, `bus-integration-dev-task`, `BUS_DEV_TASK`, and
`bus.dev.task.*` references should be audited carefully, because some may be
legacy compatibility references while others are stale user-facing text.

## Recommended Next Steps

Start a fresh thread by inspecting current state:

```bash
git status --short
git -C bus-task status --short
git -C bus-integration-task status --short
git -C bus-integration-worker status --short
git -C bus-worker status --short
git -C docs status --short
```

Read these files first:

```text
AGENTS.md
bus-task/AGENTS.md
bus-integration-task/AGENTS.md
bus-integration-worker/AGENTS.md
bus-worker/AGENTS.md
docs/docs/goals/multi-environment-task-worker-refactor.md
logs/20260529-14-agent-memo.md
```

Then run one narrow local Spark worker proof using the updated
`minimal-implement` profile. The best next task is still the concrete
`bus-task` help gap:

```bash
BUS_LOCAL_HOST_WORKER_SMOKE_AGENT_BACKEND=codex-appserver \
BUS_LOCAL_HOST_WORKER_SMOKE_MODEL=gpt-5.3-codex-spark \
BUS_LOCAL_HOST_WORKER_SMOKE_RECIPIENT=bus-task \
BUS_LOCAL_HOST_WORKER_SMOKE_TASK_PROMPT_PROFILE=minimal-implement \
BUS_LOCAL_HOST_WORKER_SMOKE_WORKTREE=true \
BUS_LOCAL_HOST_WORKER_SMOKE_COMMIT=false \
BUS_TASK_CODEX_SANDBOX=full \
BUS_TASK_TRACE=true \
BUS_LOCAL_HOST_WORKER_SMOKE_TEXT='Run exactly `bus-task/bin/bus-task new --help` and `bus-task/bin/bus-task assign --help` first. If either command still prints the top-level help banner, implement the smallest bus-task-local fix so those subcommands print subcommand-specific help. Inspect only `cmd/bus-task/main.go`, `run/run.go`, and `run/run_test.go` first. Add focused tests and run the smallest relevant Go tests.' \
scripts/test-local-host-worker-smoke.sh
```

The success signal for this proof is that the script exits zero, `bus-task
show` includes a terminal `bus.task.done` event from the worker, the worker
closeout names the changed `bus-task` files and tests run, and the isolated
worktree contains the focused help fix rather than only a broad scan or
"nothing to change" summary.

```text
Recipient: bus-task
Profile: minimal-implement
Model: gpt-5.3-codex-spark
Sandbox: full
Worktree: true
Commit: false

Task: Run exactly `bus-task/bin/bus-task new --help` and
`bus-task/bin/bus-task assign --help` first. If either command still prints
the top-level help banner, implement the smallest recipient-local fix so those
subcommands print subcommand-specific help. Inspect only
`cmd/bus-task/main.go`, `run/run.go`, and `run/run_test.go` first. Add focused
tests and run the smallest relevant Go tests.
```

If the worker still drifts into broad README/PLAN scans, treat that as a
remaining `bus-integration-task` prompt/worker-substrate bug rather than as a
`bus-task` implementation failure.

If the worker stays focused and produces a useful diff, review it manually,
run the required checks, promote the diff into `bus-task`, commit the submodule,
and pin the root.

After the `bus-task` proof succeeds, the next strong lanes are:

1. Update `bus-integration-worker` README/docs so they no longer call the
   module a skeleton and instead describe current worker-owned packages.
2. Continue extracting remaining worker launch/scheduler glue from
   `bus-integration-task` into `bus-integration-worker`.
3. Build the minimal `bus worker` CLI around the committed identity contract.
4. Re-run local Spark proof with two parallel workers once narrow task focus is
   reliable.
5. Resume ssh-docker proof only after the local lane is producing useful work.

## Completion Criteria Still Required

The full goal should not be marked complete until current evidence proves all
of the following:

- `bus-task` is the generic multi-environment task/thread system.
- Approval, priority, blockers, assignment, and deterministic queue state work
  through tested user-facing and worker-facing paths.
- `bus-worker` owns durable worker identity and worker groups with usable CLI
  and API/provider surfaces.
- `bus-integration-worker` owns proactive worker claiming, worker-group
  routing, capacity, health/stale-worker handling, and runtime launch
  decisions.
- `bus-integration-task` is slimmed to task-specific event bridge and task
  lifecycle/review semantics.
- `bus-agent` remains the runtime/provider execution owner.
- Local, ssh-docker, hosted, ChatGPT/Codex subscription, and API-key worker
  environments can coexist in one Bus deployment.
- Local Spark workers complete real implementation tasks reliably enough to
  use for parallel development.
- Remote ssh-docker Spark workers complete at least one tiny task.
- Mixed local plus remote capacity/routing is proven.
- Docs, SDD, README, CLI help, and plan files tell the same architecture story.
- The final root checkout and touched submodules are clean and committed.

## Cautions For The Next Thread

Do not infer completion from passing package tests alone. Many package tests
prove local contracts but not the full multi-environment product behavior.

Do not spend more work on model-name normalization right now. Use
`gpt-5.3-codex-spark` exactly.

Do not turn project process into core substrate requirements. Bus Notes,
PLAN-based closeout, and reporting rituals should remain overlays unless a
specific source-backed need proves otherwise.

Do not treat a worker reaching `done` as accepted progress. Supervisor review,
diff inspection, required checks, promotion, submodule commit, and root pinning
are separate gates.

Do not block local productive work on remote image distribution, GHCR access,
or macOS `workspace-write` parity. Those are real follow-ups, but the smallest
useful lane today is local Spark with `sandbox=full`, worktrees, and manual
supervisor review/promotion.

Do not ignore root guidance being too supervisor-heavy for workers. The latest
fixes moved in the right direction, but the next live proof should decide
whether more separation is needed between supervisor identity and
recipient-worker prompts.

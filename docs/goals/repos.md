# Repos Goal

## Goal

Build the Bus repository operations surface for generic Git-backed workspace
management across multiple configured repositories.

The user-facing product name is `repos`, not `git`. Git is the implementation
technology; operators and Bus modules should think in terms of configured
repositories, branches, worktrees, and portable workspace history.

The MVP does not need to create a new Git repository for every Bus resource.
It should support one or more existing configured Git repositories and create
branches plus worktrees inside those repositories. The design must still leave
room for later `repos` features that create, clone, mirror, sync, and manage
Git repositories themselves.

## Module Boundary

The target module family is:

- `bus-repos`: user-facing product and CLI concepts.
- `bus-api-provider-repos`: API/controller provider mounted by `bus-api`.
- `bus-integration-repos`: Git-backed integration and storage behavior.

The repos family should support the worker and task systems without becoming
the task scheduler, the worker runtime owner, or the supervisor process.
It also must not become aware of worker, task, wiki, or other product-domain
semantics. Product modules own their own logical identifiers, branch naming
conventions, committed metadata files, permissions, and lifecycle decisions.
Repos owns only the generic repository, branch, worktree, status, and Git
safety mechanics.

## Required Behavior

The first useful product slice should let Bus operate on multiple configured
Git repositories. A configured repository record should include at least a
stable `repo_id`, local path or clone path, default base ref, optional remote
name, optional worktree root, and non-secret status metadata.

The first workspace operation should accept generic inputs from a caller:
`repo_id`, `branch`, `base_ref`, and a worktree name or path. Repos should
create the branch when needed, create or rematerialize the local worktree,
report deterministic status, and refuse unsafe or ambiguous states. Repos
should not derive a branch name from a worker id, task id, wiki id, or any
other product-domain object; the caller supplies the branch and owns that
meaning.

Git is the portable source of truth for workspace content and history. Local
worktree paths, runtime locks, and convenience caches are environment-local and
must be rebuildable from configured repository state plus Git refs. Do not make
PostgreSQL, an Events projection, or a single-environment JSON registry the
authoritative source of workspace identity.

Product modules may commit their own metadata files on the branches they own.
For example, a worker module may commit worker-owned metadata on a branch it
requested, and a future wiki module may commit wiki-owned content on another
branch. Repos should not inspect those files for domain meaning.

Operations should cover branch and worktree creation, lookup, status, fetch
and push planning, and conservative cleanup. They should be safe for nested
superproject and submodule checkouts: never assume a dirty nested submodule is
accidental, and never delete or reset worktrees without explicit reviewed
intent.

## Current Implementation Baseline

As of the 2026-05-30 review, the repos module family is still a skeleton:
`bus-repos`, `bus-api-provider-repos`, and `bus-integration-repos` build only
bootstrap packages and do not expose working CLI, API, registry, path
allocation, Git execution, or sync behavior yet. Their `PLAN.md` files already
split the first slices into contract types, read surfaces, registry/path
allocation, non-executing provisioning plans, and later sync/provisioning
requests.

The affected worker and task modules already carry interim repository behavior
that should become callers of generic repos primitives:

- `bus-worker` stores an optional non-secret `worker_home_ref`, but currently
  validates only that the value has no whitespace.
- `bus-api-provider-worker` and `bus-integration-worker` pass worker home
  references, branches, and worktree paths through the plural
  `bus.workers.*` control/status path. The App Server lifecycle currently
  creates worker worktrees and implementation branches directly with Git.
- `bus-integration-task` still owns task isolated worktree preparation,
  branch creation, promotion, and removal for the current task-worker bridge.
- `bus-task` contains legacy `work verify` and `work prune` worktree logic,
  including dry-run-first pruning behavior, while the detailed pruning product
  goal remains in `worktree-pruning-normal-operations.md`.

Those existing implementations are compatibility call sites and evidence
sources for the repos contract, not the final owners of generic repository
policy. This goal should migrate reusable multi-repository configuration,
branch/worktree planning, status classification, and conservative cleanup
decisions into the repos family before caller modules claim repos-owned
behavior.

## Dependencies

No other goal must be finished before the first repos implementation slices can
start. This goal is an upstream dependency for the workers and tasks goals
where they require automatic branch and worktree provisioning through Bus-owned
primitives. The same generic primitives should be reusable by future modules
that want Git-backed file workspaces, without adding their domain concepts to
repos.

Live multi-environment proof that worker and task services use those
primitives depends on the adjacent workers, tasks, Events relay, scheduler, and
systemd deployment goals. That integrated proof should not block the repos
contract and local planning slices, but this goal should not be marked fully
accepted until current caller-owned Git/worktree code is either adapted to
repos-owned primitives or explicitly documented as compatibility.

## Active Implementation Workspace

Initial implementation work started on 2026-05-31 in an isolated `bus-repos`
module worktree:

- worktree: `/private/tmp/bus-repos-workspace-mvp`
- branch: `codex/repos-workspace-mvp`
- base commit: `7647fd9e9454836425abdd146c4bcc511618f49a`
- feature commits: `92063ce` (`Implement generic repos workspace MVP`) and
  `7681148` (`Add reviewed repository refresh policy`)

Additional repos-family implementation worktrees were created on 2026-05-31:

- worktree: `/private/tmp/bus-api-provider-repos-workspace-mvp`
- branch: `codex/repos-api-workspace-mvp`
- base commit: `255f6a266b22db4a0191392c6fa1aa557c74831a`
- feature commits: `cd30d38` (`Implement repos API provider MVP`) and
  `fd5d707` (`Add repos refresh API requests`)

- worktree: `/private/tmp/bus-integration-repos-workspace-mvp`
- branch: `codex/repos-integration-workspace-mvp`
- base commit: `f1fa4da6c574894c964005999f86d2d854fe089c`
- feature commits: `3d54aa3` (`Implement repos integration MVP`) and
  `9d00ab8` (`Add repos remote rematerialization proof`) and
  `c9360de` (`Handle repos refresh events`)

Do not merge or promote these branches until the operator confirms the work.

Before continuing, merging, or promoting this feature work, verify the
workspace state explicitly:

- from the BusDK superproject checkout, check each worktree exists with
  `git -C bus-repos worktree list`,
  `git -C bus-api-provider-repos worktree list`, and
  `git -C bus-integration-repos worktree list`;
- check each feature branch exists in the matching module and maps to the
  worktree path listed above;
- run `git status --short` inside each feature worktree and review every
  modified, deleted, or untracked file before staging;
- if a `/private/tmp` worktree is missing, recreate it from the named feature
  branch if the branch still exists, or stop and recover from the module's
  main checkout before continuing;
- rerun the module checks from the feature worktrees before any merge or
  promotion.

The implementation commits described below are intentionally not merged or
promoted yet. Until the operator confirms promotion, recover the work from the
feature branches and commits listed above. The `/private/tmp` worktrees are
convenience checkouts only; they can be recreated from the named branches if
the temporary directories disappear.

Current feature-branch progress:

- `bus-repos` now has a feature-branch first CLI/package slice for multiple
  configured repositories, caller-supplied branch/base/worktree inputs,
  branch/worktree planning, ensure/status behavior, conservative branch
  mismatch handling, non-executing fetch/push planning, conservative cleanup
  planning, explicitly confirmed cleanup execution for safe reviewed
  worktrees, explicitly confirmed fetch/push execution, active-branch
  detection for branches already checked out in another worktree, non-secret
  submodule status reporting, explicit fetch refspecs for remote-tracking
  refs, non-executing maintenance planning for stale local worktree caches and
  recovery candidates, non-executing reconciliation planning for local and
  remote-tracking branch state, repository-wide remote-tracking refresh
  planning, explicitly confirmed refresh execution, README/PLAN updates, and
  focused package/CLI/e2e tests. It validates remote names as non-secret
  labels, rejects more Git-invalid refs, protects explicit worktree paths from
  option-like values, validates command usage before config loading, removes
  only the worktree while retaining the caller branch, refuses sync execution
  without confirmation, configured remotes, and a local branch for pushes,
  refuses refresh execution without confirmation or a configured remote, and
  never deletes caller branches during maintenance, reconciliation, or refresh
  planning/execution.
- `bus-api-provider-repos` now has a feature-branch library HTTP handler and
  memory projection for generic repository list/show/status/sync-status reads
  plus `plan`, `cleanup-plan`, `cleanup`, `sync-plan`, `sync`, and `ensure`
  request publication, plus `maintenance-plan` request publication for stale
  cache and recovery planning and `reconcile-plan` request publication for
  local/remote branch comparison, plus `refresh-plan` and `refresh` request
  publication for reviewed remote-tracking refresh. Cleanup, refresh, and sync
  execution requests require `confirm=true` but still do not execute Git in the
  API provider. It preserves non-secret submodule status entries from status
  snapshots and non-secret sync execution evidence from
  `bus.repos.sync.response`. `NewFileProjection(path)` can persist bounded
  list, workspace-status, and sync-status projection views across restarts
  without making that file authoritative for workspace identity. It does not
  execute Git or import worker, task, wiki, or other product-domain semantics.
- `bus-integration-repos` now has a feature-branch library Event processor for
  `bus.repos.list.request`, `bus.repos.plan.request`, and
  `bus.repos.cleanup.plan.request`, `bus.repos.cleanup.request`,
  `bus.repos.maintenance.plan.request`, `bus.repos.sync.plan.request`,
  `bus.repos.reconcile.plan.request`, `bus.repos.refresh.plan.request`,
  `bus.repos.refresh.request`, `bus.repos.sync.request`, and
  `bus.repos.ensure.request`. It delegates actual repository/worktree
  mechanics to an injected generic manager and emits list response, plan
  response, cleanup-plan response, cleanup response, maintenance-plan response,
  reconcile-plan response, refresh-plan response, refresh response, sync-plan
  response, sync response, status snapshot, or stable error Events. It also has
  a Git-backed `NewReposManager` adapter that connects those Events to the
  generic `bus-repos/pkg/repos` primitives for configured repository listing,
  branch/worktree planning, worktree materialization, cleanup planning,
  confirmed safe cleanup execution, maintenance planning, reconciliation
  planning, refresh planning, confirmed remote-tracking refresh execution, sync
  planning, confirmed fetch/push execution, status snapshots, and conservative
  branch-mismatch, branch-active, and submodule-status handling. The
  integration feature branch also proves caller-owned metadata portability by
  committing a caller file on a repos-managed branch, pushing it to a remote,
  fetching it into a fresh clone, and rematerializing the workspace from the
  fetched remote-tracking branch without using API projection or
  single-environment state as the source of truth.

Remaining dependency inside this goal: caller modules such as workers, tasks,
and future wikis still need to become callers of the generic repos
request/status contract where they currently duplicate reusable Git/worktree
policy, or those compatibility paths need to be explicitly documented before
full goal acceptance. Caller migration or explicit compatibility acceptance
remains future repos-family work. Repos should remain generic and those caller
modules should remain the owners of their domain identifiers and metadata.

## Caller Compatibility Status

The current worker and task implementations are compatibility callers rather
than final repos clients. They may keep running while the repos MVP contract is
reviewed, but their generic Git/worktree behavior should not be treated as the
long-term owner.

The worker identity path is partly metadata-only today. `bus-worker` accepts
and displays `worker_home_ref`, while `bus-api-provider-worker` and
`bus-integration-worker` pass worker home references, branches, and
`worktree_path` values through worker Events and projections. Those modules
own worker ids, labels, profiles, capability tags, prompts, environment
eligibility, and worker lifecycle metadata. A future worker migration should
translate a worker-owned identity into a generic repos workspace request:
`repo_id`, caller-chosen branch, base ref, and worktree name or path. Repos
should materialize and report the branch/worktree; worker modules should commit
worker-owned metadata files and interpret them.

The App Server worker launcher in `bus-integration-worker` still contains
direct Git worktree creation and branch reuse logic in its lifecycle executor
path. That logic is compatibility code for the worker runtime path. Its future
repos boundary should use `bus.repos.plan.request`,
`bus.repos.ensure.request`, `bus.repos.status.snapshot`, and
`bus.repos.cleanup.plan.request` instead of shelling out to worktree commands
directly. The worker module should still own process launch, model/runtime
configuration, environment selection, log paths, scratch paths, and worker
status.

The task bridge in `bus-integration-task` still owns isolated task worktree
preparation, task branch naming, task-local Git metadata repair, promotion,
and removal for the current task-worker bridge. That remains compatibility
behavior until the task bridge is wired to generic repos requests. A future
task migration should ask repos to plan, ensure, status, sync-plan, and
cleanup-plan the branch/worktree, while task modules keep owning task refs,
write scopes, closeout rules, promotion semantics, and scheduler decisions.

`bus-task work verify` and `bus-task work prune` still contain legacy
worktree verification and dry-run-first pruning behavior. Those commands are
compatibility evidence for conservative cleanup, not the final generic repos
cleanup owner. The detailed pruning product goal remains
`worktree-pruning-normal-operations.md`; this repos goal owns the generic
repository/worktree surface that pruning can later call.

This compatibility documentation does not make the caller migrations complete.
Full acceptance still requires either wiring the active caller paths to repos
or explicitly accepting these compatibility paths as temporary for the MVP
handoff. In both cases, the ownership boundary remains the same: product
modules own domain identifiers and metadata; repos owns generic repository,
branch, worktree, status, sync-planning, and safety mechanics.

## Worktree Support

Bus modules need isolated worktrees and branches. The repos surface should
provide common primitives that any module can call:

- validate a caller-supplied branch name;
- create an isolated worktree from the right repository root;
- detect dirty, locked, or active worktrees;
- report repository and submodule status;
- support later pruning/recovery flows without ad hoc `rm -rf`.

The separate `worktree-pruning-normal-operations.md` goal remains the detailed
goal for safe pruning behavior. This goal owns the broader repository/product
surface that pruning uses.

## Acceptance Criteria

This goal is accepted when:

- the repos module family has a stable first CLI/API/integration contract;
- multiple configured repositories can be listed, inspected, and selected by
  stable `repo_id`;
- branch/worktree creation works from caller-supplied generic inputs;
- status output is deterministic and script-friendly;
- dirty, locked, active, missing, and malformed repository states are handled
  conservatively;
- caller modules can use repos-owned primitives instead of duplicating generic
  repository/worktree policy;
- Git refs and committed caller-owned files, not single-environment service
  storage, are enough to recreate workspace materializations on another
  environment after clone/fetch;
- focused unit tests cover repository configuration validation, branch/worktree
  creation planning, status classification, and error reporting;
- docs and README files describe the product as `repos`, not a generic Git
  implementation detail.

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

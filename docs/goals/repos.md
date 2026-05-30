# Repos Goal

## Goal

Build the Bus repository operations surface for creating, finding, and managing
Git repositories, branches, and worktrees used by tasks and workers.

The user-facing product name is `repos`, not `git`. Git is the implementation
technology; operators should think in terms of source repositories,
worker-home repositories, task-context repositories, and shared-content
repositories.

## Module Boundary

The target module family is:

- `bus-repos`: user-facing product and CLI concepts.
- `bus-api-provider-repos`: API/controller provider mounted by `bus-api`.
- `bus-integration-repos`: Git-backed integration and storage behavior.

The repos family should support the worker and task systems without becoming
the task scheduler, the worker runtime owner, or the supervisor process.

## Required Behavior

The first useful product slice should let Bus create and manage repository
records with stable non-secret logical references such as:

```text
repos://workers/<worker-id>
repos://tasks/<task-id>
```

Repository records should distinguish at least:

- `source`: the canonical project checkout;
- `worker-home`: a worker-owned home/work directory;
- `task-context`: a task-specific worktree or checkout;
- `shared-content`: shared material mounted or copied into worker context.

Operations should cover branch and worktree creation, lookup, status, and
cleanup. They should be safe for nested superproject and submodule checkouts:
never assume a dirty nested submodule is accidental, and never delete or reset
worktrees without explicit reviewed intent.

## Worktree Support

Workers need isolated worktrees and implementation branches. The repos surface
should provide the common primitives that the workers product can call:

- choose or create a branch name;
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
- repository kind and logical-ref semantics are documented and tested;
- branch/worktree creation works for worker and task callers;
- status output is deterministic and script-friendly;
- dirty, locked, active, missing, and malformed repository states are handled
  conservatively;
- worker and task modules call repos-owned primitives instead of duplicating
  repository/worktree policy;
- focused unit tests cover repository kind validation, worktree creation
  planning, status classification, and error reporting;
- docs and README files describe the product as `repos`, not a generic Git
  implementation detail.

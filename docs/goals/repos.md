# Repos Goal

## Goal

Build the first Bus repository workspace surface for preconfigured local Git
repositories.

The MVP does not create or clone repositories. It supports one or more
operator-configured Git repositories and lets caller modules request a
caller-owned branch plus worktree inside one of those repositories. This gives
future Workers, Wikis, Tasks, and other file-backed modules a common Bus
surface without making repos aware of their domain concepts.

The design must still leave room for later repository creation, clone,
mirror, sync, cleanup, and remote-management features. Those are future repos
features, not part of the first implementation slice.

## Module Boundary

The repos module family has these boundaries:

- `bus-repos` is the API client and shared Go contract library.
- `bus-api-provider-repos` is the HTTP/controller layer that publishes and
  projects `bus.repos.*` Events.
- `bus-integration-repos` owns all repository configuration, persistent
  integration state, and Git/worktree mechanics.

`bus-repos` must not execute Git, load repository configuration, store
repository state, or expose a CLI for the MVP. It should be safe for caller
modules to import as a lightweight shared library.

`bus-api-provider-repos` must not execute Git or become authoritative for
repository configuration. It validates HTTP requests, publishes Bus Events,
and serves read-side projections.

`bus-integration-repos` owns the durable backing model for this MVP:
preconfigured repository records with a stable `repo_id`, local repository
path, default base ref, optional remote name, optional worktree root, and
optional environment id. Its storage/configuration can be changed later, but
state ownership must remain behind this integration boundary.

Repos must not know about Workers, Tasks, Wikis, or any other product-domain
resource. Caller modules own logical identifiers, branch naming conventions,
metadata files committed on their branches, permissions, lifecycle policy, and
merge/promotion decisions. Repos owns only generic repository, branch,
worktree, and status mechanics.

## MVP Behavior

The first implementation supports:

- listing preconfigured repositories;
- planning a branch/worktree request without mutation;
- ensuring a caller-supplied branch and worktree exist;
- reporting projected branch/worktree status;
- rejecting malformed, ambiguous, active, or mismatched worktree states
  conservatively.

The caller supplies `repo_id`, `branch`, optional `base_ref`, and either a
worktree name or explicit worktree path. Repos must not derive branch names
from worker ids, task ids, wiki ids, or any other domain object.

Git refs and committed caller-owned files are the portable source of truth for
workspace contents. Local paths and runtime projections are environment-local
and must be rebuildable from configured repository state plus Git refs. Do not
make PostgreSQL, an Events projection, or a single-environment JSON registry
the authoritative source of workspace identity.

## Current Implementation Workspace

Initial feature work was created on 2026-05-31 in temporary worktrees:

- `/private/tmp/bus-repos-workspace-mvp` on
  `codex/repos-workspace-mvp`
- `/private/tmp/bus-api-provider-repos-workspace-mvp` on
  `codex/repos-api-workspace-mvp`
- `/private/tmp/bus-integration-repos-workspace-mvp` on
  `codex/repos-integration-workspace-mvp`

The operator then confirmed promotion into the local module branches:

- `bus-repos`: `1-bus-repos`
- `bus-api-provider-repos`: `1-bus-api-provider-repos`
- `bus-integration-repos`: `1-bus-integration-repos`

After review, the operator corrected the architecture: the first version must
not put Git execution or repository state into `bus-repos`, and it must not
put persistent repository ownership into the API provider. Corrective work is
being done directly on the local `1-*` module branches.

## Implemented Slice

The corrected implementation slice should contain:

- `bus-repos`: library-only shared client/contract for list, plan, ensure,
  and status reads.
- `bus-api-provider-repos`: HTTP controller and bounded projection for list,
  show, status, plan, and ensure routes; no Git execution and no repository
  configuration authority.
- `bus-integration-repos`: Event processor plus Git-backed manager for
  preconfigured repositories, branch/worktree planning, worktree creation,
  and status snapshots.

Cleanup, sync, refresh, reconciliation, repository creation, cloning,
mirroring, pruning, and repository-wide maintenance remain future work.

## Caller Compatibility

Worker and task modules currently contain compatibility Git/worktree behavior.
Those modules may keep running while the repos MVP contract is reviewed, but
they should later become callers of the generic repos Events where they
currently duplicate repository/worktree policy.

The relevant compatibility owners reviewed on 2026-05-31 are:

- `bus-worker` stores worker-owned metadata such as `WorkerHomeRef`.
- `bus-api-provider-worker` and `bus-integration-worker` pass worker home
  refs, branches, and worktree paths through worker Events and projections.
- `bus-integration-worker` still shells out for App Server worker worktree
  creation in its lifecycle executor path.
- `bus-integration-task` still owns isolated task worktree preparation,
  branch naming, promotion, and removal.
- `bus-task` still has legacy worktree verification and dry-run-first pruning
  commands.

Those paths are temporary compatibility evidence, not final ownership. Caller
modules must continue to own their own domain ids and metadata; repos remains
generic.

## Dependencies

No other goal must be completed before the initial repos MVP can be accepted.
This goal is an upstream dependency for Workers, Tasks, Wikis, and future
file-backed modules that want Bus-managed branch/worktree materialization.

Integrated proof that Workers or Tasks use repos can be completed in later
caller-module goals. That proof should not block the corrected repos MVP as
long as the compatibility state is documented.

## Acceptance Criteria

This goal is accepted when:

- `bus-repos` is an API client/shared library only;
- `bus-api-provider-repos` is only the HTTP/Event controller and projection;
- `bus-integration-repos` owns preconfigured repository state and Git
  worktree mechanics;
- multiple preconfigured repositories can be listed and selected by
  `repo_id`;
- branch/worktree planning and creation work from caller-supplied generic
  inputs;
- status output is deterministic and non-secret;
- malformed, ambiguous, active, missing, and mismatched worktree states are
  handled conservatively;
- focused tests cover configuration validation, planning, ensure/status, and
  API/Event error reporting;
- docs clearly mark cleanup, sync, refresh, reconcile, repository creation,
  clone, mirror, and maintenance behavior as future work.

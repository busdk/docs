# Worktree Pruning Normal Operations Handoff

## Goal

This conversation thread defined the product goal for normal operational
worktree pruning in Bus development workflows.

The target capability is:

> Worktree pruning in normal operations: the pruner defaults to dry-run,
> detects active, locked, and dirty root and submodule worktrees, and can
> reclaim obsolete finished worktrees after review.

The owning module is `bus-dev`, because the user-facing workflow is
`bus dev work prune`. The durable plan entry is in `bus-dev/PLAN.md` under:

```text
Make `bus dev work prune` safe for normal operations on large superproject
checkouts.
```

This handoff exists so another conversation can resume the goal without
needing the original chat.

## Why This Matters

The triggering incident was disk pressure in a large BusDK superproject
checkout. On 2026-05-27, the supervisor ran:

```bash
bus dev work prune --dry-run
```

from the BusDK superproject. The command produced no visible output for more
than 25 seconds before being stopped. A cleanup command that appears hung is
not safe enough for normal disk-recovery operations, especially when it may
eventually remove worker worktrees.

The operator wants this to become a normal, reviewable maintenance workflow,
not an ad hoc `rm -rf` cleanup. The command must make it obvious what it is
looking at, what it will retain, what it could remove, and why.

## Current Plan State

`bus-dev/PLAN.md` now defines the goal as follows:

```text
operators can run `bus dev work prune` routinely for disk recovery: it defaults
to dry-run review, emits prompt progress, detects active, locked, and dirty
root/submodule worker worktrees, and only reclaims obsolete finished worktrees
after explicit review.
```

The plan requires the command to:

- default to dry-run review;
- require explicit `--apply` for removal;
- emit prompt initial progress before Events replay or registry traversal can
  appear hung;
- scan root and initialized submodule Git worktree registries in bounded form;
- classify every candidate with stable action and reason fields;
- retain active, dirty, locked, unknown, and no-visible-stream worktrees;
- remove only clean terminal candidates after review;
- use Git worktree commands rather than direct filesystem deletion.

The plan item is intentionally still unchecked. The previous thread completed
the planning layer, not the implementation.

## Baseline Evidence And Caveat

The planning conversation recorded an earlier baseline where pruning behavior
was understood to already default to dry-run, require explicit `--apply`, scan
root and initialized submodule worktree registries, refuse explicitly requested
active refs, and use `git worktree remove` / `git worktree prune` rather than
ad hoc deletion.

Before implementing, verify that baseline in the current checkout. On
2026-05-29, a quick source search in this workspace found the pruning contract
in `bus-dev/PLAN.md`, but did not find matching `work prune` implementation
symbols in `bus-dev/run/*.go`. That may mean the code moved, the current
checkout is on a later or different submodule commit, or the plan is ahead of
the implementation. Do not assume the implementation exists until source has
been audited.

Relevant current commits observed during this handoff:

- superproject: `7088b3ca0375a3f3e7218d399ceba7249ee7db01`
- `bus-dev`: `1eb6e2189f744350d5714a685c5f39187d78d822`

The root checkout was already dirty when this handoff was written, including
unrelated `.gitmodules`, `agents/supervisor`, `docs`, and `logs` state. Do not
revert unrelated changes.

## Required Product Behavior

The command should be safe to run first as:

```bash
bus dev work prune
```

or explicitly as:

```bash
bus dev work prune --dry-run
```

Both forms should be non-destructive. The command should print an initial
summary or progress line promptly so the operator knows it is alive and which
repositories or registries it is inspecting.

Registry discovery must cover both the root repository and initialized
submodule repositories. Large superprojects must not cause unbounded silent
walks. Uninitialized, inaccessible, malformed, or otherwise suspicious
submodule registries should become retained or diagnostic rows in the report
instead of blocking the whole run.

Every candidate should have stable fields. The planned output contract is:

- registry;
- path;
- branch;
- work ref;
- task status;
- last event or age when available;
- dirty flag;
- lock flag;
- reason;
- planned action.

Text output should be useful for human review. JSON output should be stable
enough for scripts and tests.

## Candidate Classification

The next implementation should classify candidates at least as:

- primary checkout;
- active;
- recent terminal;
- terminal clean;
- dirty;
- locked;
- unknown or no visible stream;
- prunable registry entry.

The exact enum names can follow existing `bus-dev` style, but the distinctions
must remain visible in both dry-run output and tests.

`recent terminal` means a terminal task worktree whose last terminal task
Event is inside a named grace window. Use a documented `bus-dev` constant or
configuration source for this value; if no existing owner exists, start with a
24-hour default and print that threshold in dry-run diagnostics.

## Retention Rules

The pruner must retain any worktree that is active, dirty, locked, unknown, or
not safely connected to visible terminal task evidence.

Active work should be detected from visible task Events, worker/container
evidence, recent heartbeat evidence, and explicit refs supplied by the
operator. `--apply` must refuse active candidates.

Dirty worktree detection should include tracked and untracked changes.
Detection must work for task worktrees in both root and submodule registries.
Dirty worktrees must be retained.

Locked worktree detection should treat Git lock and in-progress operation
state conservatively. At minimum, check for lock files and states associated
with index operations, merge, rebase, bisect, or cherry-pick. Locked or
in-progress worktrees must be retained.

Unknown or no-visible-stream worktrees must be retained unless there is a
separate explicit, reviewed recovery mode. That recovery mode was not part of
this planning goal.

## Apply Rules

Destructive cleanup must require:

```bash
bus dev work prune --apply
```

`--apply` should remove only clean terminal candidates from the reviewed
candidate set. It must continue to use Git worktree commands, such as
`git worktree remove` and `git worktree prune`, rather than direct filesystem
deletion.

If a candidate changes state between dry-run review and apply, the command
should prefer retention or refusal over removal. Any state transition that
makes the candidate active, dirty, locked, unknown, or otherwise ambiguous
should block removal and explain why.

## Verification Expected

The `bus-dev/PLAN.md` item names these focused verification requirements:

```bash
go -C bus-dev test ./run -run 'Prune|Worktree'
go -C bus-dev test ./run
bus lint bus-dev/run/work_verify.go bus-dev/run/run_test.go
```

Adjust the lint paths if the implementation files differ in the current
checkout.

Fixture or unit tests should cover:

- root worktree registry scanning;
- initialized submodule worktree registry scanning;
- active task retention;
- recent terminal grace retention;
- clean terminal candidate reporting;
- dirty tracked change retention;
- dirty untracked file retention;
- Git lock or in-progress operation retention;
- unknown or no-visible-stream retention;
- explicit active-ref refusal;
- `--apply` removal only for clean terminal candidates.

Output tests should cover both text and JSON forms, including progress,
candidate fields, reason strings, and action strings.

A bounded smoke should prove that `bus dev work prune --dry-run` prints its
first status or progress line promptly on the BusDK superproject.

## Suggested Implementation Order

Start by auditing current `bus-dev` source for existing prune command support.
If the command is missing, add the command surface first with dry-run as the
default and `--apply` as the only destructive mode.

Next, implement candidate discovery and classification without deletion. This
should produce the full report while retaining everything except clean terminal
candidates marked as would-remove in dry-run.

Then add dirty and locked detection. Keep this conservative. False retention is
acceptable; false removal is not.

After the dry-run report and tests are stable, add `--apply`. Recompute or
validate candidate state at apply time so stale dry-run assumptions cannot
delete newly active or dirty work.

Finally, run the focused gates and the superproject smoke. If the smoke is too
expensive for normal CI, keep it as a documented local verification command
and preserve deterministic unit coverage for the core behavior.

## Files To Read First

Start with:

```bash
sed -n '95,155p' bus-dev/PLAN.md
sed -n '1,180p' bus-dev/AGENTS.md
rg -n "prune|worktree" bus-dev
```

Then identify the actual command implementation files in the current checkout.
Older planning notes referenced `bus-dev/run/work_verify.go`, but this
2026-05-29 checkout only has `bus-dev/run/config.go`, `bus-dev/run/run.go`,
and `bus-dev/run/run_test.go`. Treat the current checkout as authoritative.

## Work Boundaries

Keep implementation scoped to `bus-dev` unless source audit proves another
module owns the task event replay, worker evidence, or Git worktree primitive
needed by the pruner.

Do not implement cleanup by shelling out to broad deletion commands or by
walking ignored temporary directories directly. The desired behavior is a
reviewable Bus command that uses Git worktree operations and Bus task evidence.

Do not make the superproject root responsible for the implementation. The root
may hold a submodule pin after the `bus-dev` work is accepted, but the command
belongs in `bus-dev`.

## Current Handoff Status

Complete:

- the goal has been defined in durable form;
- the `bus-dev/PLAN.md` item has concrete required behavior and verification;
- this handoff captures the operator intent and the current caveat that source
  baseline must be re-audited.

Incomplete:

- implementation has not been completed in this thread;
- no prune runtime tests were run in this thread;
- the exact current source owner for the prune command still needs audit;
- no commit was requested for this handoff.

The next thread should begin with source audit, then either implement the
missing command or extend the existing implementation to match the plan.

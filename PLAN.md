# Docs Refactor Plan

Status: completed archive. New documentation work should be opened as fresh
items in the owning module `PLAN.md`; UI implementation roadmap work now lives
in the relevant `bus-gx`, `bus-ui`, or infrastructure module plan.

Current unchecked items use paths relative to the `docs` module root unless an
item explicitly names a superproject command such as `make -C docs quality`.
Older checked entries may preserve the superproject-relative paths and commands
that were used when those entries were completed.

## Current Goal: Bus Engine Product Documentation

## Current Goal: Codex Fork / Bus Agent Runtime Parity

`docs/docs/goals/codex-fork.md` owns the public cross-module goal for the
Bus-owned Go implementation of the headless Codex App Server worker-runtime
surface. The completed worker-provider bridge made `bus-agent-runtime`
available through `bus workers` as `runner_kind=appserver` /
`runner_provider=bus-agent-runtime` beside the existing Codex providers.

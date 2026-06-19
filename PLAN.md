# Docs Refactor Plan

Status: completed archive. New documentation work should be opened as fresh
items in the owning module `PLAN.md`; UI implementation roadmap work now lives
in the relevant `bus-gx`, `bus-ui`, or infrastructure module plan.

Current unchecked items use paths relative to the `docs` module root unless an
item explicitly names a superproject command such as `make -C docs quality`.
Older checked entries may preserve the superproject-relative paths and commands
that were used when those entries were completed.

## Current Goal: Codex Fork / Bus Agent Runtime Parity

`docs/docs/goals/codex-fork.md` owns the public cross-module goal for the
Bus-owned Go implementation of the headless Codex App Server worker-runtime
surface. The completed worker-provider bridge made `bus-agent-runtime`
available through `bus workers` as `runner_kind=appserver` /
`runner_provider=bus-agent-runtime` beside the existing Codex providers.

- [ ] Keep the Bus-owned runtime worker goal and public docs aligned with the
  implementation modules.
  - Goal: the goal file, module docs, and public user-facing docs must reflect
    the accepted provider contract, self-hosted GPU defaulting behavior,
    configuration boundary, and non-goals.
  - Scope:
    - keep implementation work tracked in the owning module `PLAN.md` files
      while this module owns the public goal and final user documentation
    - document that `bus-agent-runtime` is an additional provider, not a
      replacement for explicit `codex-direct`
    - avoid exposing secrets, raw provider URLs with credentials, token-file
      paths, private host paths, or ChatGPT subscription flows
    - update the public docs only after implementation behavior is verified
  - Verification: goal checklist reconciled against module `PLAN.md` files,
    changed Markdown linted with the available docs checks, and product-path
    proof linked or summarized without sensitive values.

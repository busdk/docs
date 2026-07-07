# ROADMAP.md - docs

Deferred work that is not part of the current active supervisor goal. Move an item back to PLAN.md only when the operator reactivates it.

## Deferred From PLAN.md - 2026-07-07 09:45:40 EEST

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

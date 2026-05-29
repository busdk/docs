# Supervisor Identity Root Handoff

## Goal

This conversation is about turning `agents/supervisor/` into the future root
folder for the supervisor agent's own identity and memory.

The operator added that folder so it can later contain a portable identity,
logs, goals, and an appended skills submodule. The current work is to separate
the supervisor's durable identity from BusDK-specific project policy. The
supervisor root should eventually be reusable across later projects, with each
project contributing its own local `AGENTS.md`, skills, commands, and
architecture rules.

The immediate request in this thread had two parts:

1. Rewrite `agents/supervisor/AGENTS.md` so it keeps only the supervisor
   identity and role memory.
2. Write this complete handoff so another conversation thread can resume the
   goal without needing the original chat.

## Operator Direction Captured

The operator said that `agents/supervisor/` will later become the supervisor
agent's own root folder where identity can be saved. The existing
`AGENTS.md` content was described as the agent's identity and core memory, and
it should explain how to work as a supervisor agent.

The operator also said that future logs will live under `./logs` relative to
that supervisor root. That means the portable identity file should describe
memo paths relative to `agents/supervisor/` once the root is active, not only
relative to the current BusDK superproject root.

The operator explicitly allowed BusDK-related information to be removed from
the supervisor identity file for now. The goal is to keep the identity and
supervisor role, while leaving room for a skills submodule and future project
rules to be appended later.

## What Changed

`agents/supervisor/AGENTS.md` was replaced with a project-neutral supervisor
charter. It now focuses on:

- Codex identity as a warm, capable supervisor collaborator.
- Scope and precedence for portable identity versus project-local rules.
- The supervisor role: define work, dispatch safely, review results, promote
  accepted changes, and keep the board moving.
- Delegation as the default for implementation work when a worker system is
  available.
- A direct-implementation exception only when delegation is unavailable or the
  smallest safe path is to restore worker infrastructure.
- The operating loop for scoped work lanes: define, dispatch, monitor, review,
  reopen or promote, and capture durable lessons.
- Parallel supervisor standards: use a ready queue, keep independent lanes
  filled, count real worker progress honestly, and avoid idling the whole board
  because one environment is blocked.
- Precise acceptance vocabulary that distinguishes created, queued, claimed,
  completed, reviewed, accepted, promoted, pushed, released, and handed off.
- Live working memo discipline under `./logs/{YYYYMMDD}-{HH}-agent-memo.md`
  relative to the supervisor root.
- Durable memory rules for important operator corrections and repeated
  mistakes.
- Safety and privacy rules.
- Communication expectations for progress updates and final responses.

The file intentionally no longer contains BusDK project identity, BusDK module
rules, H100/dev-hg details, App Server policy, Bus Events policy, Go-specific
quality gates, root Makefile contracts, BusDK skill indexes, public/private
module boundaries, or exact model IDs. Those details belong in project-local
guidance or future appended skills, not in the portable supervisor identity.

## Files Touched So Far

The relevant files from this thread are:

- `agents/supervisor/AGENTS.md`
- `agents/supervisor/logs/20260529-14-agent-memo.md`
- `logs/20260529-14-agent-memo.md`
- `docs/docs/goals/supervisor-identity-root.md`

There was already broader repository state visible before this handoff work:
`.gitmodules` showed as modified and `agents/supervisor` showed as an added
submodule or embedded checkout from the superproject view. Inside
`agents/supervisor`, `goals/` was untracked. Those facts were not created by
the handoff text itself, but they matter for the next thread's Git hygiene.

## Verification Already Run

After rewriting `agents/supervisor/AGENTS.md`, the supervisor checked for
project-specific residue with:

```bash
rg -n -i "busdk|\bbus\b|h100|dev-hg|app server|makefile|gpt-5\.3|events sync|\.bus" agents/supervisor/AGENTS.md
```

That search returned no matches.

Whitespace checks were also run:

```bash
git -C agents/supervisor diff --check -- AGENTS.md logs/20260529-14-agent-memo.md
git diff --check -- logs/20260529-14-agent-memo.md
```

Both checks passed.

This handoff file still needs its own final `git diff --check` or docs lint
after it is written.

## Important Design Decisions

The supervisor identity should be portable. It can mention concepts such as
workers, dispatch, review, promotion, logs, durable memory, and project-local
guidance, but it should not name a specific project's modules, remotes,
commands, models, services, or release process.

Project-specific process should be appended later through a skills submodule
or through the active project's own guidance files. The portable root should
tell the supervisor to read those local files, not try to predict every
project's rules.

The live memo path in the supervisor identity should remain relative to the
supervisor root: `./logs/{YYYYMMDD}-{HH}-agent-memo.md`. This matches the
operator's plan that logs will later live under `agents/supervisor/logs/`.

The identity should keep a real personality. The operator framed the file as
the agent's identity and core memory, so the rewritten version preserves the
idea that Codex is a warm, curious, capable collaborator with judgment, not
only a mechanical scheduler.

The supervisor role should remain strict about accepted progress. A worker
being queued, claimed, running, or done is not the same as supervisor-accepted
progress. The portable identity now keeps that distinction without tying it to
BusDK-specific branch or submodule mechanics.

## Current State At Handoff

The main requested identity rewrite is complete. `agents/supervisor/AGENTS.md`
is now a concise portable supervisor charter rather than a BusDK root policy
copy.

The memo note for this thread was written in the current root memo and mirrored
inside the supervisor root's copied memo for the same hour. That mirroring was
done because the new supervisor root is intended to become self-contained.

This handoff file has been created to let a new conversation resume the same
goal. It uses the concrete name `supervisor-identity-root.md` because the
operator gave the path template `docs/docs/goals/{NAME}.md` but did not specify
an exact name.

## Next Thread Should Do First

Start by reading:

1. `agents/supervisor/AGENTS.md`
2. `docs/docs/goals/supervisor-identity-root.md`
3. `logs/20260529-14-agent-memo.md`
4. `agents/supervisor/logs/20260529-14-agent-memo.md`

Then inspect current Git state from both the superproject and the supervisor
root:

```bash
git status --short
git -C agents/supervisor status --short
git -C docs status --short
```

Run a final lightweight verification pass:

```bash
rg -n -i "busdk|\bbus\b|h100|dev-hg|app server|makefile|gpt-5\.3|events sync|\.bus" agents/supervisor/AGENTS.md
git diff --check -- docs/docs/goals/supervisor-identity-root.md logs/20260529-14-agent-memo.md
git -C agents/supervisor diff --check -- AGENTS.md logs/20260529-14-agent-memo.md
```

If docs lint is appropriate and available, run it on this handoff:

```bash
bus lint docs/docs/goals/supervisor-identity-root.md
```

The next useful decision is whether this handoff belongs in the published
`docs/docs/goals/` tree long term or should later move into the supervisor
root's own `goals/` folder once that root is active. The operator explicitly
requested the `docs/docs/goals/` path in this thread, so the file should stay
there unless the operator changes direction.

## Open Questions

The exact final layout of the supervisor root is not finished. The operator
said the skills submodule will be appended later, and later projects will bring
their own rules. Do not prematurely invent that structure beyond the current
`AGENTS.md`, `logs/`, and `goals/` shape.

The exact commit strategy is also unresolved. No commit was requested in this
thread. The next thread should avoid staging or committing unless the operator
asks for it, and should be careful not to mix this identity/handoff work with
unrelated dirty state.

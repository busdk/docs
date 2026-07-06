# Worker Template Model Selection

Question: How should Bus Worker operators choose Codex and Claude worker
templates, and how should a deep-research workflow split work across models?

Date: 2026-07-06

Sources:
- https://developers.openai.com/codex/codex-manual.md
- https://platform.claude.com/docs/en/about-claude/models/overview
- Local Bus worker capabilities: `docs/docs/research/bus-worker-capabilities.md`
- Local Claude worker backend notes: `docs/docs/research/claude-worker-backend.md`
- Local template catalog: `.bus/worker/templates.json`

## Findings

### Codex templates

The Codex manual describes `gpt-5.5` as the strongest option for complex
coding, computer-use, knowledge-work, and research workflows; `gpt-5.4-mini`
as the faster/lower-cost option for lighter coding and subagent work; and
`gpt-5.3-codex-spark` as a near-instant research-preview model for real-time
iteration. Bus-specific evidence also matters: Codex workers have Bus App
Server thread/turn state and goal-tool support, which makes strong Codex
profiles useful as sub-supervisors for Codex worker lanes.

Practical mapping:

- `codex-53-spark`: fast scout or small-fix worker.
- `codex-54-mini`: lower-cost helper for bounded implementation, scans, and
  log work.
- `codex-55`: default implementation and review worker.
- `codex-55-high`: hard root-cause, cross-module, security/review, and
  sub-supervisor worker.

### Claude templates

Anthropic's model overview positions Claude Fable 5 as the highest-capability
widely released Claude model for long-running agents, Opus 4.8 for complex
agentic coding and enterprise work, Sonnet 5 as the speed/intelligence balance,
and Haiku 4.5 as the fastest near-frontier Claude option.

Practical mapping:

- `claude-fable-5`: deep-research lead, final synthesis, architecture, and
  difficult review.
- `claude-opus-4-8`: high-quality second opinion, architecture review, and
  complex agentic coding.
- `claude-sonnet-5`: balanced implementation/research follow-through.
- `claude-haiku-4-5`: cheap parallel extraction, log triage, source finding,
  and first-pass research.

## Deep-Research Profile

For Bus Worker operators, "deep research" is a workflow profile rather than a
single runnable template id. Use this split unless a task is small enough for
one worker:

1. Lead/synthesis: create one `claude-fable-5` worker. It owns the research
   question, source quality, final findings, and "how this applies to us".
2. Extraction: use `claude-haiku-4-5` workers for parallel source extraction,
   log summarization, and quote/evidence collection.
3. Implementation follow-through: use `claude-sonnet-5` or `codex-55` for
   practical code/documentation changes from accepted findings.
4. Verification/review: use `codex-55-high` when the work needs Bus goal
   tooling, source-level debugging, and Codex-worker supervision; use
   `claude-opus-4-8` for an independent high-quality architecture or review
   opinion.

Keep the source discipline from the supervisor research loop: use approved
authoritative domains only, save reusable findings under `docs/docs/research/`,
and link the note from the nearest `AGENTS.md`. Do not treat a fast extraction
worker's answer as the final synthesis unless the lead worker has reviewed it.

## How This Applies To Us

`.bus/worker/templates.json` should carry short `summary` strings for quick
selection and longer `description` strings for operator guidance. The exact
model ids, runner providers, reasoning settings, and sandbox settings remain
environment-local template policy. Worker briefs should request a capability
or workflow profile, then select one of the active template ids discovered by
`bus workers template list`.

Misapplication warning: do not create a new template id such as
`claude-deep-research` unless the corresponding worker identity repo and
runtime policy exist. Until then, deep research is an operator workflow that
usually starts with `claude-fable-5` and fans out to cheaper extraction lanes.

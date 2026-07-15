# Worker Template Model Selection

Question: How should Bus Worker operators choose Codex and Claude worker
templates, and how should a deep-research workflow split work across models?

Date: 2026-07-06
Revised: 2026-07-15, to make the dated 2026-07-15 19:00 UTC local evidence the
controlling recommendation and to move vendor-reported model descriptions
into a separately attributed context section.

Sources:
- Local evidence report (controlling):
  [Bus worker model performance, June–July 2026](../reports/2026-07-15-bus-worker-model-performance)
- Local Bus worker capabilities: `docs/docs/research/bus-worker-capabilities.md`
- Local Claude worker backend notes: `docs/docs/research/claude-worker-backend.md`
- Local template catalog: `.bus/worker/templates.json`
- External vendor context only (see "Vendor-Reported Model Descriptions"
  below): https://developers.openai.com/codex/codex-manual.md,
  https://platform.claude.com/docs/en/about-claude/models/overview

## Current Recommendation (evidence-driven, 2026-07-15 baseline)

This is the operative mapping. It supersedes any routing choice implied by
vendor documentation alone. It is derived from the audited 2026-06-15 through
2026-07-15 19:00 UTC window of Bus Worker, Task, Thread, and memo evidence in
the [performance report](../reports/2026-07-15-bus-worker-model-performance),
which is dated local evidence from this operating environment, not a
universal model ranking.

- **Complex implementation:** GPT-5.6 Terra High — strongest evidenced record
  for difficult, review-driven implementation reaching push/pin/install/
  live-smoke outcomes. First green candidates still require independent
  review before acceptance.
- **Bounded/mechanical implementation:** historical GPT-5.4 Mini and GPT-5.5
  work, often with unknown effort, and the Spark family produced useful bounded
  work. The exact current GPT-5.4 Mini low and GPT-5.5 medium settings each
  have 35% setting-specific support and no separately attributable accepted
  result; try them only on narrowly frozen work with independent review, never
  advertise them as validated defaults. Claude Sonnet 5 medium has direct
  accepted bounded evidence. Current Spark low is a fast bounded candidate
  with relevant but incomplete direct evidence and is never the sole
  acceptance owner.
- **Root-cause and architecture diagnosis:** GPT-5.6 Sol XHigh — strongest
  evidence for cross-module root-cause tracing and architecture/
  ownership-boundary design.
- **Adversarial review, matched to the risk domain:**
  - GPT-5.6 Sol Max: concurrency, replay, process, and exact-contract
    invariants.
  - GPT-5.6 Luna Max: convergence and ordering.
  - GPT-5.6 Terra Max: lifecycle and security-boundary review.
  - Claude Fable 5: architecture, supply-chain, and exact-byte contract
    challenge.
- **Docs and bounded diagnosis:** GPT-5.6 Luna Low — reliable and
  cost-appropriate for narrow documentation, source-backed infrastructure
  diagnosis, and smoke verification. No evidence supports low reasoning for
  the hardest implementation/review work.
- **High-effort managers do not self-accept:** a GPT-5.6 Sol Ultra manager
  produced a sophisticated, green candidate that fresh independent Sol Max
  review still rejected. Higher-effort managers own decomposition and
  candidate production; a separately assigned reviewer owns the verdict.
- **Evidence-limited settings — treat as unproven, not validated:** GPT-5.6
  Terra Medium, GPT-5.6 Luna Medium, GPT-5.4 Mini at low reasoning, and
  GPT-5.5 medium as a standalone current-template row each had thin or
  unattributable evidence in the audited window.
- **Claude Opus 4.8 is restricted, not a default second opinion or complex
  agentic coding profile:** the one audited high-reasoning Opus run produced a
  technically valuable root-cause fix but violated execution scope in a
  shared Docker runtime and required quarantine and independent proof. Opus
  is limited to:
  - read-only consultation (review, second opinion, architecture comment
    with no write/execute access), or
  - tightly isolated, externally bounded execution with an exact stop
    condition defined up front and independent proof collected after the
    run.
  Opus is expressly prohibited from: unattended work in a container or any
  shared runtime, destructive cleanup, background builds, and repeated or
  standing heavy-authority assignments (e.g. default reviewer, default
  sub-supervisor, or recurring unattended lane owner).
- **Claude Haiku 4.5 cannot solely own a required evidence gate:** its only
  audited deterministic-verification assignment produced no command or
  evidence before being stopped. One run is too small to characterize the
  model broadly, but a single Haiku run must not be trusted as the sole
  evidence source for a verification gate — pair it with an independent
  confirmation step or a fallback executor.
- **Model quality vs. execution substrate are separate axes:** the report
  explicitly separates model-quality outcomes from execution-substrate
  failures (quota exhaustion, Repos materialization, missing runtime refs,
  stale worktrees, App Server reachability). Do not read a stopped/failed/
  no-output Worker row as a model judgment without first checking whether the
  cause was substrate rather than the model.
- **Fresh heterogeneous review/relay is the effective unit of work:** the
  most reliable observed pattern was implementer → independent, risk-matched
  reviewer → focused repair → fresh review/composed proof, rather than one
  model implementing, reviewing itself, and closing every gate. When
  Codex-side quota blocked a review lane (for example Luna Max and GPT-5.5
  high hitting the same account quota), Claude Sonnet 5 served as an
  effective independent review fallback — prefer provider-diverse capacity
  over idling a blocked lane.

Match the model/effort to the work type and risk domain first, then use this
evidence to prefer or discount a specific profile within that shape. Do not
fall back to the vendor-described defaults below when they conflict with this
section.

## Deep-Research Profile

For Bus Worker operators, "deep research" is a workflow profile rather than a
single runnable template id. Use this split unless a task is small enough for
one worker:

1. Lead/synthesis: select the owner from the current risk-domain
   recommendation. The dated local audit establishes no single generic
   deep-research default; Fable remains evidenced for architecture,
   supply-chain, exact-byte, and specification review.
2. Extraction: use `claude-haiku-4-5` workers for parallel source extraction,
   log summarization, and quote/evidence collection. Because Haiku cannot
   solely own a required evidence gate (see above), any extraction result
   feeding an acceptance decision needs independent confirmation from the
   lead worker or a fallback executor before it is treated as evidence.
3. Implementation follow-through: historical Mini/GPT-5.5 and Spark-family
   evidence supports narrowly framed practical code/documentation changes.
   Exact current Mini low, GPT-5.5 medium, and Spark low may be tried only on
   narrowly frozen work with independent review; they are not validated
   defaults, and Spark low is never the sole acceptance owner. Sonnet medium
   has direct accepted bounded evidence; use GPT-5.6 Terra High for complex,
   review-driven implementation.
4. Verification/review: match the reviewer to the risk domain per the
   Current Recommendation (Sol Max / Luna Max / Terra Max / Fable 5 / Sol
   XHigh). Do not assign Opus as a default second opinion — use it only for
   read-only consultation or tightly isolated, externally bounded execution
   with an exact stop condition and independent proof.

Keep the source discipline from the supervisor research loop: use approved
authoritative domains only, save reusable findings under `docs/docs/research/`,
and link the note from the nearest `AGENTS.md`. Do not treat a fast extraction
worker's answer as the final synthesis unless the lead worker has reviewed it.

## Vendor-Reported Model Descriptions (external context, dated 2026-07-06)

The following is vendor documentation, not local evidence. It describes how
OpenAI and Anthropic each publicly position their own model families. It is
retained here only as background context for what the vendors claim; where it
conflicts with the "Current Recommendation" section above, the local evidence
in that section controls.

**Codex manual (OpenAI):** describes `gpt-5.5` as the strongest option for
complex coding, computer-use, knowledge-work, and research workflows;
`gpt-5.4-mini` as the faster/lower-cost option for lighter coding and
subagent work; and `gpt-5.3-codex-spark` as a near-instant research-preview
model for real-time iteration. Bus-specific note: Codex workers have Bus App
Server thread/turn state and goal-tool support, which the vendor framing
alone does not capture — see the Current Recommendation for how strong Codex
profiles are actually evidenced as sub-supervisors or reviewers.

**Anthropic model overview:** positions Claude Fable 5 as the
highest-capability widely released Claude model for long-running agents,
Opus 4.8 for complex agentic coding and enterprise work, Sonnet 5 as the
speed/intelligence balance, and Haiku 4.5 as the fastest near-frontier Claude
option. The audited local evidence does not support using Opus 4.8 broadly
for complex agentic coding, or Haiku 4.5 broadly for parallel extraction
without independent evidence ownership — see the restrictions in the Current
Recommendation section.

## How This Applies To Us

`.bus/worker/templates.json` should carry short `summary` strings for quick
selection and longer `description` strings for operator guidance. The exact
model ids, runner providers, reasoning settings, and sandbox settings remain
environment-local template policy. Worker briefs should request a capability
or workflow profile, then select one of the active template ids discovered by
`bus workers template list`, applying the Current Recommendation section
above rather than the vendor-reported defaults.

Misapplication warning: do not create a new template id such as
`claude-deep-research` unless the corresponding worker identity repo and
runtime policy exist. Until then, deep research is an operator workflow whose
synthesis owner is selected from the current risk-domain recommendation and
which fans out to cheaper extraction lanes, subject to the Haiku evidence-gate
restriction above.

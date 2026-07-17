# Worker Template Model Selection

Question: How should Bus Worker operators choose Codex and Claude worker
templates, and how should a deep-research workflow split work across models?

Date: 2026-07-06
Revised: 2026-07-17, to incorporate the report's accepted July 16–17 model
relays and separate capability evidence from live provider limits and cost.

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
- **Bounded/mechanical implementation:** current GPT-5.3 Codex Spark Low is
  directly validated for narrowly frozen mechanical implementation and
  review-driven repair. Nineteen metadata changes were independently reviewed,
  promoted, composed, and followed by a full 158-module build; later package
  identity, invocation, and disk-policy repairs reached current-image proof.
  Spark still requires independent review and never owns final acceptance.
  Exact current GPT-5.4 Mini Low and GPT-5.5 Medium remain evidence-limited
  bounded trials. Claude Sonnet 5 Medium has direct accepted bounded
  implementation, documentation/synthesis, and provider-diverse review
  evidence.
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
- **Docs and bounded diagnosis:** GPT-5.6 Luna Low — evidenced for narrow
  documentation, source-backed infrastructure
  diagnosis, and smoke verification. No evidence supports low reasoning for
  the hardest implementation/review work.
- **High-effort managers do not self-accept:** a GPT-5.6 Sol Ultra manager
  produced a sophisticated, green candidate that fresh independent Sol Max
  review still rejected. Higher-effort managers own decomposition and
  candidate production; a separately assigned reviewer owns the verdict.
- **Evidence-limited settings — treat as narrow, not broad defaults:** GPT-5.6
  Terra Medium, GPT-5.4 Mini at low reasoning, and GPT-5.5 Medium as a
  standalone current-template row still have thin or unattributable
  implementation evidence. GPT-5.6 Luna Medium now has one independently
  reviewed, promoted, installed, loaded, and live-proven listener-recovery
  implementation; use it for that bounded task shape while another domain is
  still needed before making it a broad default.
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
- **Claude Haiku 4.5 is an experimental, evidence-limited extraction or
  triage trial:** its only audited deterministic-verification assignment
  produced no command or evidence before being stopped. One run is too small
  to characterize the model broadly. Any output requires independent
  confirmation, and Haiku never owns required evidence.
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

## Capacity And Cost

The performance report does not contain a complete cross-provider price,
token-cost, or latency comparison. Its confidence values measure support for
narrow quality conclusions; they are not prices or future success
probabilities. Operators should combine the role evidence above with current
provider limits and configured cost policy, then choose the least expensive
available template whose evidence is sufficient for the bounded task.

When OpenAI capacity is scarce, suitable new work should use Claude capacity
first. Sonnet Medium is the first Claude choice for bounded implementation,
documentation, synthesis, follow-through, and medium-depth provider-diverse
review. Fable High is reserved for architecture, supply-chain, exact-byte,
specification, and evidence-contract challenge. Haiku remains optional
low-risk extraction/triage with independent confirmation, and Opus remains
inside the strict read-only or externally bounded safety envelope above.
Existing OpenAI lanes that are one deterministic step from review, promotion,
installation, or live smoke should finish in place when restarting elsewhere
would consume more capacity.

Highest-effort profiles should not be routine defaults. Use them when the
acceptance risk demands adversarial review, when architecture is genuinely
ambiguous, or after a lower-cost suitable worker reached model execution and
failed on the task's reasoning or behavior. A quota or materialization failure
before model execution calls for provider/substrate recovery, not a stronger
model.

## Deep-Research Profile

For Bus Worker operators, "deep research" is a workflow profile rather than a
single runnable template id. Use this split unless a task is small enough for
one worker:

1. Lead/synthesis: select the owner from the current risk-domain
   recommendation. The dated local audit establishes no single generic
   deep-research default; Fable remains evidenced for architecture,
   supply-chain, exact-byte, and specification review.
2. Extraction/triage trial: `claude-haiku-4-5` may be assigned a low-risk,
   experimental pass for parallel source extraction, log summarization, or
   quote/evidence collection. Every output needs independent confirmation
   from the lead worker or a fallback executor before it is treated as
   evidence; Haiku never owns a required evidence gate.
3. Implementation follow-through: current Spark Low is validated for narrowly
   frozen mechanical work with independent review and separate final
   acceptance. Exact current Mini Low and GPT-5.5 Medium remain bounded trials.
   Sonnet Medium has direct accepted bounded implementation and
   documentation/synthesis evidence; use GPT-5.6 Terra High for complex,
   review-driven implementation when OpenAI capacity and task complexity
   justify it.
4. Verification/review: match the reviewer to the risk domain per the
   Current Recommendation (Sol Max / Luna Max / Terra Max / Fable 5 / Sol
   XHigh). Do not assign Opus as a default second opinion — use it only for
   read-only consultation or tightly isolated, externally bounded execution
   with an exact stop condition and independent proof.

Keep the source discipline from the supervisor research loop: use approved
authoritative domains only, save reusable findings under `docs/docs/research/`,
and link the note from the nearest `AGENTS.md`. Do not treat an extraction
trial's answer as the final synthesis unless the lead worker has independently
confirmed it.

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
which may fan out to experimental extraction trials, subject to the Haiku
evidence-gate restriction above.

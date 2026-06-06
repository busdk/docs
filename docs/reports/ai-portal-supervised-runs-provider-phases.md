---
title: "AI portal supervised runs provider phases"
description: "Phase plan for adding paid supervised task runs to the existing BusDK AI portal with model, usage, and resource decisions behind BusDK APIs."
---

## Scope

This report reviews the smallest commercially useful path for a BusDK service
where customers talk to the existing AI portal, BusDK turns some requests into
supervised runs, and the backend selects models or runtime resources under
subscription and usage limits.

The first user is not an operator managing workers. The first user is a paying
customer using chat. They ask for useful work and need to see whether the run
is allowed, what it is doing, what it consumed, and what result or evidence
came back. Worker lists, resource lifecycle controls, terminals, and raw
debugging evidence are support or operator concerns and should not drive the
first customer UI.

Phase one should therefore extend `bus-portal-ai`, not create a new
`bus-portal-supervisor` module. A separate supervisor/admin portal may become
useful later, but it is not the first paid surface.

## Existing AI portal fit

`bus-portal-ai` is already the right frontend module for the first phase. It
is a stable, explicitly enabled portal module that provides browser surfaces
for chat mode and Codex/container terminal mode while keeping backend work
behind Bus APIs.

The module already owns the pieces needed for the customer-facing path:

- Chat UI over `/v1/chat/completions`.
- Billing status, checkout, billing-portal guidance, and provider-error
  handling for unauthenticated, insufficient-scope, billing-required, and
  over-quota states.
- Operator-configured model selector values.
- Container and terminal entry points through provider APIs.
- Go/WASM runtime behavior and shared `bus-ui` action, resource, result,
  terminal, and provider-error primitives.
- Public runtime configuration only: API base URLs, browser session key, and
  model selector values.

The module must continue to avoid direct calls to `bus-integration-*` modules.
Auth, quota, account isolation, model routing, runtime wake-up, usage
recording, and resource authorization stay in API providers.

## Phase 1: paid supervised runs in chat

The first phase should add a supervised-run layer around the current chat
experience. The UI should still feel like chat. The customer writes a request,
BusDK either answers directly or creates a supervised run, and the chat thread
shows run progress and result state.

Required customer-visible behavior:

- Start from the existing chat composer.
- Show whether the request will be handled as normal chat or a supervised run.
- Show run status: queued, working, waiting for approval, completed, failed,
  blocked by billing, blocked by quota, or blocked by unavailable resource.
- Show plan and usage state near the run: included usage remaining, hard
  limit state, and estimated or actual usage for the current run.
- Show a compact model/resource badge, such as OpenAI API, Codex worker,
  local runtime, container runtime, or UpCloud GPU unavailable.
- Show a decision receipt when useful: selected backend, fallback reason,
  blocked reason, or approval reason.
- Show the result in the chat transcript, with artifact links or summaries
  where applicable.
- Show a customer-safe evidence summary: what was done, which backend class
  was used, what was consumed, and which task/run id support can inspect.

Required support/operator-only behavior:

- Worker details, worker control, terminal attach, resource lifecycle control,
  GPU availability, and sensitive evidence remain outside the customer chat
  surface.
- If these controls are temporarily exposed through `bus-portal-ai` for
  operator testing, they must be gated by server-side authorization and
  provider-side redaction. Hiding controls in browser navigation is not
  sufficient.

Required provider work:

- Add or stabilize a run/task API that the AI portal can call from chat. The
  first route set should create a supervised run, fetch run status, append a
  customer message, and fetch a customer-safe run timeline. This can be owned
  by `bus-api-provider-task` if its mounted HTTP contract is ready, or by a
  narrow AI-run facade that emits task events behind the API boundary.
- Extend `bus-api-provider-llm` model catalog responses, or add an adjacent
  BusDK model catalog route, with customer-safe selection metadata: backend
  class, capability tags, plan feature key, availability, and whether the
  model can be used for chat, code, tool use, long context, or fallback.
- Expose billing and usage summaries in a portal-friendly shape through
  `bus-api-provider-billing` and `bus-api-provider-usage`: plan status,
  included usage remaining, blocked state, subscription inactive state, trial
  state, and operator-disabled state.
- Expose resource availability summaries through VM/container/UpCloud
  providers without requiring live resource creation. The AI portal only needs
  customer-safe labels and unavailable reasons in phase one.
- Emit usage records tied to chat/run/task identifiers so the UI and support
  can explain what a paid request consumed.

Phase one should not put the model/resource selection algorithm in frontend
code. `bus-portal-ai` can display the selected backend and any allowed user
choice, but entitlement checks, routing, fallback, and enforcement must happen
behind Bus APIs.

## Phase 2: backend selection receipts

Once supervised runs are visible in chat, add a backend decision service. It
can live in an existing provider if the shape is small, or become a dedicated
supervisor/run provider if composition across task, billing, usage, LLM,
container, VM, and UpCloud providers becomes awkward.

Required features:

- Decide whether a chat request stays normal chat or becomes a supervised run.
- Choose OpenAI API, Codex/App Server, local runtime, container runtime, VM
  runtime, or UpCloud GPU where configured.
- Use plan, quota, task type, capability needs, model availability, resource
  availability, cost class, and operator policy as inputs.
- Return customer-safe decision receipts for the AI portal.
- Block before expensive usage begins when billing, quota, approval, or
  resource state does not allow the run.

This phase turns "BusDK chooses the model/resource" into a backend product
feature instead of a UI convention.

## Phase 3: subscription and usage enforcement

The paid product should sell BusDK service usage, not transferable third-party
credits. OpenAI API usage and UpCloud GPU usage are backend costs and runtime
inputs. BusDK should expose its own plans, included usage, limits, and usage
ledger.

Required features:

- Plan catalog entries for included AI usage, supervised-run usage, optional
  compute/GPU usage, hard limits, and support level.
- Pre-request entitlement checks and post-request usage recording.
- Customer-visible usage ledger tied to chat/run/task identifiers.
- Operator-visible usage and cost summaries to catch margin failures.
- Strict included limits for the first commercial version, with automatic
  overage deferred until the metering and risk controls are mature.

## Phase 4: UpCloud GPU as optional premium runtime

UpCloud GPU should not block the first sellable AI portal supervised-run
product. It should be an optional premium backend shown only when configured
and available.

Required features:

- GPU-capable resource availability summary.
- Static and no-spend proof modes.
- Start, attach, stop, cleanup, and kill-switch behavior behind VM/container
  provider APIs.
- Fallback to OpenAI API, Codex/App Server, or non-GPU runtime when GPU is not
  available.
- Usage metering tied to run/task/worker identifiers.

## Phase 5: support console if needed

A separate `bus-portal-supervisor` module should be considered only after the
customer chat product is usable and support volume requires a dedicated
operator console.

That later module would be for BusDK staff or customer admins, not the first
customer chat user. It could contain worker lists, task queues, terminal
attach, resource dashboards, GPU capacity views, evidence review, and policy
override controls. Those features still require server-side authorization and
provider-side redaction.

## Recommended first implementation queue

The first engineering queue should be:

- Extend `bus-portal-ai` with supervised-run state in the chat transcript.
- Add customer-safe run status, decision receipt, usage summary, and evidence
  summary view models.
- Add AI portal API clients for run create/status/message/timeline and
  billing/usage summary.
- Stabilize the provider route that creates and follows a supervised run from
  chat.
- Extend the LLM/model catalog enough to show backend class and availability.
- Expose resource unavailable reasons in a customer-safe form.
- Tie usage events to chat/run/task identifiers.

The first paid offer can then be: authenticated AI chat with supervised runs,
hard usage limits, visible run progress, backend-selected OpenAI or Codex
execution, optional UpCloud GPU when configured, and a customer-safe summary of
what happened. Operator consoles and full resource management can wait.

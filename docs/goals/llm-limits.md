# LLM Limit Visibility Goal

## Goal

Implement Bus support for detecting and reporting remaining LLM/account limits,
starting with ChatGPT subscription limits observed through Codex.

The immediate problem is operational: a Bus worker using GPT 5.3 Codex Spark
briefly reached 0% remaining on its 5-hour window. Operators need a scriptable
way to see that before worker dispatch, during triage, and from status
surfaces.

The first supported provider is the ChatGPT subscription as exposed by Codex
App Server or Codex CLI metadata. The first required limit subjects are:

- the ChatGPT subscription as a whole:
  - 5-hour window;
  - weekly window;
- the GPT 5.3 Codex Spark model or worker profile:
  - 5-hour window;
  - weekly window.

This goal must not hard-code only those four buckets. The implementation must
support additional providers, products, models, plans, accounts, credential
sources, windows, and units later.

## Operator Direction Captured

The operator split this out from the Services Docker goal and requested:

```text
docs/docs/goals/llm-limits.md
```

The goal is to figure out the affected Bus modules first, then later implement
a CLI tool and API that can report available limits for ChatGPT subscription
usage with Codex. The design should remain generic enough for non-ChatGPT
subscription limits.

This is a goal-file definition only. Product implementation must use Bus
Workers and worker-owned worktrees/branches before changing module code.

## Current Evidence And Source Signal

Codex/App Server session events already expose useful rate-limit metadata. A
recent worker session emitted a `rate_limits` object with:

```text
limit_id
limit_name
primary.used_percent
primary.window_minutes
primary.resets_at
secondary.used_percent
secondary.window_minutes
secondary.resets_at
```

The same event also carried model/runtime context in nearby metadata, such as
the selected model and worker profile. For the observed failure mode, the
primary window behaved like the 5-hour limit and the secondary window behaved
like the weekly limit.

The first implementation should consume this kind of structured Codex/App
Server metadata when available. It must not scrape human text, rely on a
browser-only ChatGPT page, or invent absolute quotas when the source only
reports percentages.

Upstream Codex source confirms this is a structured protocol surface, not only
an incidental log shape. As of 2026-06-06, `openai/codex` contains
`codex-rs/codex-api/src/rate_limits.rs`, which parses:

- the default `codex` header family;
- additional limit families discovered from `x-<limit>-primary-used-percent`
  style headers;
- primary and secondary windows with used percent, window minutes, and reset
  timestamps;
- credits, plan type, limit id, and limit name where available;
- `codex.rate_limits` event payloads into the same snapshot shape.

Upstream Codex issue evidence also points to the App Server JSON-RPC method
`account/rateLimits/read`, which returns a backward-compatible `rateLimits`
object and a `rateLimitsByLimitId` map. The Bus implementation should prefer
this structured method or the parsed App Server events over scanning rollout
files when a running App Server is available.

## Product Contract

Bus should expose a normalized limit snapshot with enough structure to answer:

- which provider or runtime reported the limit;
- which account, credential source, environment, worker profile, model, plan,
  or subscription the limit applies to, when known;
- which window is being reported, such as 5-hour, daily, weekly, monthly,
  rolling, or fixed reset;
- which unit is being limited, such as messages, requests, tokens, compute,
  turns, minutes, cost, or an unknown backend-defined unit;
- how much is used and remaining, including percent-only snapshots;
- when the window resets, when the snapshot was observed, and how stale it is;
- whether the source is live, cached, unavailable, unsupported, or
  partially-known.

The initial Codex shape should support percent-only windows:

```json
{
  "provider": "chatgpt",
  "runtime": "codex",
  "model": "gpt-5.3-codex-spark",
  "limit_id": "codex",
  "scope": "model",
  "windows": [
    {
      "kind": "rolling",
      "label": "5h",
      "duration_minutes": 300,
      "used_percent": 100,
      "remaining_percent": 0,
      "resets_at": "2026-06-06T13:39:32Z"
    },
    {
      "kind": "rolling",
      "label": "weekly",
      "duration_minutes": 10080,
      "used_percent": 23,
      "remaining_percent": 77,
      "resets_at": "2026-06-13T13:39:32Z"
    }
  ],
  "observed_at": "2026-06-06T12:40:00Z",
  "source": "codex_app_server_event"
}
```

If Codex does not distinguish subscription-wide and model-specific limits in
one event, Bus must report the distinction as unknown rather than guessing.
The collector can enrich snapshots with worker profile, model, auth mode, and
credential-source metadata so operators can correlate the limit to
`codex-spark`, `gpt-5.3-codex-spark`, or a ChatGPT subscription credential.

## CLI Contract

The CLI should be script-friendly and usable before dispatching expensive work.
The first user-facing shape should live under the existing `bus-agent` module:

```bash
bus agent limits
bus agent limits --provider chatgpt
bus agent limits --provider chatgpt --runtime codex
bus agent limits --provider chatgpt --model gpt-5.3-codex-spark
bus agent limits --environment dev-hg --worker-profile codex-spark
bus agent limits --format json
bus agent limits check --provider chatgpt --model gpt-5.3-codex-spark \
  --window 5h --remaining-percent-gt 10
```

A future `bus llm limits` alias or module may be added if the command becomes
broader than agent-runtime limits. It should reuse the same API and data model
rather than duplicating Codex-specific probing.

The command should:

- return exit 0 when at least one current or cached snapshot is available;
- return exit 0 with a stale warning when live detection fails but a usable
  cached snapshot is available;
- return exit 1 only when the provider is configured but no usable live or
  cached snapshot is available;
- return exit 2 for invalid flags or unsupported filter combinations;
- support `--format text|json` and stable machine-readable JSON;
- show reset times in absolute timestamps, not only relative phrases;
- clearly distinguish live snapshots from cached/stale snapshots;
- avoid printing secrets, auth homes, raw tokens, session file bodies, or broad
  environment data.

The CLI must also provide a scriptable predicate mode. The preferred shape is:

```bash
bus agent limits check --remaining-percent-gt 10
bus agent limits check --provider chatgpt --window 5h --remaining-percent-gt 10
bus agent limits check --worker-profile codex-spark --window weekly \
  --remaining-percent-gte 25
```

Predicate mode should:

- return exit 0 when every selected limit window satisfies the predicate;
- return exit 1 when at least one selected limit window does not satisfy the
  predicate, no usable snapshot exists, or the selected snapshot is stale and
  stale data is not explicitly allowed;
- return exit 2 for invalid predicates, unsupported windows, or incompatible
  filters;
- support `--window 5h|weekly|all` and leave room for duration-based selectors
  such as `--window-duration-minutes 300`;
- support both strict and inclusive comparisons, such as
  `--remaining-percent-gt 10` and `--remaining-percent-gte 10`;
- optionally support `--allow-stale` with clear output that the predicate was
  evaluated against stale data;
- print a concise human diagnostic to stderr on failure and stable JSON to
  stdout when `--format json` is requested.

The command may initially read from a local App Server/Codex probe, a worker
session event store, or a Bus API endpoint. The long-term command should prefer
the Bus API when a service is configured and fall back to local provider probes
only when explicitly requested.

## API Contract

Bus should expose a provider-neutral API for limit snapshots. A suitable first
shape is an internal API mounted by `bus-api`:

```text
GET /api/internal/llm/limits
GET /api/internal/llm/limits?provider=chatgpt
GET /api/internal/llm/limits?provider=chatgpt&model=gpt-5.3-codex-spark
GET /api/internal/llm/limits?environment=dev-hg&worker_profile=codex-spark
```

The API response should include:

- `items`: normalized limit snapshots;
- `observed_at`, `expires_at`, and `stale` fields;
- provider/source metadata;
- model/profile/account/environment filters when known;
- structured warnings for partial data, unsupported providers, stale cache, or
  live probe failure.

Authentication and authorization should follow existing internal Bus API
patterns. A read-only scope such as `llm:limits:read` or `usage:read` may be
chosen during implementation, but the chosen scope must be explicit in tests
and docs.

Do not expose ChatGPT credentials, Codex auth home paths, raw session logs, or
token values through this API.

## Data Model Requirements

The normalized model must support:

- provider id, runtime id, integration id, source id, and source kind;
- account id or credential-source label without raw credential values;
- model id and worker profile when available;
- subject scope values such as `subscription`, `model`, `worker_profile`,
  `account`, `organization`, `environment`, or `unknown`;
- arbitrary windows with duration, reset timestamp, and rolling/fixed kind;
- percent-only limits;
- absolute used/limit/remaining values when a provider reports them;
- unit values such as `message`, `request`, `token`, `minute`, `compute`,
  `currency`, or `unknown`;
- source confidence: `live`, `cached`, `inferred`, `partial`, `unsupported`,
  and `unavailable`;
- schema versioning so later providers can add fields without breaking the CLI.

Do not conflate these limit snapshots with billable usage events. Usage records
say what Bus consumed or billed. Limit snapshots say what an upstream provider
currently allows or has throttled.

## Affected Bus Modules

Primary implementation owners:

- `bus-agent`: owns reusable Codex App Server protocol helpers and the first
  user-facing CLI surface for agent-runtime limit checks:
  `bus agent limits` and `bus agent limits check`. It should parse
  provider-emitted rate-limit metadata into a stable Go type without importing
  provider integrations. This is the right place for low-level App
  Server/Codex event parsing, local App Server probing, hermetic parser tests,
  and script-friendly predicate exit codes.
- `bus-integration-codex`: owns provider-specific Codex behavior. It should
  collect live ChatGPT/Codex limit snapshots, map Codex `rate_limits` metadata
  into the normalized model, perform any low-impact live probe, and publish
  provider-neutral limit events or API client responses.
- `bus-api-provider-llm`: owns LLM API/model surfaces. It should expose the
  provider-neutral limit read API, enforce read authorization, and keep
  OpenAI-compatible `/v1/*` behavior separate from Bus internal limit endpoints.
- optional future `bus-llm` CLI module: may own a provider-neutral
  `bus llm limits` alias later if the feature grows beyond agent-runtime
  limits. It should not be required for the first Codex/ChatGPT implementation.
  The root `bus` dispatcher must not implement limit logic; it should only
  dispatch to `bus-agent` or a future `bus-llm` executable.

Important supporting owners:

- `bus-integration-worker`: carries worker profile, model, environment, auth
  mode, App Server URL, and Codex home metadata for direct workers. It should
  attach or expose enough non-secret context to correlate a limit snapshot to
  a worker profile such as `codex-spark`.
- `bus-worker`: owns durable worker identity semantics and may need read-only
  status fields if worker status should show current limit pressure.
- `bus-api-provider-usage` and `bus-integration-usage`: may store or serve
  cached limit snapshots if the first API needs persistence or billing
  correlation. They should not own live Codex collection.
- `bus-api-provider-inference` and `bus-operator-inference`: may later expose
  non-Codex provider/runtime limits, but they should not be the first owner of
  ChatGPT/Codex subscription telemetry unless implementation shows the LLM API
  boundary is the wrong fit.
- `bus-services`: may eventually include the limit collector in
  `services.yml`, but it should only supervise the collector service; it should
  not own limit parsing or API semantics.
- `bus-config` or `bus-preferences`: may own non-secret defaults such as
  preferred provider, default model, stale-cache TTL, or CLI display policy.

Modules that should not own this feature:

- `bus-events`, `bus-api`, and individual model/provider runtime modules should
  remain transport or service hosts unless they already own the specific API
  mount or provider integration.
- `bus-billing` should not be the first owner. Provider limits inform
  dispatch/capacity decisions; billing may consume snapshots later.

## Suggested Implementation Slices

1. Define the provider-neutral limit snapshot schema in the smallest shared
   package that both the API provider and Codex collector can use.

2. Add hermetic parser coverage for Codex/App Server `rate_limits` metadata.
   Tests must include 5-hour and weekly windows, missing `limit_name`,
   percent-only values, reset timestamps, unknown units, and malformed input.

3. Implement a Codex collector that can produce a snapshot from one of these
   sources, in preferred order:

   - structured App Server event metadata from an existing worker/session;
   - a low-impact live Codex/App Server probe that returns rate-limit metadata;
   - a cached recent snapshot when live collection is unavailable.

4. Add the provider-neutral API endpoint with authentication, filtering, stale
   cache behavior, and JSON tests.

5. Add `bus agent limits` with text and JSON output, provider/model/profile
   filters, deterministic exit codes, predicate checks such as
   `--remaining-percent-gt 10`, and no secret leakage.

6. Integrate worker status or scheduling only after the read surfaces work.
   A worker dispatcher can then avoid selecting a profile whose 5-hour limit is
   exhausted, or at least surface a precise operator warning.

## Verification Requirements

Deterministic tests:

- parser maps Codex `primary.window_minutes=300` into a 5-hour window without
  hardcoding only that window;
- parser maps `secondary.window_minutes=10080` into a weekly window without
  assuming all providers use weekly secondary limits;
- parser computes remaining percent from used percent when absolute remaining
  is absent;
- malformed or missing fields yield partial/unavailable snapshots without
  panics;
- API filters by provider, model, worker profile, environment, and source;
- CLI JSON output is stable and secret-free;
- CLI text output names the absolute reset timestamp;
- CLI predicate mode returns exit 0 when selected windows satisfy the
  threshold and exit 1 when they do not;
- CLI predicate mode supports strict and inclusive remaining-percent checks;
- stale cache behavior is visible in API and CLI output;
- all tests use fake Codex/App Server events or clients, not real ChatGPT
  credentials.

Live or opt-in proof:

- run a Codex/App Server session with ChatGPT subscription auth and capture a
  real `rate_limits` snapshot;
- show ChatGPT subscription and GPT 5.3 Codex Spark windows when the source
  distinguishes them;
- when the source does not distinguish them, show `scope: unknown` or
  `scope: model` with a warning rather than fabricating subscription-wide data;
- prove the CLI reports the 5-hour and weekly windows with used/remaining
  percentages and reset timestamps;
- prove the API returns the same normalized data;
- prove logs, status, and API responses do not contain raw credentials,
  session bodies, auth home contents, or tokens.

## Open Questions

- Does Codex expose separate subscription-wide and model-specific limits in one
  structured source, or only the effective limit for the selected model/runtime?
- Is a low-impact live probe acceptable, or should Bus only consume
  rate-limit metadata opportunistically from real worker turns?
- Should cached snapshots live in the usage database, worker status storage,
  or a new small limit-snapshot store?
- Should `bus agent limits` be considered an operator command only, or should it
  be exposed to end users with account-scoped authorization?
- Should a later `bus llm limits` alias be introduced once non-agent LLM
  providers are supported?
- Which scope name should guard the API: `llm:limits:read`,
  `inference:read`, or an extension of `usage:read`?

## Current State At Handoff

This goal is defined but not implemented. The first implementation should
start with module-owned workers, not supervisor-local product edits.

The recommended primary path is:

1. `bus-agent` parser/type support for Codex/App Server rate-limit metadata.
2. `bus-integration-codex` live/cached collector for ChatGPT/Codex snapshots.
3. `bus-api-provider-llm` internal read API for normalized limit snapshots.
4. `bus-agent` CLI support for `bus agent limits`.
5. Optional `bus-integration-worker` status integration after the read surfaces
   are proven.

The key acceptance condition is that an operator can see the 5-hour and weekly
limit state for ChatGPT/Codex, including GPT 5.3 Codex Spark when available,
through both a CLI and API without exposing secrets and without hardcoding a
data model that prevents other providers or limit types later.

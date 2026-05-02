---
title: bus-api-provider-llm — OpenAI-compatible LLM provider
description: bus-api-provider-llm is the Bus API provider for OpenAI-compatible /v1 model proxy behavior.
---

## `bus-api-provider-llm` — OpenAI-compatible LLM provider

`bus-api-provider-llm` is the provider for OpenAI-compatible `/v1/*` model
proxy behavior. It lets end users call Bus-hosted LLM services with normal
OpenAI-compatible clients while Bus handles authentication, billing
entitlement, runtime wake-up, streaming, and usage metering.

The provider validates Bus API JWTs issued by `bus auth`. The same
OpenAI-compatible API can be used by tools such as `bus-agent`, but existing
non-Bus model providers and credential flows can remain available in those
client tools.

### Authentication

Execution endpoints require a Bearer JWT with audience `ai.hg.fi/api` and
scope `llm:proxy`. `GET /v1/models` also requires a valid bearer token so the
catalog is not public, but it does not check billing entitlement or wake the
runtime.

The JWT `sub` is the account UUID used for billing and usage records.

### `GET /v1/models`

Returns the model catalog shown to end users.

By default this endpoint uses the configured local catalog. It does not wake
GPU runtimes, check billing entitlement, or probe the backend.

Use proxy mode only when the deployment intentionally wants model listing to be
forwarded to the backend.

### `POST /v1/chat/completions`

Proxies OpenAI-compatible chat completion requests to the configured backend,
or publishes a provider-neutral LLM execution event when
`--execution-backend events` is selected.

Streaming requests are forwarded chunk by chunk. When possible, the provider
adds `stream_options.include_usage=true` so streamed responses can include
token usage for billing.

### `POST /v1/completions`

Proxies OpenAI-compatible text completion requests or sends the matching Bus
LLM execution event when event-backed execution is enabled.

The provider applies the same authentication, billing, runtime readiness, and
usage recording behavior as chat completions.

### `POST /v1/responses`

Proxies OpenAI-compatible Responses API requests or sends the matching Bus LLM
execution event when event-backed execution is enabled.

Use this endpoint for clients that target the newer OpenAI-compatible response
shape.

### `POST /v1/embeddings`

Proxies OpenAI-compatible embedding requests.

Embedding requests are authenticated and metered under the same account as
other execution requests.

### `GET /readyz`

Reports provider readiness.

When required Events listeners are enabled, readiness stays unhealthy until the
runtime, usage, and billing response streams are connected.

### Billing Enforcement

When `--billing-backend events` is enabled, execution endpoints check
entitlement before runtime wake-up or backend proxying.

Denied access returns `billing_required` or `quota_exceeded` with guidance from
the billing system.

### Runtime Wake-Up

When `--runtime-backend events` is enabled, the provider uses VM runtime events
to make the backend available before forwarding execution requests.

Model catalog reads do not trigger runtime wake-up.

### Usage Recording

The provider records request lifecycle and token-usage events through direct
storage or `bus-integration-usage`.

Client disconnects during streaming cancel upstream work and record a terminal
abort/failure event when backend work may have started.

### `--addr <addr>`

Selects the listen address for the provider.

### `--backend-url <url>`

Sets the OpenAI-compatible backend URL used for execution requests when
`--execution-backend http` is selected.

Use the provider root as the base URL, without appending `/v1`; the LLM
provider appends the incoming `/v1/*` request path itself. For example:

```sh
bus-api-provider-llm --backend-url http://127.0.0.1:11434
```

### `--execution-backend <http|events>`

Selects where model execution runs.

Use `http` to proxy requests directly to an OpenAI-compatible backend at
`--backend-url`.

Use `events` to publish provider-neutral `bus.llm.*` execution events. This is
the preferred local Bus architecture for Codex-backed development because
`bus-api-provider-llm` stays responsible for REST compatibility, JWTs, billing,
runtime readiness, and usage records while integrations such as
[`bus-integration-codex`](./bus-integration-codex) own provider-specific model
execution.

When `events` is selected, the provider listens for correlated response events
and does not require `--backend-url`. The provider service token must have
`llm:proxy` for publishing and listening to `bus.llm.*` events.

### `--model-catalog <path>`

Loads the local `/v1/models` catalog from a JSON file.

The matching environment variable is `BUS_LLM_MODEL_CATALOG`.

### `--models-backend <catalog|proxy>`

Selects how `/v1/models` is served.

Use `catalog` for production deployments that should not wake GPU backends on
model listing. Use `proxy` only when backend model listing is intended.

### `--runtime-backend <none|events>`

Controls runtime wake-up.

Use `events` when the provider should ask the Bus VM/runtime layer to start or
verify the backend before execution requests.

### `--usage-backend <none|events>`

Controls usage recording.

Use `events` when usage should be collected by `bus-integration-usage`.

### `--billing-backend <none|events>`

Controls billing entitlement checks.

Use `events` for paid LLM plans.

### `--events-url <url>`

Sets the Bus Events API URL used by runtime, usage, and billing event backends.

Provide the provider's Events token through deployment-managed configuration,
such as `BUS_API_TOKEN`. Do not pass bearer tokens as command-line arguments.
When `--execution-backend events` is enabled, the token must be able to send
and receive `bus.llm.*` events with `llm:proxy`. When `--runtime-backend
events` is enabled, the token must be able to send VM start/status requests and
receive the correlated responses, typically `vm:write` and `vm:read`. When
`--usage-backend events` is enabled, it needs usage write permissions such as
`usage:write`. When `--billing-backend events` is enabled, it needs
entitlement-check permission such as `billing:entitlement:check`. Deployments
may use an internal service token for these provider-to-provider calls.

### `--backend-ready-path <path>`

Sets the backend readiness path checked after runtime wake-up.

Common values are `/v1/models` for OpenAI-compatible backends and `/api/tags`
for Ollama-compatible backends.

### `--backend-ready-timeout <duration>`

Sets the maximum time to wait for backend readiness.

### `--backend-ready-poll-interval <duration>`

Sets the delay between backend readiness attempts.

### `--backend-ready-statuses <codes>`

Sets the HTTP status codes that count as backend-ready. Use comma-separated
integer status codes, such as `200,204`. The default ready status set is
`200,204`.

### `BUS_EVENTS_LISTENER_REQUIRED`

When set to `1`, readiness requires the Events response listeners needed by the
enabled backends.

### End-User Access

Approved users request an API token with LLM scope:

```sh
bus auth token --audience ai.hg.fi/api --scope "llm:proxy"
```

`llm:proxy` is the required scope for model execution. Add `billing:read` only
when the same token will also call billing status or setup APIs.

They can then use the token with OpenAI-compatible clients by setting the base
URL to the Bus LLM endpoint and using the Bus API token as the bearer token.
For a hosted AI Platform deployment this is commonly the `/v1` API base URL.

Billing setup is required only when the deployment enforces billing for the
feature. If billing is missing or quota is exhausted, the provider returns a
deterministic error with guidance instead of waking the runtime or forwarding
the request to the backend.

### Usage And Billing

The provider records lifecycle events for request starts, runtime readiness,
backend starts and finishes, successful token usage, missing usage,
request failures, and client aborts. `bus-integration-usage` can export
successful token usage to `bus-integration-billing`, which counts quota buckets
and records payment-provider meter events such as Stripe meter events.

Streaming clients that disconnect early cancel upstream work and record a
terminal failure/abort usage event when backend work may have started. This
keeps billing and operational records aligned with actual work attempted by the
service.

For Stripe-backed deployments, configure billing and Stripe integrations before
enabling paid LLM access for users. Keep Stripe keys and webhook secrets in
deployment secrets or untracked local operator configuration.

### Sources

- [bus-billing](./bus-billing)
- [bus-integration-usage](./bus-integration-usage)
- [bus-api-provider-vm](./bus-api-provider-vm)
- [bus-integration-codex](./bus-integration-codex)

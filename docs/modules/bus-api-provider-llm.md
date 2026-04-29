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

### API

```text
GET  /readyz
GET  /v1/models
POST /v1/responses
POST /v1/chat/completions
POST /v1/completions
POST /v1/embeddings
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default
and require `llm:proxy`. The JWT `sub` must be the stable account UUID. The
provider forwards execution requests to the configured backend, strips client
`Authorization` and `Proxy-Authorization` before forwarding, streams backend
responses to the caller, and records request lifecycle plus token usage through
direct usage storage or through `bus-integration-usage`.

When `--billing-backend events` is enabled, execution endpoints also require an
active provider-neutral billing entitlement from `bus-integration-billing`
before runtime wake-up or backend proxying. Denied access returns
`billing_required` with `bus billing setup` guidance, or `quota_exceeded` when
the active plan has exhausted a configured quota window.

`GET /v1/models` uses a configured local model catalog by default, so listing
models does not wake GPU backends. Configure it with `--model-catalog <path>` or
`BUS_LLM_MODEL_CATALOG`. Use `--models-backend proxy` only when a deployment
explicitly wants model listing forwarded to the backend.
Catalog-mode `GET /v1/models` does not check billing entitlement, wake runtime,
or probe the backend.

For runtime wake-up, start the provider with `--runtime-backend events` and
provide `--events-url` plus a normal Bus API token in `BUS_API_TOKEN`. The
provider then uses `bus.vm.status.request` and
`bus.vm.start.request` events through `bus-api-provider-events`; concrete cloud
or SSH work remains in the corresponding `bus-integration-*` workers.
After runtime wake-up, execution endpoints wait for the configured backend
service readiness path before proxying. Configure `--backend-ready-path`,
`--backend-ready-timeout`, `--backend-ready-poll-interval`, and
`--backend-ready-statuses`, or the matching `BUS_LLM_BACKEND_READY_*`
environment variables. When runtime events are enabled and no readiness path is
supplied, the default path is `/v1/models`. Catalog-mode `GET /v1/models` still
returns local configured data and does not wake or probe the backend.
Events response listeners use the shared `BUS_EVENTS_LISTENER_*` retry
environment so the provider can start before Events API and reconnect after
stream restarts; static-token auth failures fail fast by default. When
`BUS_EVENTS_LISTENER_REQUIRED=1`, `GET /readyz` reports unhealthy until the
required runtime and usage response streams are connected.
Billing entitlement response streams are included in readiness when
`--billing-backend events` is used with required listeners.

Typical production flags and environment include:

```sh
BUS_API_TOKEN_FILE=/run/secrets/bus-api-token \
bus-api-provider-llm \
  --addr 127.0.0.1:8080 \
  --backend-url http://127.0.0.1:11434 \
  --model-catalog /etc/bus/llm-model-catalog.json \
  --runtime-backend events \
  --usage-backend events \
  --billing-backend events \
  --events-url http://127.0.0.1:8090/api/v1/events \
  --backend-ready-path /v1/models
```

The provider token used for Events should be deployment-managed and should have
only the scopes needed for runtime, usage, and billing event exchange. Do not
pass bearer tokens as command-line arguments.

Streaming chat/completion requests that set `stream=true` are amended with
`stream_options.include_usage=true` when possible, so streamed responses can
include billing usage. The provider records `request_started`, `runtime_ready`,
`backend_request_started`, `backend_request_finished`, `usage_recorded`,
`usage_missing`, `request_failed`, and `client_aborted`. Client-abort recording
uses a bounded post-response context so a disconnected streaming caller does not
hide the terminal usage event.

The module e2e suite proves the replacement flow with local non-secret
components: `bus auth` issues the model token, Events API wakes the runtime,
the proxy streams the backend response, `bus-integration-usage` persists usage
to PostgreSQL, and `bus-api-provider-usage` exposes collector read/delete.
Set `BUS_LLM_E2E_DATABASE_URL` or `BUS_USAGE_E2E_DATABASE_URL` to use an
existing local PostgreSQL database, or let the e2e suite start a disposable
Docker Compose PostgreSQL service when Docker is available.

### End-User Access

Approved users request an API token with LLM scope:

```sh
bus auth token --scope "llm:proxy billing:read"
```

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

The complete paid LLM billing flow is available as an opt-in e2e because it
uses Docker Compose and Stripe test-mode APIs:

```sh
set -a
. ../.env
set +a
BUS_LLM_FULL_BILLING_E2E=1 make e2e
```

The local `.env` must provide Stripe test values such as
`BUS_STRIPE_SECRET_KEY` and `BUS_STRIPE_WEBHOOK_SECRET`; do not commit it. The
suite starts PostgreSQL and MailHog, registers a user by email OTP, verifies
waitlist denial, approves the user through the internal auth route, creates an
isolated Stripe test price, verifies checkout and webhook entitlement, performs
a streamed LLM call, persists usage, exports usage to a Stripe meter, and checks
account isolation, internal-only billing authorization, backend auth-header
stripping, and secret redaction.

### Sources

- [bus-api-provider-llm README](../../../bus-api-provider-llm/README.md)

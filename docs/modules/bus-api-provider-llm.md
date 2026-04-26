---
title: bus-api-provider-llm — OpenAI-compatible LLM provider
description: bus-api-provider-llm is the Bus API provider for OpenAI-compatible /v1 model proxy behavior.
---

## `bus-api-provider-llm` — OpenAI-compatible LLM provider

`bus-api-provider-llm` is the provider for OpenAI-compatible `/v1/*` model
proxy behavior extracted from AI Platform api-proxy.

The provider should validate Bus auth model-access JWTs as one supported
credential source. Existing `bus-agent` providers and credential flows must
remain available.

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

`GET /v1/models` uses a configured local model catalog by default, so listing
models does not wake GPU backends. Configure it with `--model-catalog <path>` or
`BUS_LLM_MODEL_CATALOG`. Use `--models-backend proxy` only when a deployment
explicitly wants model listing forwarded to the backend.

For runtime wake-up, start the provider with `--runtime-backend events` and
provide `--events-url` plus a normal Bus API token in `--api-token` or
`BUS_API_TOKEN`. The provider then uses `bus.vm.status.request` and
`bus.vm.start.request` events through `bus-api-provider-events`; concrete cloud
or SSH work remains in the corresponding `bus-integration-*` workers.

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

### Sources

- [bus-api-provider-llm README](../../../bus-api-provider-llm/README.md)
